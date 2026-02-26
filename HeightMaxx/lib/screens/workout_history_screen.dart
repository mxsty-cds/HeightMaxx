// lib/screens/workout_history_screen.dart
//
// Displays the user's completed workout sessions.
// Currently shows a structured placeholder list derived from user stats.
// TODO: Replace with real per-session history fetched from Firestore.

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  final UserProfile? user;

  const WorkoutHistoryScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final int totalWorkouts = user?.totalWorkoutsCompleted ?? 0;
    // TODO: Load real session list from Firestore WorkoutSession collection.
    // For now, generate a deterministic placeholder list from totalWorkouts.
    final List<_WorkoutEntry> entries = _buildPlaceholderHistory(totalWorkouts);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Workout History',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: totalWorkouts == 0
          ? _buildEmptyState()
          : Column(
              children: [
                _buildSummaryBanner(totalWorkouts),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _WorkoutHistoryCard(entry: entries[index]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryBanner(int totalWorkouts) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.accentPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.accentPrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center_rounded,
              color: AppColors.accentPrimary, size: 24),
          const SizedBox(width: 12),
          Text(
            '$totalWorkouts total sessions completed',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fitness_center_outlined,
              size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'No workouts yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Complete your first session to see it here.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Builds a deterministic placeholder list from [totalWorkouts].
  /// TODO: Remove this and load real session data from Firestore.
  static const int _maxPlaceholderEntries = 20;

  List<_WorkoutEntry> _buildPlaceholderHistory(int totalWorkouts) {
    const sessionTypes = [
      'Spine Decompression',
      'Posture Alignment',
      'Core Stability',
      'Mobility Flow',
      'Stretch & Breathe',
    ];
    const durations = [20, 25, 30, 20, 15];

    final now = DateTime.now();
    final count = totalWorkouts.clamp(0, _maxPlaceholderEntries);
    return List.generate(count, (i) {
      final daysAgo = i * 1; // one session per day as approximation
      final date = now.subtract(Duration(days: daysAgo));
      return _WorkoutEntry(
        name: sessionTypes[i % sessionTypes.length],
        durationMinutes: durations[i % durations.length],
        xpEarned: 50 + (i % 3) * 25,
        date: date,
      );
    });
  }
}

class _WorkoutEntry {
  final String name;
  final int durationMinutes;
  final int xpEarned;
  final DateTime date;

  const _WorkoutEntry({
    required this.name,
    required this.durationMinutes,
    required this.xpEarned,
    required this.date,
  });
}

class _WorkoutHistoryCard extends StatelessWidget {
  final _WorkoutEntry entry;

  const _WorkoutHistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${entry.date.day}/${entry.date.month}/${entry.date.year}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fitness_center_rounded,
                color: AppColors.accentPrimary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.durationMinutes} min  •  $dateLabel',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+${entry.xpEarned} XP',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
