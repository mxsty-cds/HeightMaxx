// lib/widgets/circular_value_slider.dart
//
// A purely custom radial slider mapping touch gestures to a circular track.
// Built without third-party packages to keep the app lightweight and heavily branded.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class CircularValueSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String unit;
  final bool isDecimal;

  const CircularValueSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.unit,
    this.isDecimal = false,
  });

  @override
  State<CircularValueSlider> createState() => _CircularValueSliderState();
}

class _CircularValueSliderState extends State<CircularValueSlider> {
  // 270 degree sweep. Starts at bottom left, goes over the top to bottom right.
  final double _startAngle = math.pi * 0.75;
  final double _sweepAngle = math.pi * 1.5;

  void _handlePan(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    
    // Calculate angle from center (-pi to pi)
    double angle = math.atan2(dy, dx);
    
    // Normalize angle to match our start angle
    double normalizedAngle = angle - _startAngle;
    if (normalizedAngle < 0) {
      normalizedAngle += 2 * math.pi;
    }

    // Clamp to our sweep arc
    double progress = normalizedAngle / _sweepAngle;
    progress = progress.clamp(0.0, 1.0);

    // If dragging near the gap at the bottom, determine closest edge
    if (normalizedAngle > _sweepAngle) {
      final gapMidpoint = _sweepAngle + ((2 * math.pi - _sweepAngle) / 2);
      progress = normalizedAngle < gapMidpoint ? 1.0 : 0.0;
    }

    final newValue = widget.min + (progress * (widget.max - widget.min));
    
    // Slight haptic on value change
    if ((newValue * 10).round() != (widget.value * 10).round()) {
      HapticFeedback.selectionClick();
    }
    
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = widget.isDecimal 
        ? widget.value.toStringAsFixed(1) 
        : widget.value.round().toString();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < 250 ? constraints.maxWidth : 250.0;
        
        return Center(
          child: GestureDetector(
            onPanUpdate: (details) => _handlePan(details.localPosition, Size(size, size)),
            onPanDown: (details) => _handlePan(details.localPosition, Size(size, size)),
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _RadialSliderPainter(
                  progress: (widget.value - widget.min) / (widget.max - widget.min),
                  startAngle: _startAngle,
                  sweepAngle: _sweepAngle,
                  trackColor: AppColors.subtleBackground,
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayValue,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2.0,
                          color: AppColors.textPrimary,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.unit.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}

class _RadialSliderPainter extends CustomPainter {
  final double progress;
  final double startAngle;
  final double sweepAngle;
  final Color trackColor;
  final Gradient gradient;

  _RadialSliderPainter({
    required this.progress,
    required this.startAngle,
    required this.sweepAngle,
    required this.trackColor,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 16;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw Background Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

    // Draw Active Gradient Track
    final activePaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, activePaint);

    // Draw Thumb
    final thumbAngle = startAngle + (sweepAngle * progress);
    final thumbCenter = Offset(
      center.dx + radius * math.cos(thumbAngle),
      center.dy + radius * math.sin(thumbAngle),
    );
    
    final thumbPaint = Paint()..color = AppColors.surface;
    final thumbShadowPaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
    canvas.drawCircle(thumbCenter, 18, thumbShadowPaint);
    canvas.drawCircle(thumbCenter, 16, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant _RadialSliderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}