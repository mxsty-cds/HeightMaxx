// lib/utils/leaderboard_utils.dart
//
// Utilities for scoring, ranking, and generating mock competitors
// for the HeightMaxx leaderboard.

import 'dart:math';
import '../models/user.dart'; 

class LeaderboardUtils {
  static final Random _random = Random();

  /// Calculates the total competitive score for a user.
  /// Formula: (Total Growth cm * 100) + (Streak Days * 10) + (Total Workouts * 5)
  static int calculateScore(double totalGrowthCm, int streakDays, int totalWorkouts) {
    int growthScore = (totalGrowthCm * 100).toInt();
    int streakScore = streakDays * 10;
    int workoutScore = totalWorkouts * 5;
    return growthScore + streakScore + workoutScore;
  }

  /// Evaluates a UserProfile to extract their competitive score.
  /// (Assumes totalGrowthCm and totalWorkoutsCompleted exist on UserProfile)
  static int getScoreForUser(UserProfile user) {
    // Fallbacks provided in case these fields are newly added to the model
    final growth = user.totalGrowthCm ?? 0.0;
    final workouts = user.totalWorkoutsCompleted ?? 0;
    return calculateScore(growth, user.streakDays, workouts);
  }

  /// Generates realistic bot users to populate the leaderboard.
  static List<UserProfile> generateBotUsers(int count) {
    final List<String> adjectives = ['Apex', 'Sky', 'Tall', 'Zen', 'Aero', 'Giant', 'Prime', 'Pro'];
    final List<String> nouns = ['Stretcher', 'Mover', 'Walker', 'Jumper', 'Posture', 'Titan', 'Spine'];
    
    return List.generate(count, (index) {
      final String botName = '${adjectives[_random.nextInt(adjectives.length)]}${nouns[_random.nextInt(nouns.length)]}${_random.nextInt(99)}';
      
      // Generate realistic bell-curve-ish stats
      final double botGrowth = (_random.nextDouble() * 5.0).clamp(0.0, 5.0); // 0 to 5 cm
      final int botStreak = _random.nextInt(45); // 0 to 45 days
      final int botWorkouts = _random.nextInt(120); // 0 to 120 workouts

      return UserProfile(
        id: 'bot_$index',
        username: botName.toLowerCase(),
        nickname: botName,
        streakDays: botStreak,
        totalGrowthCm: botGrowth, // *Ensure this exists in your UserProfile*
        totalWorkoutsCompleted: botWorkouts, // *Ensure this exists in your UserProfile*
        // Fills remaining required fields with dummy data
        level: (_random.nextInt(10) + 1),
      );
    });
  }
}