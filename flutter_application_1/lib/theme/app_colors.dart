/// lib/theme/app_colors.dart
///
/// The centralized color system for the HeightMaxx app.
/// This palette is designed to be bright, minimal, and premium,
/// evoking a sense of calm motivation and vertical growth.
library;

import 'package:flutter/material.dart';

class AppColors {
  // Prevent instantiation. This class is a namespace for static constants only.
  AppColors._();

  // --- 1️⃣ Background Colors ---
  // A bright, airy foundation that lets content breathe.
  
  /// The main scaffold background. A very light, crisp off-white.
  static const Color background = Color(0xFFF8FAFC);
  
  /// The surface color for cards and elevated elements. Pure white for crisp contrast.
  static const Color surface = Color(0xFFFFFFFF);
  
  /// A slightly tinted background for separating sections without harsh lines.
  static const Color subtleBackground = Color(0xFFEFF3F8);

  // --- 2️⃣ Primary Accent ---
  // The core brand color representing energy, elevation, and progress.
  // We use a premium, modern "Elevation Blue".
  
  /// The main brand color used for primary buttons, active states, and highlights.
  static const Color accent = Color(0xFF4361EE);
  
  /// A lighter tint of the accent color, useful for soft backgrounds behind icons or badges.
  static const Color accentLight = Color(0xFFE0E7FF);
  
  /// A darker shade of the accent color, useful for pressed states or deep emphasis.
  static const Color accentDark = Color(0xFF2A3FB1);

  // --- 3️⃣ Text Colors ---
  // High legibility typography colors. Pure black is avoided to keep the UI soft and premium.
  
  /// Primary text color for headings and crucial body text. A deep, rich slate.
  static const Color textPrimary = Color(0xFF0F172A);
  
  /// Secondary text color for descriptions, subtitles, and less critical data.
  static const Color textSecondary = Color(0xFF64748B);
  
  /// Muted text color for placeholders, subtle labels, or disabled states.
  static const Color textMuted = Color(0xFF94A3B8);
  
  /// Text color specifically meant to be overlaid on top of the [accent] color.
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // --- 4️⃣ Status Colors ---
  // Semantic colors for feedback. Kept slightly desaturated to maintain the modern feel.
  
  /// Indicates successful completion of a mission or habit. (Modern Emerald)
  static const Color success = Color(0xFF10B981);
  
  /// Indicates a warning, such as a streak about to break. (Warm Amber)
  static const Color warning = Color(0xFFF59E0B);
  
  /// Indicates an error or destructive action. (Soft Red)
  static const Color error = Color(0xFFEF4444);

  // --- 5️⃣ Optional Gradient ---
  // An extremely soft, minimal vertical gradient to provide depth on larger screens 
  // like the welcome or onboarding flows, without distracting from the content.
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF), // Starts pure white
      Color(0xFFF1F5F9), // Gently fades into a soft slate-tinted background
    ],
  );
}