import '../models/user.dart';
import '../models/xp_event.dart';
import '../models/unlocks.dart';

class XpEngine {
  
  /// Applies a specific XP event (e.g., stretching, completing a task) to the user.
  UserProfile applyEvent(UserProfile user, XpEvent event) {
    // Note: Optionally log 'event' to an analytics or history service here.
    
    // Update streak based on consecutive daily activity
    int newStreakDays = user.streakDays;
    DateTime today = DateTime.now();
    DateTime todayMidnight = DateTime(today.year, today.month, today.day);
    
    if (user.lastActiveDate == null) {
      // First activity ever
      newStreakDays = 1;
    } else {
      DateTime lastActiveMidnight = DateTime(
        user.lastActiveDate!.year,
        user.lastActiveDate!.month,
        user.lastActiveDate!.day,
      );
      
      final daysDifference = todayMidnight.difference(lastActiveMidnight).inDays;
      
      if (daysDifference == 0) {
        // Same day, streak continues unchanged
        newStreakDays = user.streakDays;
      } else if (daysDifference == 1) {
        // Next consecutive day, increment streak
        newStreakDays = user.streakDays + 1;
      } else {
        // Gap in activity, reset streak to 1
        newStreakDays = 1;
      }
    }
    
    UserProfile updatedUser = addXp(user, event.xpAmount);
    
    // Update with streak and last active date
    return updatedUser.copyWith(
      streakDays: newStreakDays,
      lastActiveDate: DateTime.now(),
    );
  }

  /// Adds raw XP, handles level-ups, carries over overflow XP, and grants unlocks.
  UserProfile addXp(UserProfile user, int amount) {
    if (amount <= 0) return user;

    int newXp = user.currentXp + amount;
    int newLevel = user.level;
    int newTargetXp = user.xpToNextLevel;
    
    List<String> newThemes = List.from(user.unlockedThemeIds);
    List<String> newAvatars = List.from(user.unlockedAvatarTierIds);
    List<String> newWorkouts = List.from(user.unlockedWorkoutTierIds);

    // Handle overflow XP across potentially multiple level-ups
    while (newXp >= newTargetXp) {
      newXp -= newTargetXp; 
      newLevel++;
      newTargetXp = _calculateXpRequiredForLevel(newLevel);
      
      // Check for and grant unlocks at this new level
      final unlocks = getUnlocksForLevel(newLevel);
      for (final reward in unlocks) {
        switch (reward.type) {
          case UnlockType.theme:
            if (!newThemes.contains(reward.id)) newThemes.add(reward.id);
            break;
          case UnlockType.avatarTier:
            if (!newAvatars.contains(reward.id)) newAvatars.add(reward.id);
            break;
          case UnlockType.workoutTier:
            if (!newWorkouts.contains(reward.id)) newWorkouts.add(reward.id);
            break;
        }
      }
    }

    return user.copyWith(
      level: newLevel,
      currentXp: newXp,
      xpToNextLevel: newTargetXp,
      totalXpEarned: user.totalXpEarned + amount,
      unlockedThemeIds: newThemes,
      unlockedAvatarTierIds: newAvatars,
      unlockedWorkoutTierIds: newWorkouts,
    );
  }

  /// Scalable XP curve formula.
  int _calculateXpRequiredForLevel(int level) {
    // Starts at 100 for level 1->2, increases by 60 each subsequent level.
    // e.g., Lvl 2: 160, Lvl 3: 220, Lvl 4: 280
    return 100 + ((level - 1) * 60);
  }

  /// Returns a hint about what the user will unlock next.
  UnlockableReward? getNextUnlockHint(int currentLevel) {
    // Find the closest reward that requires a level greater than the current
    try {
      return allRewards.where((r) => r.unlockLevel > currentLevel)
          .reduce((a, b) => a.unlockLevel < b.unlockLevel ? a : b);
    } catch (_) {
      return null; // No more rewards
    }
  }

  /// Returns all rewards granted precisely at a specific level.
  List<UnlockableReward> getUnlocksForLevel(int level) {
    return allRewards.where((r) => r.unlockLevel == level).toList();
  }

  // --- Mock Database of Rewards ---
  // Note: Move this to a remote config or database service.
  // Public so screens can reference reward definitions without duplicating them.
  static const List<UnlockableReward> allRewards = [
    UnlockableReward(id: 'thm_skyline', type: UnlockType.theme, name: 'Skyline Theme', description: 'A sleek, urban dark mode.', unlockLevel: 2),
    UnlockableReward(id: 'wrk_advanced_core', type: UnlockType.workoutTier, name: 'Advanced Core', description: 'Deep stabilization routines.', unlockLevel: 3),
    UnlockableReward(id: 'ava_tier_2', type: UnlockType.avatarTier, name: 'Silver Avatar Tier', description: 'Unlock new avatar accessories.', unlockLevel: 5),
  ];
}