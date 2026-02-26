// lib/utils/measurement_utils.dart
//
// Centralised helpers for converting and formatting height and weight.
// Canonical storage: height in centimetres (heightCm), weight in kilograms (weightKg).
// Default UI system: Imperial (feet + inches, pounds).

enum UnitSystem { imperial, metric }

class MeasurementUtils {
  // ---------------------------------------------------------------------------
  // Height helpers
  // ---------------------------------------------------------------------------

  /// Converts feet + inches to centimetres.
  static double feetInchesToCm(int feet, int inches) {
    return (feet * 12 + inches) * 2.54;
  }

  /// Splits centimetres into a (feet, inches) record.
  static ({int feet, int inches}) cmToFeetInches(double heightCm) {
    final roundedInches = (heightCm / 2.54).round();
    final feet = roundedInches ~/ 12;
    final inches = roundedInches % 12;
    return (feet: feet, inches: inches);
  }

  /// Returns a human-readable imperial height string, e.g. `5' 9"`.
  /// Returns `"--' --\""` when [heightCm] is null.
  static String formatHeight(double? heightCm) {
    if (heightCm == null) return "--' --\"";
    final parts = cmToFeetInches(heightCm);
    return "${parts.feet}' ${parts.inches}\"";
  }

  // ---------------------------------------------------------------------------
  // Weight helpers
  // ---------------------------------------------------------------------------

  /// Converts kilograms to pounds.
  static double kgToLbs(double kg) => kg * 2.20462;

  /// Converts pounds to kilograms.
  static double lbsToKg(double lbs) => lbs / 2.20462;

  /// Returns a human-readable imperial weight string, e.g. `"160 lb"`.
  /// Returns `"-- lb"` when [weightKg] is null.
  static String formatWeight(double? weightKg) {
    if (weightKg == null) return '-- lb';
    return '${kgToLbs(weightKg).round()} lb';
  }
}
