/// lib/widgets/vertical_progress.dart
///
/// A reusable, animated vertical progress bar for HeightMaxx.
/// Visually communicates the user's "vertical progression" towards their next
/// level or goal, featuring smooth easing animations and a premium aesthetic.
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class VerticalProgressBar extends StatelessWidget {
  const VerticalProgressBar({
    super.key,
    required this.progress,
    this.height = 160.0,
    this.width = 24.0,
    this.showLabel = true,
    this.label,
  });

  /// Progress value between 0.0 and 1.0.
  /// Values outside this range will be safely clamped internally.
  final double progress;

  /// Total height of the progress bar track.
  final double height;

  /// Total width (thickness) of the progress bar track.
  final double width;

  /// Whether to show a text label below the bar.
  final bool showLabel;

  /// Optional custom label (e.g., "Level 4").
  /// If null and [showLabel] is true, it defaults to a percentage string.
  final String? label;

  @override
  Widget build(BuildContext context) {
    // Safely clamp progress between 0% and 100% to prevent rendering errors
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBar(context, clampedProgress),
        if (showLabel) ...[
          const SizedBox(height: 12),
          _buildLabel(context, clampedProgress),
        ],
      ],
    );
  }

  /// Builds the animated vertical track and fill.
  Widget _buildBar(BuildContext context, double clampedProgress) {
    final borderRadius = BorderRadius.circular(width / 2);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Track background: A subtle, low-contrast color
        // Fallback if AppColors.background isn't strictly defined as needed:
        // color: Colors.grey.withOpacity(0.1),
        color: AppColors.background,
        borderRadius: borderRadius,
        boxShadow: [
          // Soft outer drop shadow for a premium floating effect
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Clip to ensure the fill doesn't bleed outside the rounded corners
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // The animated fill portion
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            width: width,
            height: height * clampedProgress,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              // Gradient to create a subtle glow/highlight near the top of the fill
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.accentSecondary,
                  // Lighter shade at the top to simulate an upward glow
                  // Fallback: Colors.greenAccent
                  Color.lerp(AppColors.accentPrimary, Colors.white, 0.15) ??
                      AppColors.accentPrimary,
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildTopHighlight(),
            ),
          ),
        ],
      ),
    );
  }

  /// Adds a tiny "glass" pill highlight at the top of the fill area
  /// to make the fluid look more alive and premium.
  Widget _buildTopHighlight() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      width: width * 0.5,
      height: width * 0.15,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.35 * 255).round()),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// Builds the label displayed beneath the progress bar.
  Widget _buildLabel(BuildContext context, double clampedProgress) {
    final int percent = (clampedProgress * 100).round();
    final String displayLabel = label ?? '$percent%';

    return Text(
      displayLabel,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        // Fallback: Colors.grey[600]
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}
