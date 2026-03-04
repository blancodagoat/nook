import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.dark(
        background: AppColors.bg,
        surface: AppColors.surface1,
        primary: AppColors.accent,
        secondary: AppColors.positive,
        error: AppColors.negative,
        onPrimary: Colors.white,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'SF Pro Display'),
        displayMedium: TextStyle(fontFamily: 'SF Pro Display'),
        displaySmall: TextStyle(fontFamily: 'SF Pro Display'),
        headlineLarge: TextStyle(fontFamily: 'SF Pro Display'),
        headlineMedium: TextStyle(fontFamily: 'SF Pro Display'),
        headlineSmall: TextStyle(fontFamily: 'SF Pro Display'),
        titleLarge: TextStyle(fontFamily: 'SF Pro Display'),
        titleMedium: TextStyle(fontFamily: 'SF Pro Text'),
        titleSmall: TextStyle(fontFamily: 'SF Pro Text'),
        bodyLarge: TextStyle(fontFamily: 'SF Pro Text'),
        bodyMedium: TextStyle(fontFamily: 'SF Pro Text'),
        bodySmall: TextStyle(fontFamily: 'SF Pro Text'),
        labelLarge: TextStyle(fontFamily: 'SF Pro Text'),
        labelMedium: TextStyle(fontFamily: 'SF Pro Text'),
        labelSmall: TextStyle(fontFamily: 'SF Pro Text'),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
      cupertinoOverrideTheme: MaterialBasedCupertinoThemeData(
        materialTheme: ThemeData.dark(),
      ),
    );
  }

  static void setSystemUIOverlayStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
}
