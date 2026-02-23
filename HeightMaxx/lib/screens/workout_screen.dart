// lib/screens/workout_screen.dart
//
// Features animated list cards with glowing accents upon opening.

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(child: _buildAnimatedList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Workout', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1.0, color: AppColors.textPrimary)),
          SizedBox(height: 8),
          Text('List of exercises', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAnimatedList() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          itemCount: _routine.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            // Slight stagger effect using math
            final delayOffset = (index * 0.1).clamp(0.0, 1.0);
            final itemOpacity = ((value - delayOffset) / (1 - delayOffset)).clamp(0.0, 1.0);
            
            return Opacity(
              opacity: itemOpacity,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - itemOpacity)),
                child: _buildExerciseCard(context, _routine[index], index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.accentSecondary.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.accentPrimary.withValues(alpha: 0.1),
          highlightColor: AppColors.accentPrimary.withValues(alpha: 0.05),
          onTap: () => _openPlayer(context, index),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Glowing accent dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [BoxShadow(color: AppColors.accentGlow, blurRadius: 6)],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(exercise.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ),
                Text(
                  '${exercise.durationSeconds}s',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.accentSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}