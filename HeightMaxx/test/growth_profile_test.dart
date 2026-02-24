import 'package:flutter_test/flutter_test.dart';
import 'package:heightmaxx/models/growth_profile.dart';
import 'package:heightmaxx/models/user_factors.dart';

void main() {
  group('GrowthProfile.postureRiskScore', () {
    test('returns high risk for sedentary + poor posture', () {
      const profile = GrowthProfile(
        age: 18,
        heightCm: 175,
        weightKg: 70,
        activityLevel: ActivityLevel.sedentary,
        postureLevel: PostureLevel.poor,
      );

      expect(profile.postureRiskScore, 10);
      expect(profile.recommendedStretchTier, 'Gentle / Restorative');
    });

    test('returns low risk for high activity + good posture', () {
      const profile = GrowthProfile(
        age: 21,
        heightCm: 180,
        weightKg: 72,
        activityLevel: ActivityLevel.high,
        postureLevel: PostureLevel.good,
      );

      expect(profile.postureRiskScore, 1);
      expect(profile.recommendedStretchTier, 'Advanced / Deep Mobility');
    });

    test('returns standard tier for moderate profile', () {
      const profile = GrowthProfile(
        age: 25,
        heightCm: 170,
        weightKg: 65,
        activityLevel: ActivityLevel.moderate,
        postureLevel: PostureLevel.average,
      );

      expect(profile.postureRiskScore, 5);
      expect(profile.recommendedStretchTier, 'Standard / Alignment');
    });
  });
}
