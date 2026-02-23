// lib/widgets/premium_stepper.dart
//
// A premium, high-contrast numeric stepper designed to replace generic sliders.
// Forces intentional interaction and provides a highly polished, tactile feel.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class PremiumStepper extends StatelessWidget {
  const PremiumStepper({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    this.unit = '',
  });

  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;
  final String unit;

  void _decrement() {
    if (value > minValue) {
      HapticFeedback.lightImpact();
      onChanged(value - 1);
    }
  }

  void _increment() {
    if (value < maxValue) {
      HapticFeedback.lightImpact();
      onChanged(value + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canDecrement = value > minValue;
    final bool canIncrement = value < maxValue;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Decrement Button
          _buildControlButton(
            icon: Icons.remove_rounded,
            isEnabled: canDecrement,
            onTap: _decrement,
          ),
          
          // Massive Numeric Display
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2.0,
                  color: AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  unit.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
          
          // Increment Button
          _buildControlButton(
            icon: Icons.add_rounded,
            isEnabled: canIncrement,
            onTap: _increment,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isEnabled ? AppColors.subtleBackground : AppColors.background,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        customBorder: const CircleBorder(),
        splashColor: AppColors.accentPrimary.withValues(alpha: 0.1),
        highlightColor: AppColors.accentPrimary.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Icon(
            icon,
            size: 28,
            color: isEnabled
                ? AppColors.accentPrimary
                : AppColors.textMuted.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}