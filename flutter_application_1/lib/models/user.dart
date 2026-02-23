/// lib/models/user.dart
///
/// The core user progression model for HeightMaxx.
/// Designed as an immutable data class to integrate cleanly with modern
/// Flutter state management solutions (BLoC, Riverpod, etc.).
library;

class UserProfile {
  final String id;
  final String displayName;
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final int streakDays;
  final DateTime? lastActiveDate;
  final int totalXpEarned;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.level = 1,
    this.currentXp = 0,
    this.xpToNextLevel = 150, // Default based on formula: 100 + (1 * 50)
    this.streakDays = 0,
    this.lastActiveDate,
    this.totalXpEarned = 0,
  });

  // --- GETTERS ---

  /// Returns a normalized value between 0.0 and 1.0 representing level progress.
  /// Perfect for driving a LinearProgressIndicator or CircularProgressIndicator.
  double get progressToNextLevel {
    if (xpToNextLevel <= 0) return 0.0;
    return (currentXp / xpToNextLevel).clamp(0.0, 1.0);
  }

  // --- BUSINESS LOGIC ---

  /// Adds XP, handles leveling up, and carries over remaining XP.
  /// Returns a new updated instance of UserProfile.
  UserProfile addXp(int amount) {
    if (amount <= 0) return this;

    int newXp = currentXp + amount;
    int newLevel = level;
    int newTargetXp = xpToNextLevel;

    // Use a while loop to handle massive XP gains that span multiple levels
    while (newXp >= newTargetXp) {
      newXp -= newTargetXp; // Carry over overflow XP
      newLevel++;
      newTargetXp = _calculateXpForLevel(newLevel);
    }

    return copyWith(
      level: newLevel,
      currentXp: newXp,
      xpToNextLevel: newTargetXp,
      totalXpEarned: totalXpEarned + amount,
    );
  }

  /// Increments the daily streak safely.
  /// Injects [now] as a parameter to keep the function pure and testable.
  UserProfile incrementStreak(DateTime now) {
    if (lastActiveDate == null) {
      // First time activity
      return copyWith(
        streakDays: 1,
        lastActiveDate: now,
      );
    }

    final lastActiveDateOnly = DateTime(lastActiveDate!.year, lastActiveDate!.month, lastActiveDate!.day);
    final nowDateOnly = DateTime(now.year, now.month, now.day);
    final difference = nowDateOnly.difference(lastActiveDateOnly).inDays;

    if (difference == 0) {
      // Already active today, no changes needed
      return this;
    } else if (difference == 1) {
      // Consecutive day, increment streak
      return copyWith(
        streakDays: streakDays + 1,
        lastActiveDate: now,
      );
    } else {
      // Streak broken, start fresh at 1
      return copyWith(
        streakDays: 1,
        lastActiveDate: now,
      );
    }
  }

  /// Resets the user's streak to zero.
  UserProfile resetStreak() {
    return copyWith(streakDays: 0);
  }

  /// Centralized formula for calculating the XP required for a specific level.
  /// Formula: 100 + (level * 50)
  static int _calculateXpForLevel(int targetLevel) {
    return 100 + (targetLevel * 50);
  }

  // --- IMMUTABILITY & SERIALIZATION ---

  UserProfile copyWith({
    String? id,
    String? displayName,
    int? level,
    int? currentXp,
    int? xpToNextLevel,
    int? streakDays,
    DateTime? lastActiveDate,
    int? totalXpEarned,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'level': level,
      'currentXp': currentXp,
      'xpToNextLevel': xpToNextLevel,
      'streakDays': streakDays,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'totalXpEarned': totalXpEarned,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      level: json['level'] as int? ?? 1,
      currentXp: json['currentXp'] as int? ?? 0,
      xpToNextLevel: json['xpToNextLevel'] as int? ?? 150,
      streakDays: json['streakDays'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null 
          ? DateTime.parse(json['lastActiveDate'] as String) 
          : null,
      totalXpEarned: json['totalXpEarned'] as int? ?? 0,
    );
  }
}