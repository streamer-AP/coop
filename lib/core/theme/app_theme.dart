import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static String get _appChineseFontFamily =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? 'PingFang SC'
          : 'SourceHanSansCN';

  static const _chineseFontFallback = [
    'PingFang HK',
    'PingFang TC',
    'SourceHanSansCN',
    'Source Han Sans SC',
    'Source Han Sans CN',
    'Noto Sans CJK SC',
    'Noto Sans SC',
    'sans-serif',
  ];

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.background,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: _appChineseFontFamily,
      colorScheme: colorScheme.copyWith(primary: AppColors.primary),
      scaffoldBackgroundColor: AppColors.background,
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: _appChineseFontFamily,
        fontFamilyFallback: _chineseFontFallback,
      ),
      primaryTextTheme: ThemeData.light().primaryTextTheme.apply(
        fontFamily: _appChineseFontFamily,
        fontFamilyFallback: _chineseFontFallback,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: const Color(0xFF000000),
          fontSize: 18,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.8,
          fontFamily: _appChineseFontFamily,
          fontFamilyFallback: _chineseFontFallback,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF000000)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: const Color(0xFF79747E),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerHeight: 0,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: _appChineseFontFamily,
          fontFamilyFallback: _chineseFontFallback,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: _appChineseFontFamily,
          fontFamilyFallback: _chineseFontFallback,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _appChineseFontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: _appChineseFontFamily,
        fontFamilyFallback: _chineseFontFallback,
      ),
      primaryTextTheme: ThemeData.dark().primaryTextTheme.apply(
        fontFamily: _appChineseFontFamily,
        fontFamilyFallback: _chineseFontFallback,
      ),
    );
  }
}
