/// lib/models/user_factors.dart
///
/// Structured enums for biometric data and user habits.
/// Provides safe serialization and deserialization methods.
library;

/// lib/models/user_factors.dart
///
/// Refined biometric and habit enums tailored for HeightMaxx's 
/// precise onboarding flow.

enum Sex { male, female }

enum LifestyleLevel { easy, medium, athlete }

enum PrimaryGoal { heightmaxx, posturemaxx, both }

enum ActivityLevel { sedentary, moderate, high }

enum SleepQuality { poor, average, good }

enum HydrationLevel { low, medium, high }

enum PostureLevel { poor, average, good }

enum GrowthGoal { heightmaxx, posturemaxx, both }

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

/// Helper extension to properly format enum names for the UI.
extension EnumNaming on Enum {
  String get formattedName {
    // Specifically handle the stylized "Maxx" capitalization
    if (name.toLowerCase() == 'heightmaxx') return 'HeightMaxx';
    if (name.toLowerCase() == 'posturemaxx') return 'Posturemaxx';
    // Capitalize first letter for standard options
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }
}