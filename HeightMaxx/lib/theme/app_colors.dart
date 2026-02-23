// lib/theme/app_colors.dart
//
// Refined color palette extracted directly from the HeightMaxx brand icon.
// Features glowing cyan, deep aquatic blue, and ultra-clean cool surfaces.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  // --- Background & Surface ---
  /// A very light, cool-tinted off-white to make white cards pop.
  static const Color background = Color(0xFFF0F4F8);
  /// Pure white for elevated cards and sheets.
  static const Color surface = Color(0xFFFFFFFF);
  /// Subtle divider or inactive track color.
  static const Color subtleBackground = Color(0xFFE2E8F0);

  // --- Brand Accents (From Icon) ---
  /// The glowing, energetic cyan from the center of the icon.
  static const Color accentPrimary = Color(0xFF00E5FF);
  /// The deep, rich blue from the outer edges of the icon.
  static const Color accentSecondary = Color(0xFF005BB5);
  /// A soft, translucent cyan for glowing drop shadows.
  static const Color accentGlow = Color(0x4D00E5FF);

  // --- Typography ---
  /// Deep, rich navy for high-contrast primary text.
  static const Color textPrimary = Color(0xFF0A192F);
  /// Cool slate gray for secondary labels and descriptions.
  static const Color textSecondary = Color(0xFF64748B);
  /// Light gray for placeholders or disabled text.
  static const Color textMuted = Color(0xFF94A3B8);

  // --- Status ---
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color error = Color(0xFFEF4444);   // Rose

  // --- Brand Gradients ---
  /// Replicates the vertical, glowing gradient of the app icon.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [accentSecondary, accentPrimary],
  );
}