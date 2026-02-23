class UserProfile {
  final String id;
  final String displayName;
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final int streakDays;
  final DateTime? lastActiveDate;
  final int totalXpEarned;
  
  // --- New Gamification Fields ---
  final List<String> unlockedThemeIds;
  final List<String> unlockedAvatarTierIds;
  final List<String> unlockedWorkoutTierIds;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.level = 1,
    this.currentXp = 0,
    this.xpToNextLevel = 100, 
    this.streakDays = 0,
    this.lastActiveDate,
    this.totalXpEarned = 0,
    this.unlockedThemeIds = const [],
    this.unlockedAvatarTierIds = const [],
    this.unlockedWorkoutTierIds = const [],
  });

  /// Returns a normalized value between 0.0 and 1.0 representing level progress.
  double get progressToNextLevel {
    if (xpToNextLevel <= 0) return 0.0;
    return (currentXp / xpToNextLevel).clamp(0.0, 1.0);
  }

  // Note: Complex level-up and XP logic has been migrated to XpEngine 
  // to maintain pure data-class semantics here.

  UserProfile copyWith({
    String? id,
    String? displayName,
    int? level,
    int? currentXp,
    int? xpToNextLevel,
    int? streakDays,
    DateTime? lastActiveDate,
    int? totalXpEarned,
    List<String>? unlockedThemeIds,
    List<String>? unlockedAvatarTierIds,
    List<String>? unlockedWorkoutTierIds,
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
      unlockedThemeIds: unlockedThemeIds ?? this.unlockedThemeIds,
      unlockedAvatarTierIds: unlockedAvatarTierIds ?? this.unlockedAvatarTierIds,
      unlockedWorkoutTierIds: unlockedWorkoutTierIds ?? this.unlockedWorkoutTierIds,
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
      'unlockedThemeIds': unlockedThemeIds,
      'unlockedAvatarTierIds': unlockedAvatarTierIds,
      'unlockedWorkoutTierIds': unlockedWorkoutTierIds,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      level: json['level'] as int? ?? 1,
      currentXp: json['currentXp'] as int? ?? 0,
      xpToNextLevel: json['xpToNextLevel'] as int? ?? 100,
      streakDays: json['streakDays'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null 
          ? DateTime.parse(json['lastActiveDate'] as String) 
          : null,
      totalXpEarned: json['totalXpEarned'] as int? ?? 0,
      unlockedThemeIds: List<String>.from(json['unlockedThemeIds'] ?? []),
      unlockedAvatarTierIds: List<String>.from(json['unlockedAvatarTierIds'] ?? []),
      unlockedWorkoutTierIds: List<String>.from(json['unlockedWorkoutTierIds'] ?? []),
    );
  }
}