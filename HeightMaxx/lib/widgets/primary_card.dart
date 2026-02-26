// lib/widgets/primary_card.dart
//
// Reusable rounded card with soft shadow — the standard surface container
// for stats, insights, exercise items, and other content blocks.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class PrimaryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double elevation;

  const PrimaryCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spaceMD),
    this.borderRadius = AppTheme.radiusLG,
    this.color,
    this.gradient,
    this.onTap,
    this.elevation = 8,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.surface;

    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? effectiveColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentSecondary.withValues(alpha: 0.06),
            blurRadius: elevation,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: child,
                ),
              ),
            )
          : Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
    );
  }
}
