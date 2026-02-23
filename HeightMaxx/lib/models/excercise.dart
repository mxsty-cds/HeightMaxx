// lib/models/exercise.dart
//
// A simple, scalable data model representing a single workout movement.

class Exercise {
  final String id;
  final String name;
  final int durationSeconds;

  const Exercise({
    required this.id,
    required this.name,
    this.durationSeconds = 30, // Default duration
  });
}