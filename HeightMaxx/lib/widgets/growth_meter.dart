import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GrowthMeter extends StatelessWidget {
  const GrowthMeter({
    super.key,
    required this.progress,
    this.height = 180.0,
    this.width = 32.0,
  });

  /// Normalized progress between 0.0 and 1.0
  final double progress;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final borderRadius = BorderRadius.circular(8.0); // Slightly sharper, like a building

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.subtleBackground,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Animated Skyscraper Fill
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0, end: clampedProgress),
            builder: (context, value, child) {
              return Container(
                width: width,
                height: height * value,
                decoration: const BoxDecoration(
                  color: AppColors.accentPrimary,
                ),
                child: _buildSkyscraperSegments(height * value),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Draws horizontal "floor" lines inside the active fill area 
  /// to create the skyscraper aesthetic.
  Widget _buildSkyscraperSegments(double currentHeight) {
    // Distance between "floors"
    const double floorHeight = 12.0; 
    final int floorCount = (currentHeight / floorHeight).floor();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(floorCount, (index) {
        return Container(
          height: 1.0, // Floor divider thickness
          width: width * 0.7, // Windows don't touch the exact edges
          margin: const EdgeInsets.only(bottom: floorHeight - 1.0),
          color: Colors.white.withAlpha((0.3 * 255).round()),
        );
      }),
    );
  }
}