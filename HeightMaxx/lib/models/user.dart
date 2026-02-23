// lib/models/user.dart
//
// Extended UserProfile integrating biometric data, habit tracking,
// gamification, and the new distinct identity fields (username/nickname).

import 'user_factors.dart';
import 'growth_profile.dart';

class UserProfile {
  // Identity Fields
  final String id;
  final String username;
  final String nickname;
  
  // Gamification Fields
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final int streakDays;
  final DateTime? lastActiveDate;
  final int totalXpEarned;
  final List<String> unlockedThemeIds;
  final List<String> unlockedAvatarTierIds;
  final List<String> unlockedWorkoutTierIds;

  // Biometric & Habit Fields
  final int? age;
  final Sex? sex;
  final double? heightCm;
  final double? weightKg;
  final ActivityLevel? activityLevel;
  final SleepQuality? sleepQuality;
  final HydrationLevel? hydrationLevel;
  final PostureLevel? postureLevel;
  final GrowthGoal? growthGoal;
  final DateTime? profileCreatedAt;

  const UserProfile({
    required this.id,
    required this.username,
    required this.nickname,
    this.level = 1,
    this.currentXp = 0,
    this.xpToNextLevel = 100,
    this.streakDays = 0,
    this.lastActiveDate,
    this.totalXpEarned = 0,
    this.unlockedThemeIds = const [],
    this.unlockedAvatarTierIds = const [],
    this.unlockedWorkoutTierIds = const [],
    // Biometrics
    this.age,
    this.sex,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.sleepQuality,
    this.hydrationLevel,
    this.postureLevel,
    this.growthGoal,
    this.profileCreatedAt,
  });

  /// Hook to calculate derived metrics if sufficient biometric data exists.
  GrowthProfile? get growthProfile {
    if (age != null && heightCm != null && weightKg != null && 
        activityLevel != null && postureLevel != null) {
      return GrowthProfile(
        age: age!,
        heightCm: heightCm!,
        weightKg: weightKg!,
        activityLevel: activityLevel!,
        postureLevel: postureLevel!,
      );
    }
    return null;
  }

  /// Checks if the user has completed the onboarding profile setup.
  bool get hasCompletedProfile => age != null && heightCm != null && growthGoal != null;

  double get progressToNextLevel {
    if (xpToNextLevel <= 0) return 0.0;
    return (currentXp / xpToNextLevel).clamp(0.0, 1.0);
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? nickname,
    int? level,
    int? currentXp,
    int? xpToNextLevel,
    int? streakDays,
    DateTime? lastActiveDate,
    int? totalXpEarned,
    List<String>? unlockedThemeIds,
    List<String>? unlockedAvatarTierIds,
    List<String>? unlockedWorkoutTierIds,
    int? age,
    Sex? sex,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    SleepQuality? sleepQuality,
    HydrationLevel? hydrationLevel,
    PostureLevel? postureLevel,
    GrowthGoal? growthGoal,
    DateTime? profileCreatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      unlockedThemeIds: unlockedThemeIds ?? this.unlockedThemeIds,
      unlockedAvatarTierIds: unlockedAvatarTierIds ?? this.unlockedAvatarTierIds,
      unlockedWorkoutTierIds: unlockedWorkoutTierIds ?? this.unlockedWorkoutTierIds,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      hydrationLevel: hydrationLevel ?? this.hydrationLevel,
      postureLevel: postureLevel ?? this.postureLevel,
      growthGoal: growthGoal ?? this.growthGoal,
      profileCreatedAt: profileCreatedAt ?? this.profileCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'level': level,
      'currentXp': currentXp,
      'xpToNextLevel': xpToNextLevel,
      'streakDays': streakDays,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'totalXpEarned': totalXpEarned,
      'unlockedThemeIds': unlockedThemeIds,
      'unlockedAvatarTierIds': unlockedAvatarTierIds,
      'unlockedWorkoutTierIds': unlockedWorkoutTierIds,
      'age': age,
      'sex': sex?.name,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel?.name,
      'sleepQuality': sleepQuality?.name,
      'hydrationLevel': hydrationLevel?.name,
      'postureLevel': postureLevel?.name,
      'growthGoal': growthGoal?.name,
      'profileCreatedAt': profileCreatedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String? ?? 'user_000',
      nickname: json['nickname'] as String? ?? 'SkyStretcher',
      level: json['level'] as int? ?? 1,
      currentXp: json['currentXp'] as int? ?? 0,
      xpToNextLevel: json['xpToNextLevel'] as int? ?? 100,
      streakDays: json['streakDays'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null ? DateTime.parse(json['lastActiveDate'] as String) : null,
      totalXpEarned: json['totalXpEarned'] as int? ?? 0,
      unlockedThemeIds: List<String>.from(json['unlockedThemeIds'] ?? []),
      unlockedAvatarTierIds: List<String>.from(json['unlockedAvatarTierIds'] ?? []),
      unlockedWorkoutTierIds: List<String>.from(json['unlockedWorkoutTierIds'] ?? []),
      age: json['age'] as int?,
      sex: Sex.values.byNameOrNull(json['sex'] as String?),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      activityLevel: ActivityLevel.values.byNameOrNull(json['activityLevel'] as String?),
      sleepQuality: SleepQuality.values.byNameOrNull(json['sleepQuality'] as String?),
      hydrationLevel: HydrationLevel.values.byNameOrNull(json['hydrationLevel'] as String?),
      postureLevel: PostureLevel.values.byNameOrNull(json['postureLevel'] as String?),
      growthGoal: GrowthGoal.values.byNameOrNull(json['growthGoal'] as String?),
      profileCreatedAt: json['profileCreatedAt'] != null ? DateTime.parse(json['profileCreatedAt'] as String) : null,
    );
  }
}