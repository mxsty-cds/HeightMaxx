/// lib/models/task.dart
///
/// The core task/mission model for HeightMaxx.
/// Designed immutably to integrate perfectly with BLoC, Riverpod, or Provider,
/// ensuring UI state remains predictable and testable.
library;

class HeightTask {
  final String id;
  final String title;
  final String? description;
  final int xpReward;
  final bool isCompleted;
  final String category;
  final int? estimatedMinutes;
  final DateTime? scheduledFor;
  final DateTime? completedAt;

  const HeightTask({
    required this.id,
    required this.title,
    this.description,
    required this.xpReward,
    this.isCompleted = false,
    required this.category,
    this.estimatedMinutes,
    this.scheduledFor,
    this.completedAt,
  });

  // --- GETTERS ---

  /// Checks if the task is scheduled for the current calendar day.
  bool get isScheduledToday {
    if (scheduledFor == null) return false;
    final now = DateTime.now();
    return scheduledFor!.year == now.year &&
        scheduledFor!.month == now.month &&
        scheduledFor!.day == now.day;
  }

  /// Checks if the task is past its scheduled date and remains incomplete.
  bool get isOverdue {
    if (isCompleted || scheduledFor == null) return false;
    return scheduledFor!.isBefore(DateTime.now());
  }

  // --- BUSINESS LOGIC ---

  /// Marks the task as complete and records the timestamp.
  /// Returns a new updated instance of [HeightTask].
  HeightTask complete({DateTime? at}) {
    return copyWith(
      isCompleted: true,
      completedAt: at ?? DateTime.now(),
    );
  }

  /// Resets the task to an incomplete state.
  /// Returns a new instance with the completion data cleared.
  HeightTask resetCompletion() {
    // We instantiate directly here rather than using copyWith, 
    // to explicitly force [completedAt] to null.
    return HeightTask(
      id: id,
      title: title,
      description: description,
      xpReward: xpReward,
      isCompleted: false,
      category: category,
      estimatedMinutes: estimatedMinutes,
      scheduledFor: scheduledFor,
      completedAt: null, 
    );
  }

  // --- IMMUTABILITY & SERIALIZATION ---

  HeightTask copyWith({
    String? id,
    String? title,
    String? description,
    int? xpReward,
    bool? isCompleted,
    String? category,
    int? estimatedMinutes,
    DateTime? scheduledFor,
    DateTime? completedAt,
  }) {
    return HeightTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'xpReward': xpReward,
      'isCompleted': isCompleted,
      'category': category,
      'estimatedMinutes': estimatedMinutes,
      'scheduledFor': scheduledFor?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory HeightTask.fromJson(Map<String, dynamic> json) {
    return HeightTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      xpReward: json['xpReward'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      category: json['category'] as String? ?? 'general',
      estimatedMinutes: json['estimatedMinutes'] as int?,
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.parse(json['scheduledFor'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}