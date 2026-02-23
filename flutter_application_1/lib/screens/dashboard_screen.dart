/// lib/screens/dashboard_screen.dart
///
/// The main hub for HeightMaxx. Displays the user's level, daily tasks,
/// and streak progress with a clean, vertical-focused aesthetic.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- Project Dependencies ---
// Assuming these are implemented elsewhere in the project as requested.
import '../models/user.dart';
import '../models/task.dart';
import '../widgets/vertical_progress.dart';
import '../widgets/task_card.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // --- State ---
  late UserProfile _user;
  late List<HeightTask> _tasks;

  // --- Animation ---
  late final AnimationController _animController;
  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _levelOpacity;
  late final Animation<Offset> _levelSlide;
  late final Animation<double> _tasksOpacity;
  late final Animation<Offset> _tasksSlide;
  late final Animation<double> _streakOpacity;
  late final Animation<Offset> _streakSlide;

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _setupAnimations();
  }

  /// TODO: Replace with real data fetching (e.g., from a Repository or BLoC)
  void _loadMockData() {
    _user = const UserProfile(
      id: 'usr_123',
      displayName: 'Alex',
      level: 3,
      currentXp: 120,
      xpToNextLevel: 250,
      streakDays: 5,
    );

    _tasks = [
      const HeightTask(
        id: 't1',
        title: 'Morning Stretch Flow',
        description: 'Open up your chest and decompress the spine.',
        xpReward: 50,
        category: 'Mobility',
        estimatedMinutes: 5,
      ),
      const HeightTask(
        id: 't2',
        title: 'Posture Reset',
        description: 'Hold a perfect wall posture.',
        xpReward: 30,
        category: 'Posture',
        estimatedMinutes: 2,
      ),
      const HeightTask(
        id: 't3',
        title: 'Core Activation',
        description: 'Plank variations to support the spine.',
        xpReward: 40,
        category: 'Strength',
        estimatedMinutes: 3,
      ),
    ];
  }

  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    CurvedAnimation curved(double begin, double end) {
      return CurvedAnimation(
        parent: _animController,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );
    }

    const slideOffset = Offset(0, 0.1);

    _headerOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curved(0.0, 0.4));
    _headerSlide = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(curved(0.0, 0.4));

    _levelOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curved(0.2, 0.6));
    _levelSlide = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(curved(0.2, 0.6));

    _tasksOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curved(0.4, 0.8));
    _tasksSlide = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(curved(0.4, 0.8));

    _streakOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curved(0.6, 1.0));
    _streakSlide = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(curved(0.6, 1.0));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Handles toggling task completion and rewarding/removing XP locally.
  void _handleTaskTap(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      final task = _tasks[index];
      if (task.isCompleted) {
        // Untoggle
        _tasks[index] = task.resetCompletion();
        // Assuming addXp can handle negative values for toggling in demo
        _user = _user.addXp(-task.xpReward);
      } else {
        // Complete
        _tasks[index] = task.complete();
        _user = _user.addXp(task.xpReward);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Awesome! Gained +${task.xpReward} XP.'),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
    // TODO: Persist completion status and new UserProfile XP to database.
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
              _buildLevelSection(),
              const SizedBox(height: 40),
              _buildTasksSection(),
              const SizedBox(height: 40),
              _buildStreakSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _headerSlide,
      child: FadeTransition(
        opacity: _headerOpacity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _user.displayName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSection() {
    return SlideTransition(
      position: _levelSlide,
      child: FadeTransition(
        opacity: _levelOpacity,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.surface, // Typically Colors.white
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withAlpha((0.05 * 255).round()),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${_user.level}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_user.currentXp} / ${_user.xpToNextLevel} XP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Keep progressing to unlock\nnew mobility routines.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // The vertical growth indicator
              SizedBox(
                height: 120,
                width: 24,
                child: VerticalProgressBar(
                  progress: _user.progressToNextLevel,
                  height: 120,
                  width: 24,
                  showLabel: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasksSection() {
    return SlideTransition(
      position: _tasksSlide,
      child: FadeTransition(
        opacity: _tasksOpacity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Growth Missions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_tasks.length, (index) {
              final task = _tasks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TaskCard(
                  task: task,
                  // Assuming TaskCard exposes an onTap callback
                  onTap: () => _handleTaskTap(index),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSection() {
    return SlideTransition(
      position: _streakSlide,
      child: FadeTransition(
        opacity: _streakOpacity,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withAlpha((0.05 * 255).round()),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(
                    '${_user.streakDays}-Day Streak',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Consistency is the key to vertical growth. Keep showing up!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _buildWeeklyTrend(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a simple 7-day trend indicator (dots/bars) using basic widgets.
  Widget _buildWeeklyTrend() {
    // For demo purposes: assume the user hit their goals 5 days out of the last 7
    // True = completed, False = missed
    final List<bool> weekHistory = [true, true, false, true, true, true, false];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isCompleted = weekHistory[index];
        final isToday = index == 6; // Assume last item is today

        return Container(
          width: 32,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.accent.withAlpha((0.2 * 255).round())
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: isToday
                ? Border.all(color: AppColors.accent, width: 2)
                : null,
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.accent
                    : AppColors.textSecondary.withAlpha((0.3 * 255).round()),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
