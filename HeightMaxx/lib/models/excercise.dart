// lib/models/exercise.dart
//
// A scalable data model representing a single workout movement.

/// The type of animated visual guide shown during an exercise.
///
/// Each value maps to a distinct stick-figure animation in
/// [ExerciseAnimationView].  Add a new value here and handle it inside
/// `_ExercisePainter` to support a new visual.
///
/// TODO: When real Lottie assets are available, replace the custom-painter
/// switch-cases in exercise_animation_view.dart with Lottie.asset() calls
/// keyed on this enum.
enum ExerciseVisualType {
  hanging,
  cobraStretch,
  forwardBend,
  spineStretch,
  jumpTraining,
  /// Fallback for any exercise without a dedicated animation.
  generic,
}

class Exercise {
  final String id;
  final String name;
  final int durationSeconds;
  /// The primary body area targeted (e.g., 'Spine', 'Core', 'Hips')
  final String bodyArea;
  /// Short description explaining the movement and its benefit
  final String description;
  /// Selects the animated visual guide shown in [ExerciseAnimationView].
  final ExerciseVisualType visualType;

  const Exercise({
    required this.id,
    required this.name,
    this.durationSeconds = 30,
    this.bodyArea = 'Full Body',
    this.description = '',
    this.visualType = ExerciseVisualType.generic,
  });
}