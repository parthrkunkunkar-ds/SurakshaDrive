import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class DetectionService {
  late FaceDetector _faceDetector;
  bool _isProcessing = false;

  DetectionService() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.05,
      ),
    );
  }

  Future<DetectionResult?> processFrame(
    CameraImage image,
    InputImageRotation rotation,
  ) async {
    if (_isProcessing) return null;
    _isProcessing = true;

    try {
      final inputImage = _convertToInputImage(image, rotation);
      if (inputImage == null) {
        debugPrint('❌ InputImage conversion failed');
        return null;
      }

      final faces = await _faceDetector.processImage(inputImage);
      debugPrint(
        '👤 Faces found: ${faces.length} | rotation: $rotation | size: ${image.width}x${image.height} | planes: ${image.planes.length}',
      );

      if (faces.isEmpty) return DetectionResult.noFace();

      final face = faces.reduce(
        (a, b) => a.boundingBox.width > b.boundingBox.width ? a : b,
      );

      if (face.boundingBox.width < 60 || face.boundingBox.height < 60) {
        return DetectionResult.noFace();
      }

      final ear = _calculateEAR(face);
      debugPrint('👁️ EAR: $ear');

      return DetectionResult(
        ear: ear,
        faceDetected: true,
        faceBox: face.boundingBox,
        leftEyeBox: _getEyeBox(face, true),
        rightEyeBox: _getEyeBox(face, false),
      );
    } catch (e) {
      debugPrint('💥 Detection error: $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  Rect? _getEyeBox(Face face, bool isLeft) {
    final contourType =
        isLeft ? FaceContourType.leftEye : FaceContourType.rightEye;
    final contour = face.contours[contourType];
    if (contour == null || contour.points.isEmpty) return null;

    final pts = contour.points;
    int minX = pts[0].x, maxX = pts[0].x;
    int minY = pts[0].y, maxY = pts[0].y;
    for (final p in pts) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }

    // Add padding around eye
    final pad = ((maxX - minX) * 0.3).toInt();
    return Rect.fromLTRB(
      (minX - pad).toDouble(),
      (minY - pad).toDouble(),
      (maxX + pad).toDouble(),
      (maxY + pad).toDouble(),
    );
  }

  InputImage? _convertToInputImage(
    CameraImage image,
    InputImageRotation rotation,
  ) {
    try {
      final int width = image.width;
      final int height = image.height;
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel!;

      final nv21 = Uint8List(width * height * 3 ~/ 2);

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          nv21[y * width + x] =
              image.planes[0].bytes[y * image.planes[0].bytesPerRow + x];
        }
      }

      int uvIndex = width * height;
      for (int y = 0; y < height ~/ 2; y++) {
        for (int x = 0; x < width ~/ 2; x++) {
          final int bufferIndex = y * uvRowStride + x * uvPixelStride;
          nv21[uvIndex++] = image.planes[2].bytes[bufferIndex];
          nv21[uvIndex++] = image.planes[1].bytes[bufferIndex];
        }
      }

      return InputImage.fromBytes(
        bytes: nv21,
        metadata: InputImageMetadata(
          size: Size(width.toDouble(), height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: width,
        ),
      );
    } catch (e) {
      debugPrint('Frame conversion error: $e');
      return null;
    }
  }

  double _calculateEAR(Face face) {
    final leftEAR = _eyeEAR(face, true);
    final rightEAR = _eyeEAR(face, false);

    if (leftEAR != null && rightEAR != null) {
      return (leftEAR + rightEAR) / 2.0;
    } else if (leftEAR != null) {
      return leftEAR;
    } else if (rightEAR != null) {
      return rightEAR;
    }

    final leftProb = face.leftEyeOpenProbability;
    final rightProb = face.rightEyeOpenProbability;

    if (leftProb != null && rightProb != null) {
      final avgProb = (leftProb + rightProb) / 2.0;
      return 0.10 + (avgProb * 0.28);
    }

    return -1.0;
  }

  double? _eyeEAR(Face face, bool isLeft) {
    final contourType =
        isLeft ? FaceContourType.leftEye : FaceContourType.rightEye;

    final contour = face.contours[contourType];
    if (contour == null || contour.points.length < 13) return null;

    final pts = contour.points;
    final p1 = pts[0];
    final p2 = pts[2];
    final p3 = pts[4];
    final p4 = pts[8];
    final p5 = pts[10];
    final p6 = pts[12];

    final A = _dist(p2, p6);
    final B = _dist(p3, p5);
    final C = _dist(p1, p4);

    if (C == 0) return null;
    return (A + B) / (2.0 * C);
  }

  double _dist(Point<int> a, Point<int> b) {
    final dx = (a.x - b.x).toDouble();
    final dy = (a.y - b.y).toDouble();
    return sqrt(dx * dx + dy * dy);
  }

  void dispose() {
    _faceDetector.close();
  }
}

class DetectionResult {
  final double ear;
  final bool faceDetected;
  final double cnnScore;
  final Rect? faceBox;
  final Rect? leftEyeBox;
  final Rect? rightEyeBox;

  DetectionResult({
    required this.ear,
    required this.faceDetected,
    this.cnnScore = -1.0,
    this.faceBox,
    this.leftEyeBox,
    this.rightEyeBox,
  });

  factory DetectionResult.noFace() => DetectionResult(
        ear: 0.0,
        faceDetected: false,
      );
}