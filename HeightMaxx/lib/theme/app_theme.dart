// lib/theme/app_theme.dart
//
// Central design system for HeightMaxx.
// Wire this into MaterialApp.theme to get consistent styling everywhere.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ─── Spacing constants ───────────────────────────────────────────────────
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // ─── Border radii ────────────────────────────────────────────────────────
  static const double radiusSM = 8.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 24.0;
  static const double radiusXL = 32.0;

  // ─── Text styles ─────────────────────────────────────────────────────────
  static const TextStyle headline1 = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.5,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textMuted,
    height: 1.3,
  );

  static const TextStyle labelButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  // ─── Full ThemeData ───────────────────────────────────────────────────────
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.accentPrimary,
        primaryContainer: AppColors.accentSecondary,
        secondary: AppColors.accentSecondary,
        secondaryContainer: AppColors.accentGlow,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: AppColors.textPrimary,
        ),
        centerTitle: false,
      ),

      // ── Cards ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: labelButton,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLG,
            vertical: spaceMD,
          ),
        ),
      ),

      // ── Text Button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          side: const BorderSide(color: AppColors.accentPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),

      // ── Input / TextField ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.subtleBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMD,
          vertical: spaceMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(
            color: AppColors.accentPrimary,
            width: 1.5,
          ),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accentPrimary,
        unselectedItemColor: AppColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ── Progress Indicators ───────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentPrimary,
        linearTrackColor: AppColors.subtleBackground,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.subtleBackground,
        thickness: 1,
        space: 1,
      ),

      // ── Typography ────────────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: headline1,
        displayMedium: headline2,
        headlineLarge: headline2,
        headlineMedium: headline3,
        titleLarge: subtitle1,
        titleMedium: subtitle2,
        bodyLarge: bodyText1,
        bodyMedium: bodyText2,
        labelLarge: labelButton,
        bodySmall: caption,
        labelSmall: caption,
      ),
    );
  }
}
