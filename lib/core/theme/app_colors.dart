import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand colors
  static const primary = Color(0xFF634E83);
  static const secondary = Color(0xFF625B71);
  static const error = Color(0xFFB3261E);

  // Background colors
  static const background = Color(0xFFEAEAEA);
  static const listBackground = Color(0xFFF5F5F5);

  // Gradient colors
  static const gradientStart = Color(0xB3634E83); // rgba(99,78,131,0.7)
  static const gradientEnd = Color(0xB3EAEAEA); // rgba(234,234,234,0.7)

  // Mini player bar
  static const miniPlayerActive = Color(0xCC634E83); // semi-transparent purple
  static const miniPlayerInactive = Color(0xFFD0D0D0);

  // Gradient definitions
  static const headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );

  static const miniPlayerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xCC634E83),
      Color(0xAA8B6FAF),
    ],
  );
}
