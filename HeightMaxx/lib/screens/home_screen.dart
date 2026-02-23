// lib/screens/home_screen.dart
//
// The clean, structured MVP Home Dashboard for HeightMaxx.
// Focuses on clear metric visibility, daily actionable tasks, and simple progress tracking.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Mock Data ---
  // TODO: Replace with real data from UserProfile and backend services.
  final String _userName = "User";
  final double _currentHeight = 175.0;
  final double _goalHeight = 180.0;
  final String _workoutName = "Stretching routine";
  final String _dailyTip = "Sleep 8–9 hours for optimal growth hormone";
  final String _lastImprovement = "Last check:\n+0.5 cm posture improvement";

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
              _buildDivider(),
              _buildWorkoutCard(),
              _buildDivider(),
              _buildDailyTipsCard(),
              _buildDivider(),
              _buildProgressCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the greeting, current/goal height metrics, and horizontal progress bar.
  Widget _buildHeader() {
    // Calculate progress safely
    final double progress = (_goalHeight > 0) ? (_currentHeight / _goalHeight).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting
        Text(
          'Hello, $_userName',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // Metrics Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current height:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currentHeight.toStringAsFixed(0)} cm',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Goal:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_goalHeight.toStringAsFixed(0)} cm',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: AppColors.subtleBackground,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
      ],
    );
  }

  /// Builds the primary actionable workout card.
  Widget _buildWorkoutCard() {
    return _buildBaseCard(
      title: "Today's Workout Card",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _workoutName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to active workout screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppColors.accent.withValues(alpha: 0.3),
              minimumSize: const Size(double.infinity, 56),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Start Workout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the informational daily tips card.
  Widget _buildDailyTipsCard() {
    return _buildBaseCard(
      title: "Daily Tips Card",
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.accent,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _dailyTip,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the summary progress card.
  Widget _buildProgressCard() {
    return _buildBaseCard(
      title: "Progress Card",
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _lastImprovement,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  /// Reusable card container to ensure consistent styling, padding, and shadows.
  Widget _buildBaseCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// Standardized visual divider used between main sections.
  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      child: Divider(
        height: 1,
        thickness: 1.5,
        color: AppColors.subtleBackground,
      ),
    );
  }
}