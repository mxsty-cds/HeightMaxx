import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user.dart';
import '../models/task.dart';
import '../models/xp_event.dart';
import '../models/xp_engine.dart';
import '../widgets/growth_meter.dart';
import '../widgets/task_card.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late UserProfile _user;
  late List<HeightTask> _tasks;
  
  // Initialize the gamification engine
  final XpEngine _xpEngine = XpEngine();

  // Animations
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _setupAnimations();
  }

  void _loadMockData() {
    _user = const UserProfile(
      id: 'usr_123',
      displayName: 'Alex',
      level: 1,
      currentXp: 40,
      xpToNextLevel: 100, // Based on new formula
      streakDays: 5,
    );

    _tasks = [
      const HeightTask(id: 't1', title: 'Morning Stretch Flow', xpReward: 40, category: 'Mobility'),
      const HeightTask(id: 't2', title: 'Posture Reset', xpReward: 30, category: 'Posture'),
    ];
  }

  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTaskTap(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      final task = _tasks[index];
      if (!task.isCompleted) {
        // Complete the task
        _tasks[index] = task.complete();
        
        // Generate an XP Event and process it through the engine
        final event = XpEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: XpActionType.taskCompletion,
          xpAmount: task.xpReward,
          createdAt: DateTime.now(),
        );
        
        final previousLevel = _user.level;
        _user = _xpEngine.applyEvent(_user, event);

        // Check for level up to show a specific UI celebration
        if (_user.level > previousLevel) {
          _showLevelUpDialog(_user.level);
        } else {
          _showXpToast(task.xpReward);
        }
      }
    });
  }

  void _showXpToast(int amount) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vertical growth! +$amount XP.'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLevelUpDialog(int newLevel) {
    // Simple placeholder for a premium level-up celebration
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Level Up! 🏢'),
        content: Text('You have reached Level $newLevel. Keep climbing.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildLevelSection(),
                  const SizedBox(height: 40),
                  _buildTasksSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Welcome back,', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(_user.displayName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildLevelSection() {
    final nextUnlock = _xpEngine.getNextUnlockHint(_user.level);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha((0.04 * 255).round()), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Level ${_user.level}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text('${_user.currentXp} / ${_user.xpToNextLevel} XP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.accent)),
                const SizedBox(height: 16),
                
                // Dynamic Unlock Hint
                if (nextUnlock != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Next: ${nextUnlock.name} at Lvl ${nextUnlock.unlockLevel}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentDark),
                    ),
                  ),
              ],
            ),
          ),
          // Skyscraper visual
          GrowthMeter(progress: _user.progressToNextLevel),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Today\'s Growth Missions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        ...List.generate(_tasks.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TaskCard(
              task: _tasks[index],
              onTap: () => _handleTaskTap(index),
            ),
          );
        }),
      ],
    );
  }
}