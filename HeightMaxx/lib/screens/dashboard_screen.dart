import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/task.dart';
import '../models/user.dart';
import '../models/xp_engine.dart';
import '../models/xp_event.dart';
import '../theme/app_colors.dart';
import '../widgets/growth_meter.dart';
import '../widgets/task_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.user});

  final UserProfile? user;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late UserProfile _user;
  late List<HeightTask> _tasks;

  final XpEngine _xpEngine = XpEngine();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupAnimations();
  }

  void _loadData() {
    _user =
        widget.user ??
        UserProfile.fromJson({
          'id': 'usr_123',
          'displayName': 'Alex',
          'username': 'alex_123',
          'nickname': 'Alex',
          'level': 1,
          'currentXp': 40,
          'xpToNextLevel': 100,
          'streakDays': 5,
        });

    _tasks = [
      HeightTask(
        id: 't1',
        title: 'Morning Stretch Flow',
        xpReward: 40,
        category: 'Mobility',
      ),
      HeightTask(
        id: 't2',
        title: 'Posture Reset',
        xpReward: 30,
        category: 'Posture',
      ),
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
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
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
      if (task.isCompleted) {
        return;
      }

      _tasks[index] = task.complete();

      final event = XpEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: XpActionType.taskCompletion,
        xpAmount: task.xpReward,
        createdAt: DateTime.now(),
      );

      final previousLevel = _user.level;
      _user = _xpEngine.applyEvent(_user, event);

      if (_user.level > previousLevel) {
        _showLevelUpDialog(_user.level);
      } else {
        _showXpToast(task.xpReward);
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
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Level Up! 🏢'),
        content: Text('You reached Level $newLevel. Keep climbing.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
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
    final userJson = _user.toJson();
    final nickname = (userJson['nickname'] as String?)?.trim() ?? '';
    final displayName = (userJson['displayName'] as String?)?.trim() ?? '';
    final greetingName = nickname.isNotEmpty
        ? nickname
        : (displayName.isNotEmpty ? displayName : 'Mover');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back,',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              greetingName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.04 * 255).round()),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Streak',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${_user.streakDays} days',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
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
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_user.currentXp} / ${_user.xpToNextLevel} XP',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 16),
                if (nextUnlock != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Next: ${nextUnlock.name} at Lvl ${nextUnlock.unlockLevel}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentDark,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          GrowthMeter(progress: _user.progressToNextLevel),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Growth Missions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_tasks.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TaskCard(task: _tasks[index], onTap: () => _handleTaskTap(index)),
          );
        }),
      ],
    );
  }
}
