// lib/models/exercise.dart
//
// A scalable data model representing a single workout movement.

class Exercise {
  final String id;
  final String name;
  final int durationSeconds;
  /// The primary body area targeted (e.g., 'Spine', 'Core', 'Hips')
  final String bodyArea;
  /// Short description explaining the movement and its benefit
  final String description;

  const Exercise({
    required this.id,
    required this.name,
    this.durationSeconds = 30,
    this.bodyArea = 'Full Body',
    this.description = '',
  });
}