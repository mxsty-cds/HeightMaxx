// lib/screens/home_screen.dart
//
// Dashboard updated with a premium card-based layout, glowing accents,
// and an implicitly animated progress bar.

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';
import 'workout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.user, this.onStartWorkout});

  final UserProfile? user;
  final VoidCallback? onStartWorkout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock Data
  final double _currentHeight = 175.0;
  final double _goalHeight = 180.0;
  final String _workoutName = "Stretching routine";
  final String _dailyTip = "Sleep 8–9 hours for optimal growth hormone";

  String get _displayName {
    final nickname = widget.user?.nickname.trim() ?? '';
    if (nickname.isNotEmpty) {
      return nickname;
    }
    final fullName = widget.user?.fullName.trim() ?? '';
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return 'Mover';
  }

  String get _progressText {
    final isFirstTimeUser = (widget.user?.totalXpEarned ?? 0) == 0;
    if (isFirstTimeUser) {
      return 'No progress yet.\n0.0 cm improvement';
    }
    return 'Last check:\n+0.5 cm posture improvement';
  }

  void _handleStartWorkout() {
    if (widget.onStartWorkout != null) {
      widget.onStartWorkout!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WorkoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildWorkoutCard(),
              const SizedBox(height: 24),
              _buildDailyTipsCard(),
              const SizedBox(height: 24),
              _buildProgressCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final double targetProgress = (_goalHeight > 0) ? (_currentHeight / _goalHeight).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $_displayName',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMetricLayout('Current height', '${_currentHeight.toStringAsFixed(0)} cm'),
            _buildMetricLayout('Goal', '${_goalHeight.toStringAsFixed(0)} cm', isRightAligned: true),
          ],
        ),
        const SizedBox(height: 16),
        
        // Animated Progress Bar
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: targetProgress),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.subtleBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppColors.primaryGradient,
                    boxShadow: const [
                      BoxShadow(color: AppColors.accentGlow, blurRadius: 12, offset: Offset(0, 4)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricLayout(String label, String value, {bool isRightAligned = false}) {
    return Column(
      crossAxisAlignment: isRightAligned ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard() {
    return _buildBaseCard(
      title: "Today's Workout",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _workoutName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleStartWorkout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              foregroundColor: AppColors.surface,
              minimumSize: const Size(double.infinity, 56),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: AppColors.textPrimary.withValues(alpha: 0.2),
            ),
            child: const Text('Start Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTipsCard() {
    return _buildBaseCard(
      title: "Daily Tip",
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_rounded, color: AppColors.accentSecondary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _dailyTip,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return _buildBaseCard(
      title: "Recent Progress",
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: AppColors.accentGlow, blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _progressText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentSecondary.withValues(alpha: 0.06), // Cool, blue-tinted shadow
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}