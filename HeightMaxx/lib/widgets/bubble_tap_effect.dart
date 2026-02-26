// lib/widgets/bubble_tap_effect.dart
//
// Reusable "bubble press" effect widget.
// Wraps any child and shows expanding translucent circles on tap,
// matching the app's primary cyan/blue palette.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Wraps [child] with a bubble-press animation on tap.
///
/// On [onTap], one or more concentric circles radiate out from the tap point
/// with decreasing opacity, then fade. The effect is clipped to [borderRadius].
///
/// Example:
/// ```dart
/// BubbleTapEffect(
///   onTap: () => doSomething(),
///   borderRadius: BorderRadius.circular(AppTheme.radiusMD),
///   child: MyButtonContent(),
/// )
/// ```
///
/// To customise the look, adjust [maxRadius], [duration], or [color]:
/// ```dart
/// BubbleTapEffect(
///   onTap: onPressed,
///   maxRadius: 80,
///   duration: Duration(milliseconds: 250),
///   color: AppColors.accentSecondary,
///   child: child,
/// )
/// ```
class BubbleTapEffect extends StatefulWidget {
  final Widget child;

  /// Called when the user taps the widget.
  final VoidCallback? onTap;

  /// Optional passthrough of the raw [TapDownDetails] (e.g. for outer scale
  /// animations in parent widgets like [GradientButton]).
  final GestureTapDownCallback? onTapDown;

  /// Optional passthrough of the raw [TapUpDetails].
  final GestureTapUpCallback? onTapUp;

  /// Optional passthrough of tap-cancel events.
  final VoidCallback? onTapCancel;

  /// The maximum radius the outer bubble expands to.
  /// Defaults to [AppTheme.bubbleMaxRadius].
  final double maxRadius;

  /// Total duration of the bubble animation.
  /// Defaults to [AppTheme.bubbleDuration].
  final Duration duration;

  /// Fill colour for the bubbles. Opacity is applied internally.
  /// Defaults to [AppColors.accentPrimary].
  final Color color;

  /// Clips the effect to this shape. Should match the button's own border radius.
  /// Defaults to [AppTheme.radiusMD] on all corners.
  final BorderRadius borderRadius;

  const BubbleTapEffect({
    super.key,
    required this.child,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.maxRadius = AppTheme.bubbleMaxRadius,
    this.duration = AppTheme.bubbleDuration,
    this.color = AppColors.accentPrimary,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppTheme.radiusMD),
    ),
  });

  @override
  State<BubbleTapEffect> createState() => _BubbleTapEffectState();
}

class _BubbleTapEffectState extends State<BubbleTapEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Reset so the painter stops drawing after the animation ends.
          if (mounted) setState(() => _tapPosition = null);
          _controller.reset();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      // Capture position and kick off bubble animation.
      setState(() => _tapPosition = details.localPosition);
      _controller.forward(from: 0);
    }
    widget.onTapDown?.call(details);
  }

  void _handleTapUp(TapUpDetails details) {
    widget.onTapUp?.call(details);
  }

  void _handleTapCancel() {
    widget.onTapCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => CustomPaint(
              foregroundPainter: _tapPosition != null
                  ? BubblePainter(
                      progress: _controller.value,
                      tapPosition: _tapPosition!,
                      maxRadius: widget.maxRadius,
                      color: widget.color,
                    )
                  : null,
              child: child,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// [CustomPainter] that draws the expanding bubble rings.
///
/// Exposed publicly so it can be reused by widgets (e.g. [GradientButton])
/// that manage their own [GestureDetector] but still want bubble visuals.
class BubblePainter extends CustomPainter {
  final double progress;
  final Offset tapPosition;
  final double maxRadius;
  final Color color;

  const BubblePainter({
    required this.progress,
    required this.tapPosition,
    required this.maxRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final eased = Curves.easeOut.transform(progress);

    // Outer bubble: large, low opacity.
    _drawCircle(canvas, maxRadius * eased, (1.0 - eased) * 0.22);
    // Inner bubble: smaller, slightly more opaque, adds depth.
    _drawCircle(canvas, maxRadius * 0.55 * eased, (1.0 - eased) * 0.16);
  }

  void _drawCircle(Canvas canvas, double radius, double opacity) {
    if (opacity <= 0 || radius <= 0) return;
    canvas.drawCircle(
      tapPosition,
      radius,
      Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(BubblePainter old) =>
      old.progress != progress || old.tapPosition != tapPosition;
}
