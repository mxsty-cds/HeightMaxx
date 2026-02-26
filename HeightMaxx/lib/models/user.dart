import 'user_factors.dart';
import 'growth_profile.dart';

// 1. ВОТ ЭТО РАСШИРЕНИЕ ИСПРАВЛЯЕТ ВСЕ ОШИБКИ ИЗ ТВОЕГО СКРИНА!
// Оно безопасно превращает строки из Firebase обратно в твои Enum-ы.
extension EnumByNameOrNull<T extends Enum> on Iterable<T> {
  T? byNameOrNull(String? name) {
    if (name == null) return null;
    for (var value in this) {
      if (value.name == name) return value;
    }
    return null;
  }
}

class UserProfile {
  // --- Identity Fields ---
  final String id;
  final String fullName;
  final String username;
  final String nickname;

  // --- Gamification Fields ---
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final int streakDays;
  final DateTime? lastActiveDate;
  final int totalXpEarned;
  final double? totalGrowthCm;
  final int? totalWorkoutsCompleted;
  final List<String> unlockedThemeIds;
  final List<String> unlockedAvatarTierIds;
  final List<String> unlockedWorkoutTierIds;
  final String? avatarPath;

  // --- Biometric & Habit Fields ---
  final int? age;
  final Sex? sex;
  final double? heightCm;
  final double? weightKg;
  final ActivityLevel? activityLevel;
  final SleepQuality? sleepQuality;
  final HydrationLevel? hydrationLevel;
  final PostureLevel? postureLevel;
  final GrowthGoal? growthGoal;
  final String? workoutFocus;
  final int? workoutDaysPerWeek;
  final int? workoutMinutesPerSession;
  final DateTime? profileCreatedAt;

  const UserProfile({
    required this.id,
    this.fullName = 'Mover',
    required this.username,
    required this.nickname,
    this.level = 1,
    this.currentXp = 0,
    this.xpToNextLevel = 100,
    this.streakDays = 0,
    this.lastActiveDate,
    this.totalXpEarned = 0,
    this.totalGrowthCm,
    this.totalWorkoutsCompleted,
    this.unlockedThemeIds = const [],
    this.unlockedAvatarTierIds = const [],
    this.unlockedWorkoutTierIds = const [],
    this.age,
    this.sex,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.sleepQuality,
    this.hydrationLevel,
    this.postureLevel,
    this.growthGoal,
    this.workoutFocus,
    this.workoutDaysPerWeek,
    this.workoutMinutesPerSession,
    this.profileCreatedAt,
    this.avatarPath,
  });

  /// Вычисляет профиль роста
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

  /// Проверяет, заполнил ли юзер все данные
  bool get hasCompletedProfile =>
      age != null && heightCm != null && growthGoal != null;

  double get progressToNextLevel {
    if (xpToNextLevel <= 0) return 0.0;
    return (currentXp / xpToNextLevel).clamp(0.0, 1.0);
  }

  /// Returns streak only if user was active today or yesterday.
  /// Prevents stale Firebase values from showing incorrect streak counts.
  int get effectiveStreakDays {
    if (lastActiveDate == null) return 0;
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final lastMidnight = DateTime(
      lastActiveDate!.year, lastActiveDate!.month, lastActiveDate!.day,
    );
    final daysDiff = todayMidnight.difference(lastMidnight).inDays;
    // Streak is valid if user was active today or yesterday
    return daysDiff <= 1 ? streakDays : 0;
  }

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? username,
    String? nickname,
    int? level,
    int? currentXp,
    int? xpToNextLevel,
    int? streakDays,
    DateTime? lastActiveDate,
    int? totalXpEarned,
    double? totalGrowthCm,
    int? totalWorkoutsCompleted,
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
    String? workoutFocus,
    int? workoutDaysPerWeek,
    int? workoutMinutesPerSession,
    DateTime? profileCreatedAt,
    String? avatarPath,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      totalGrowthCm: totalGrowthCm ?? this.totalGrowthCm,
      totalWorkoutsCompleted: totalWorkoutsCompleted ??
          this.totalWorkoutsCompleted,
      unlockedThemeIds: unlockedThemeIds ?? this.unlockedThemeIds,
      unlockedAvatarTierIds: unlockedAvatarTierIds ??
          this.unlockedAvatarTierIds,
      unlockedWorkoutTierIds: unlockedWorkoutTierIds ??
          this.unlockedWorkoutTierIds,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      hydrationLevel: hydrationLevel ?? this.hydrationLevel,
      postureLevel: postureLevel ?? this.postureLevel,
      growthGoal: growthGoal ?? this.growthGoal,
      workoutFocus: workoutFocus ?? this.workoutFocus,
      workoutDaysPerWeek: workoutDaysPerWeek ?? this.workoutDaysPerWeek,
      workoutMinutesPerSession: workoutMinutesPerSession ??
          this.workoutMinutesPerSession,
      profileCreatedAt: profileCreatedAt ?? this.profileCreatedAt,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  // 2. Метод toJson для отправки в Firebase Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'nickname': nickname,
      'level': level,
      'currentXp': currentXp,
      'xpToNextLevel': xpToNextLevel,
      'streakDays': streakDays,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'totalXpEarned': totalXpEarned,
      'totalGrowthCm': totalGrowthCm,
      'totalWorkoutsCompleted': totalWorkoutsCompleted,
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
      'workoutFocus': workoutFocus,
      'workoutDaysPerWeek': workoutDaysPerWeek,
      'workoutMinutesPerSession': workoutMinutesPerSession,
      'profileCreatedAt': profileCreatedAt?.toIso8601String(),
      'avatarPath': avatarPath,
    };
  }

  // 3. Метод fromJson для получения данных из Firebase Firestore
  // 3. Метод fromJson для получения данных из Firebase Firestore
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? 'Mover',
      username: json['username'] as String? ?? 'user_000',
      nickname: json['nickname'] as String? ?? 'SkyStretcher',
      level: json['level'] as int? ?? 1,
      currentXp: json['currentXp'] as int? ?? 0,
      xpToNextLevel: json['xpToNextLevel'] as int? ?? 100,
      streakDays: json['streakDays'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null ? DateTime.parse(
          json['lastActiveDate'] as String) : null,
      totalXpEarned: json['totalXpEarned'] as int? ?? 0,
      totalGrowthCm: (json['totalGrowthCm'] as num?)?.toDouble(),
      totalWorkoutsCompleted: json['totalWorkoutsCompleted'] as int?,
      unlockedThemeIds: List<String>.from(json['unlockedThemeIds'] ?? []),
      unlockedAvatarTierIds: List<String>.from(
          json['unlockedAvatarTierIds'] ?? []),
      unlockedWorkoutTierIds: List<String>.from(
          json['unlockedWorkoutTierIds'] ?? []),
      age: json['age'] as int?,

      // ИСПОЛЬЗУЕМ ВСТРОЕННЫЙ МЕТОД asNameMap() - НИКАКИХ ОШИБОК!
      sex: Sex.values.asNameMap()[json['sex']],
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      activityLevel: ActivityLevel.values.asNameMap()[json['activityLevel']],
      sleepQuality: SleepQuality.values.asNameMap()[json['sleepQuality']],
      hydrationLevel: HydrationLevel.values.asNameMap()[json['hydrationLevel']],
      postureLevel: PostureLevel.values.asNameMap()[json['postureLevel']],
      growthGoal: GrowthGoal.values.asNameMap()[json['growthGoal']],

      workoutFocus: json['workoutFocus'] as String?,
      workoutDaysPerWeek: json['workoutDaysPerWeek'] as int?,
      workoutMinutesPerSession: json['workoutMinutesPerSession'] as int?,
      profileCreatedAt: json['profileCreatedAt'] != null ? DateTime.parse(
          json['profileCreatedAt'] as String) : null,
      avatarPath: json['avatarPath'] as String?,
    );
  }
}