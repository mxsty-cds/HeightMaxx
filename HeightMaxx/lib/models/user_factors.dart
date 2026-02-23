/// lib/models/user_factors.dart
///
/// Structured enums for biometric data and user habits.
/// Provides safe serialization and deserialization methods.
library;

enum Sex { male, female, other }

enum ActivityLevel { sedentary, light, moderate, high }

enum SleepQuality { poor, average, good }

enum HydrationLevel { low, moderate, high }

enum PostureLevel { poor, average, good }

enum GrowthGoal { maximizeHeight, improvePosture, both }

/// Extension to easily convert enums to/from JSON strings.
extension EnumByName<T extends Enum> on Iterable<T> {
  T? byNameOrNull(String? name) {
    if (name == null) return null;
    for (var value in this) {
      if (value.name == name) return value;
    }
    return null;
  }
}