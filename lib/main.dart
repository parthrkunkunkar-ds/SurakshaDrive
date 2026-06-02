import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('darkMode') ?? false;
  runApp(SurakshaDriveApp(isDark: isDark));
}

class SurakshaDriveApp extends StatefulWidget {
  final bool isDark;
  const SurakshaDriveApp({super.key, required this.isDark});

  static _SurakshaDriveAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SurakshaDriveAppState>();

  @override
  State<SurakshaDriveApp> createState() => _SurakshaDriveAppState();
}

class _SurakshaDriveAppState extends State<SurakshaDriveApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  void toggleTheme(bool val) async {
    setState(() => _isDark = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', val);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SurakshaDrive',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFF9500),
          secondary: Color(0xFF30D158),
          surface: Color(0xFFFFFFFF),
          error: Color(0xFFFF453A),
        ),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF9500),
          secondary: Color(0xFF30D158),
          surface: Color(0xFF2C2C2E),
          error: Color(0xFFFF453A),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}