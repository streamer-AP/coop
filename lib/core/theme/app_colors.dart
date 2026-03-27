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
  static const gradientStart = Color(0xFF786B9E); // Figma 选歌页顶部
  static const gradientEnd = Color(0xFFB8A8D0); // Figma 选歌页底部

  // Tab bar
  static const tabBarBg = Color(0xFF2C2C2E);
  static const tabBarActive = Color(0xFFFFFFFF);
  static const tabBarInactiveIcon = Color(0xFF8E8E93);

  // Card
  static const cardBg = Color(0xFFFFFFFF);
  static const cardBgTranslucent = Color(0xE6FFFFFF);

  // Text
  static const textPrimary = Color(0xFF1C1B1F);
  static const textSecondary = Color(0xFF79747E);
  static const textHint = Color(0xFFAEAEB2);

  // Unread dot
  static const unreadDot = Color(0xFFFF3B30);

  // Verification
  static const success = Color(0xFF34C759);

  // Mini player bar
  static const miniPlayerActive = Color(0xCC634E83); // semi-transparent purple
  static const miniPlayerInactive = Color(0xFFD0D0D0);

  // Gradient definitions
  static const headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );

  static const homeBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF3A2D5C),
      Color(0xFF5C4A7A),
      Color(0xFFB8A9D4),
      Color(0xFFD5CCE6),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const profileBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF3A2D5C),
      Color(0xFF8B7AAF),
      Color(0xFFD5CCE6),
    ],
    stops: [0.0, 0.4, 1.0],
  );

  static const purpleButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF7B61A0),
      Color(0xFF9B85C0),
    ],
  );
}
