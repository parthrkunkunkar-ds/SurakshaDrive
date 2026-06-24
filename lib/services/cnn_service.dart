import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class CnnService {
  Isolate? _isolate;
  SendPort? _sendPort;
  final ReceivePort _receivePort = ReceivePort();
  bool _isReady = false;
  double _lastScore = -1.0;

  double get lastScore => _lastScore;

  Future<void> init() async {
    final byteData = await rootBundle.load(
      'assets/models/drivesafe_float16.tflite',
    );
    final modelBytes = byteData.buffer.asUint8List();

    _isolate = await Isolate.spawn(
      _cnnIsolateEntry,
      _IsolateInitPayload(
        sendPort: _receivePort.sendPort,
        modelBytes: modelBytes,
      ),
    );

    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _isReady = true;
        debugPrint('✅ CNN isolate ready');
      } else if (message is double) {
        _lastScore = message;
        debugPrint('🤖 CNN score: $_lastScore');
      }
    });
  }

  void submitFrame({
    required Uint8List yBytes,
    required Uint8List uBytes,
    required Uint8List vBytes,
    required int yRowStride,
    required int uvRowStride,
    required int uvPixelStride,
    required int width,
    required int height,
    required double faceLeft,
    required double faceTop,
    required double faceRight,
    required double faceBottom,
    double? leftEyeLeft,
    double? leftEyeTop,
    double? leftEyeRight,
    double? leftEyeBottom,
    double? rightEyeLeft,
    double? rightEyeTop,
    double? rightEyeRight,
    double? rightEyeBottom,
  }) {
    if (!_isReady || _sendPort == null) return;
    _sendPort!.send(_FramePayload(
      yBytes: yBytes,
      uBytes: uBytes,
      vBytes: vBytes,
      yRowStride: yRowStride,
      uvRowStride: uvRowStride,
      uvPixelStride: uvPixelStride,
      width: width,
      height: height,
      faceLeft: faceLeft,
      faceTop: faceTop,
      faceRight: faceRight,
      faceBottom: faceBottom,
      leftEyeLeft: leftEyeLeft,
      leftEyeTop: leftEyeTop,
      leftEyeRight: leftEyeRight,
      leftEyeBottom: leftEyeBottom,
      rightEyeLeft: rightEyeLeft,
      rightEyeTop: rightEyeTop,
      rightEyeRight: rightEyeRight,
      rightEyeBottom: rightEyeBottom,
    ));
  }

  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort.close();
    _isReady = false;
  }
}

void _cnnIsolateEntry(_IsolateInitPayload payload) async {
  final receivePort = ReceivePort();
  payload.sendPort.send(receivePort.sendPort);

  final interpreter = Interpreter.fromBuffer(payload.modelBytes);
  debugPrint('✅ CNN interpreter loaded in isolate');

  bool busy = false;

  await for (final message in receivePort) {
    if (message is! _FramePayload) continue;
    if (busy) continue;

    busy = true;
    try {
      final score = _runInference(interpreter, message);
      payload.sendPort.send(score);
    } catch (e) {
      debugPrint('💥 CNN isolate error: $e');
    }
    busy = false;
  }
}

double _runInference(Interpreter interpreter, _FramePayload frame) {
  final width = frame.width;
  final height = frame.height;

  // Use precise eye contour boxes if available, else fall back to face box estimate
  double cropLeft, cropTop, cropRight, cropBottom;

  if (frame.leftEyeLeft != null && frame.rightEyeRight != null) {
    // Combine both eye boxes into one region covering both eyes
    cropLeft = frame.leftEyeLeft!;
    cropTop = (frame.leftEyeTop! < frame.rightEyeTop!)
        ? frame.leftEyeTop!
        : frame.rightEyeTop!;
    cropRight = frame.rightEyeRight!;
    cropBottom = (frame.leftEyeBottom! > frame.rightEyeBottom!)
        ? frame.leftEyeBottom!
        : frame.rightEyeBottom!;
  } else {
    // Fallback to face box estimate
    final faceH = frame.faceBottom - frame.faceTop;
    final faceW = frame.faceRight - frame.faceLeft;
    cropLeft = frame.faceLeft + faceW * 0.05;
    cropTop = frame.faceTop + faceH * 0.25;
    cropRight = frame.faceRight - faceW * 0.05;
    cropBottom = frame.faceTop + faceH * 0.60;
  }

  final eyeLeft = cropLeft.toInt().clamp(0, width - 1);
  final eyeTop = cropTop.toInt().clamp(0, height - 1);
  final eyeRight = cropRight.toInt().clamp(0, width - 1);
  final eyeBottom = cropBottom.toInt().clamp(0, height - 1);
  final cropW = (eyeRight - eyeLeft).clamp(1, width - eyeLeft);
  final cropH = (eyeBottom - eyeTop).clamp(1, height - eyeTop);

  // Convert ONLY the eye region pixels directly — no full frame conversion
  final resized = img.Image(width: 64, height: 64);
  final scaleX = cropW / 64.0;
  final scaleY = cropH / 64.0;

  for (int py = 0; py < 64; py++) {
    for (int px = 0; px < 64; px++) {
      final srcX = (eyeLeft + px * scaleX).toInt().clamp(0, width - 1);
      final srcY = (eyeTop + py * scaleY).toInt().clamp(0, height - 1);

      final yVal = frame.yBytes[srcY * frame.yRowStride + srcX];
      final uvIndex =
          (srcY ~/ 2) * frame.uvRowStride + (srcX ~/ 2) * frame.uvPixelStride;
      final uVal = frame.uBytes[uvIndex];
      final vVal = frame.vBytes[uvIndex];

      final r = (yVal + 1.370705 * (vVal - 128)).round().clamp(0, 255);
      final g = (yVal - 0.698001 * (vVal - 128) - 0.337633 * (uVal - 128))
          .round().clamp(0, 255);
      final b = (yVal + 1.732446 * (uVal - 128)).round().clamp(0, 255);
      resized.setPixelRgb(px, py, r, g, b);
    }
  }

  final input = List.generate(
    1,
    (_) => List.generate(
      64,
      (y) => List.generate(
        64,
        (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        },
      ),
    ),
  );

  final output = List.generate(1, (_) => List.filled(1, 0.0));
  interpreter.run(input, output);
  return output[0][0];
}

class _IsolateInitPayload {
  final SendPort sendPort;
  final Uint8List modelBytes;
  _IsolateInitPayload({required this.sendPort, required this.modelBytes});
}

class _FramePayload {
  final Uint8List yBytes;
  final Uint8List uBytes;
  final Uint8List vBytes;
  final int yRowStride;
  final int uvRowStride;
  final int uvPixelStride;
  final int width;
  final int height;
  final double faceLeft;
  final double faceTop;
  final double faceRight;
  final double faceBottom;
  final double? leftEyeLeft;
  final double? leftEyeTop;
  final double? leftEyeRight;
  final double? leftEyeBottom;
  final double? rightEyeLeft;
  final double? rightEyeTop;
  final double? rightEyeRight;
  final double? rightEyeBottom;

  _FramePayload({
    required this.yBytes,
    required this.uBytes,
    required this.vBytes,
    required this.yRowStride,
    required this.uvRowStride,
    required this.uvPixelStride,
    required this.width,
    required this.height,
    required this.faceLeft,
    required this.faceTop,
    required this.faceRight,
    required this.faceBottom,
    this.leftEyeLeft,
    this.leftEyeTop,
    this.leftEyeRight,
    this.leftEyeBottom,
    this.rightEyeLeft,
    this.rightEyeTop,
    this.rightEyeRight,
    this.rightEyeBottom,
  });
}