import 'package:flutter/material.dart';

class AppColors {
  static Color bg(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color card(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color subText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF8E8E93)
          : const Color(0xFF8E8E93);

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3A3A3C)
          : const Color(0xFFE5E5EA);

  static const primary = Color(0xFFFF9500);
  static const green = Color(0xFF30D158);
  static const red = Color(0xFFFF453A);
}