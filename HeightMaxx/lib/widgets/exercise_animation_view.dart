// lib/widgets/exercise_animation_view.dart
//
// Animated stick-figure guide shown while the workout timer runs.
//
// Each [ExerciseVisualType] value maps to a dedicated [CustomPainter] that
// uses trigonometric oscillation to simulate the exercise motion.
//
// Note: Replace the custom-painter branches with Lottie.asset() calls once
// real animation files are available.  Drop *.json files into
// assets/animations/ (register the folder in pubspec.yaml), then swap out
// the `CustomPaint` widget for:
//
//   Lottie.asset(
//     'assets/animations/${exercise.visualType.name}.json',
//     controller: animationController,
//     fit: BoxFit.contain,
//   )

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../theme/app_colors.dart';

/// Displays a looping stick-figure animation that illustrates [exercise].
///
/// Pass a repeating [AnimationController] via [animation] so the figure moves
/// continuously while the timer is running.  Pause the controller when the
/// workout is paused and the figure will freeze in place.
class ExerciseAnimationView extends StatelessWidget {
  final Exercise exercise;
  final Animation<double> animation;

  const ExerciseAnimationView({
    super.key,
    required this.exercise,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => CustomPaint(
        size: const Size(150, 150),
        painter: _ExercisePainter(
          type: exercise.visualType,
          t: animation.value,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private CustomPainter — one paint method per ExerciseVisualType
// ---------------------------------------------------------------------------

class _ExercisePainter extends CustomPainter {
  final ExerciseVisualType type;
  final double t; // 0.0–1.0 looping value from AnimationController

  const _ExercisePainter({required this.type, required this.t});

  double get _angle => t * 2 * math.pi;

  // --- Shared paint styles -------------------------------------------------

  Paint get _linePaint => Paint()
    ..color = AppColors.textPrimary
    ..strokeWidth = 3.5
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  Paint get _accentLinePaint => Paint()
    ..color = AppColors.accentPrimary.withValues(alpha: 0.7)
    ..strokeWidth = 2.5
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  Paint get _headFillPaint => Paint()
    ..color = AppColors.textPrimary
    ..style = PaintingStyle.fill;

  // --- Shared helpers ------------------------------------------------------

  void _drawHead(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, _headFillPaint);
  }

  void _drawGroundLine(Canvas canvas, double cx, double groundY) {
    canvas.drawLine(
      Offset(cx - 60, groundY),
      Offset(cx + 60, groundY),
      _accentLinePaint,
    );
  }

  // --- Router --------------------------------------------------------------

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case ExerciseVisualType.hanging:
        _drawHanging(canvas, size);
      case ExerciseVisualType.cobraStretch:
        _drawCobra(canvas, size);
      case ExerciseVisualType.forwardBend:
        _drawForwardBend(canvas, size);
      case ExerciseVisualType.spineStretch:
        _drawSpineStretch(canvas, size);
      case ExerciseVisualType.jumpTraining:
        _drawJump(canvas, size);
      case ExerciseVisualType.generic:
        _drawGeneric(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_ExercisePainter old) => old.t != t || old.type != type;

  // =========================================================================
  // 1. Hanging exercise — figure hangs from a bar and sways side-to-side
  // =========================================================================
  void _drawHanging(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final sway = math.sin(_angle) * 7.0;

    // Overhead bar
    final barPaint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 50, 14), Offset(cx + 50, 14), barPaint);

    final bx = cx + sway;

    // Arms: bar → shoulders
    canvas.drawLine(Offset(bx - 18, 14), Offset(bx - 13, 44), _linePaint);
    canvas.drawLine(Offset(bx + 18, 14), Offset(bx + 13, 44), _linePaint);

    // Head (sits between the arms)
    _drawHead(canvas, Offset(bx, 33), 10);

    // Torso: shoulders → hips
    canvas.drawLine(Offset(bx, 44), Offset(bx, 85), _linePaint);

    // Legs with light knee-sway
    final kSway = math.sin(_angle + 1.0) * 5.0;
    canvas.drawLine(Offset(bx, 85), Offset(bx - 11 + kSway, 108), _linePaint);
    canvas.drawLine(
        Offset(bx - 11 + kSway, 108), Offset(bx - 7, 130), _linePaint);
    canvas.drawLine(Offset(bx, 85), Offset(bx + 11 - kSway, 108), _linePaint);
    canvas.drawLine(
        Offset(bx + 11 - kSway, 108), Offset(bx + 7, 130), _linePaint);
  }

  // =========================================================================
  // 2. Cobra stretch — upper body arches up from the floor and relaxes
  // =========================================================================
  void _drawCobra(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height - 18.0;

    _drawGroundLine(canvas, cx, groundY);

    // Arch oscillates between a shallow angle and a tall arch
    final archProgress = (math.sin(_angle) + 1) / 2; // 0..1
    final spineAngle =
        math.pi * 0.12 + archProgress * math.pi * 0.38; // ~22° → ~90°

    // Flat lower body / legs to the right
    canvas.drawLine(
        Offset(cx + 12, groundY - 5), Offset(cx + 62, groundY - 5), _linePaint);

    // Hip anchor
    final hipX = cx + 12.0;
    final hipY = groundY - 5.0;

    // Spine arches upward from hips
    const spineLen = 46.0;
    final shoulderX = hipX - spineLen * math.cos(spineAngle);
    final shoulderY = hipY - spineLen * math.sin(spineAngle);
    canvas.drawLine(Offset(hipX, hipY), Offset(shoulderX, shoulderY), _linePaint);

    // Head
    final hAngle = spineAngle + 0.3;
    _drawHead(canvas,
        Offset(shoulderX - 11 * math.cos(hAngle), shoulderY - 11 * math.sin(hAngle)),
        10);

    // Supporting arms down to the floor
    canvas.drawLine(Offset(shoulderX, shoulderY + 4),
        Offset(shoulderX - 16, groundY - 5), _linePaint);
    canvas.drawLine(Offset(shoulderX, shoulderY + 4),
        Offset(shoulderX + 8, groundY - 5), _linePaint);
  }

  // =========================================================================
  // 3. Forward bend — figure bends from upright to a deep forward fold
  // =========================================================================
  void _drawForwardBend(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height - 18.0;

    _drawGroundLine(canvas, cx, groundY);

    // 0 = upright, 1 = deep forward bend
    final bendProgress = (math.sin(_angle) + 1) / 2;

    // Straight legs
    final hipY = groundY - 52.0;
    canvas.drawLine(Offset(cx - 10, groundY - 4), Offset(cx - 10, hipY), _linePaint);
    canvas.drawLine(Offset(cx + 10, groundY - 4), Offset(cx + 10, hipY), _linePaint);

    // Spine: pivots from vertical (angle=π/2) toward horizontal
    const spineLen = 46.0;
    final spineAngle =
        math.pi / 2 * (1 - bendProgress * 0.88); // π/2 → ~π/10
    final shoulderX = cx + spineLen * math.cos(spineAngle);
    final shoulderY = hipY - spineLen * math.sin(spineAngle);
    canvas.drawLine(Offset(cx, hipY), Offset(shoulderX, shoulderY), _linePaint);

    // Head continues along the spine direction
    final headX = shoulderX + 13 * math.cos(spineAngle);
    final headY = shoulderY - 13 * math.sin(spineAngle);
    _drawHead(canvas, Offset(headX, headY), 10);

    // Arms hang down (lower when bent more)
    final armDropExtra = 22 * (1 - math.sin(spineAngle));
    canvas.drawLine(
        Offset(shoulderX, shoulderY + 8),
        Offset(shoulderX - 7, shoulderY + 28 + armDropExtra),
        _linePaint);
    canvas.drawLine(
        Offset(shoulderX, shoulderY + 8),
        Offset(shoulderX + 7, shoulderY + 28 + armDropExtra),
        _linePaint);
  }

  // =========================================================================
  // 4. Spine stretch (seated) — seated figure reaches arms forward and back
  // =========================================================================
  void _drawSpineStretch(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height - 18.0;

    _drawGroundLine(canvas, cx, groundY);

    // 0 = arms at rest, 1 = full reach
    final reach = (math.sin(_angle) + 1) / 2;

    // Seated legs extended forward (to the right)
    canvas.drawLine(
        Offset(cx - 18, groundY - 8), Offset(cx + 55, groundY - 8), _linePaint);

    // Hip anchor
    final hipX = cx - 14.0;
    final hipY = groundY - 8.0;

    // Torso leans slightly forward as arms reach
    final leanAngle = math.pi / 2 - reach * 0.28;
    const torsoLen = 46.0;
    final shoulderX = hipX + torsoLen * math.cos(leanAngle);
    final shoulderY = hipY - torsoLen * math.sin(leanAngle);
    canvas.drawLine(Offset(hipX, hipY), Offset(shoulderX, shoulderY), _linePaint);

    // Head
    _drawHead(canvas, Offset(shoulderX + 3, shoulderY - 12), 10);

    // Arms reach toward the feet
    final armTarget = hipX + 22 + reach * 40;
    canvas.drawLine(Offset(shoulderX, shoulderY + 8),
        Offset(armTarget, groundY - 14), _linePaint);
    canvas.drawLine(Offset(shoulderX, shoulderY + 8),
        Offset(armTarget + 6, groundY - 6), _linePaint);
  }

  // =========================================================================
  // 5. Jump training — figure bounces up and down with spread arms/legs
  // =========================================================================
  void _drawJump(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height - 18.0;

    _drawGroundLine(canvas, cx, groundY);

    // Jump height: abs(sin) gives a bouncing arc, clamped for style
    final jumpHeight = math.pow(math.sin(_angle).abs(), 0.55).toDouble() * 32.0;
    final inAir = jumpHeight > 4;

    // Hip Y: standing hip is groundY - legLen from ground
    const legLen = 44.0;
    const torsoLen = 36.0;
    const headR = 10.0;

    final hipY = groundY - legLen - jumpHeight;
    final shoulderY = hipY - torsoLen;

    // Torso
    canvas.drawLine(Offset(cx, hipY), Offset(cx, shoulderY), _linePaint);

    // Head
    _drawHead(canvas, Offset(cx, shoulderY - headR - 1), headR);

    // Arms: spread in the air, relaxed on the ground
    final armSpread = inAir ? 28.0 : 14.0;
    final armDrop = inAir ? -4.0 : 14.0;
    canvas.drawLine(Offset(cx, shoulderY + 10),
        Offset(cx - armSpread, shoulderY + 10 + armDrop), _linePaint);
    canvas.drawLine(Offset(cx, shoulderY + 10),
        Offset(cx + armSpread, shoulderY + 10 + armDrop), _linePaint);

    // Legs
    final legSpread = inAir ? 12.0 : 6.0;
    final kneeSpread = legSpread * 0.7;
    final kneeY = hipY + legLen * 0.5;
    final footY = inAir ? hipY + legLen : groundY - 4;

    canvas.drawLine(Offset(cx, hipY), Offset(cx - kneeSpread, kneeY), _linePaint);
    canvas.drawLine(
        Offset(cx - kneeSpread, kneeY), Offset(cx - legSpread, footY), _linePaint);
    canvas.drawLine(Offset(cx, hipY), Offset(cx + kneeSpread, kneeY), _linePaint);
    canvas.drawLine(
        Offset(cx + kneeSpread, kneeY), Offset(cx + legSpread, footY), _linePaint);
  }

  // =========================================================================
  // 6. Generic — standing figure with gentle breathing / swaying motion
  // =========================================================================
  void _drawGeneric(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height - 18.0;

    _drawGroundLine(canvas, cx, groundY);

    final breathe = math.sin(_angle * 0.8) * 2.5;
    final sway = math.sin(_angle * 0.5) * 3.0;
    final bx = cx + sway;

    // Head
    _drawHead(canvas, Offset(bx, groundY - 106 - breathe), 11);

    // Torso: neck to hip
    canvas.drawLine(Offset(bx, groundY - 95 - breathe),
        Offset(bx, groundY - 52), _linePaint);

    // Arms swing gently
    final armA = 0.2 + math.sin(_angle) * 0.18;
    canvas.drawLine(
        Offset(bx, groundY - 82),
        Offset(bx - 26 * math.cos(armA), groundY - 82 + 30 * math.sin(armA)),
        _linePaint);
    canvas.drawLine(
        Offset(bx, groundY - 82),
        Offset(bx + 26 * math.cos(armA), groundY - 82 + 30 * math.sin(armA)),
        _linePaint);

    // Legs
    canvas.drawLine(
        Offset(bx, groundY - 52), Offset(bx - 11, groundY - 28), _linePaint);
    canvas.drawLine(
        Offset(bx - 11, groundY - 28), Offset(bx - 13, groundY - 4), _linePaint);
    canvas.drawLine(
        Offset(bx, groundY - 52), Offset(bx + 11, groundY - 28), _linePaint);
    canvas.drawLine(
        Offset(bx + 11, groundY - 28), Offset(bx + 13, groundY - 4), _linePaint);
  }
}
