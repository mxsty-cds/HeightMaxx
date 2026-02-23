/// lib/models/growth_profile.dart
///
/// Calculates derived metrics (BMI, posture risk, stretch intensity) 
/// based on the user's raw biometric data.
/// NOTE: This provides structural guidance, not medical advice.
library;

import 'user_factors.dart';

class GrowthProfile {
  final int age;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;
  final PostureLevel postureLevel;

  const GrowthProfile({
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.postureLevel,
  });

  /// Standard Body Mass Index calculation.
  double get bmi {
    if (heightCm <= 0) return 0.0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Estimates the general phase of skeletal development.
  /// Used to tailor expectations (e.g., active growth vs. spinal decompression).
  String get estimatedGrowthWindow {
    if (age < 18) return 'Active Growth Phase';
    if (age < 22) return 'Late Growth / Consolidation Phase';
    return 'Maintenance & Posture Optimization Phase';
  }

  /// Calculates a basic posture risk score (1-10) based on habits.
  /// 10 = High Risk, 1 = Low Risk.
  int get postureRiskScore {
    int score = 5; // Baseline
    
    // Sedentary lifestyle increases risk
    if (activityLevel == ActivityLevel.sedentary) score += 3;
    if (activityLevel == ActivityLevel.high) score -= 2;

    // Self-reported posture
    if (postureLevel == PostureLevel.poor) score += 3;
    if (postureLevel == PostureLevel.good) score -= 3;

    return score.clamp(1, 10);
  }

  /// Determines the recommended intensity for daily mobility missions.
  String get recommendedStretchTier {
    if (postureRiskScore >= 8 || activityLevel == ActivityLevel.sedentary) {
      return 'Gentle / Restorative';
    } else if (postureRiskScore <= 4 && activityLevel == ActivityLevel.high) {
      return 'Advanced / Deep Mobility';
    }
    return 'Standard / Alignment';
  }
}