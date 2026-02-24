import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise.dart';
import '../theme/app_colors.dart';
import 'workout_player_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  static const List<Exercise> _routine = [
    Exercise(id: 'e1', name: 'Hanging exercise', durationSeconds: 30),
    Exercise(id: 'e2', name: 'Cobra stretch', durationSeconds: 45),
    Exercise(id: 'e3', name: 'Forward bend', durationSeconds: 30),
    Exercise(id: 'e4', name: 'Spine stretch', durationSeconds: 60),
    Exercise(id: 'e5', name: 'Jump training', durationSeconds: 40),
  ];

  void _openPlayer(BuildContext context, int initialIndex) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutPlayerScreen(exercises: _routine, initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverHeader(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                sliver: _buildAnimatedSliverList(),
              ),
            ],
          ),
          _buildStickyStartButton(context),
        ],
      ),
    );
  }

  // --- 1. ПРЕМИАЛЬНАЯ ШАПКА ---
  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 240,
      collapsedHeight: 80,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accentPrimary.withValues(alpha: 0.05), AppColors.background],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daily\nRoutine', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.1)),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStatChip(Icons.timer_outlined, '~4 min'),
                  const SizedBox(width: 12),
                  _buildStatChip(Icons.bolt_rounded, '120 XP'),
                  const SizedBox(width: 12),
                  _buildStatChip(Icons.fitness_center_rounded, 'Medium'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.subtleBackground),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.accentSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // --- 2. УЛУЧШЕННЫЙ СПИСОК С АНИМАЦИЕЙ ---
  Widget _buildAnimatedSliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildExerciseCard(context, _routine[index], index),
                  ),
                ),
              );
            },
          );
        },
        childCount: _routine.length,
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _openPlayer(context, index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Иконка упражнения в Bento-стиле
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.subtleBackground,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Icon(
                      index == 4 ? Icons.bolt_rounded : Icons.accessibility_new_rounded,
                      color: AppColors.accentPrimary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(
                        index < 3 ? 'Posture Focus' : 'Growth Boost',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                // Индикатор времени
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${exercise.durationSeconds}s',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.accentPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 3. ГЛАВНАЯ КНОПКА ЗАПУСКА ---
  Widget _buildStickyStartButton(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 24,
      right: 24,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPrimary.withValues(alpha: 0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _openPlayer(context, 0),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.play_arrow_rounded, size: 28),
              SizedBox(width: 10),
              Text('START ROUTINE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}