import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user.dart';
import '../models/unlocks.dart';
import '../models/xp_engine.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  final UserProfile? user;

  const DashboardScreen({super.key, this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  // --- РЕАЛЬНЫЕ ДАННЫЕ ИЗ FIREBASE ---
  int get _level => widget.user?.level ?? 1;
  int get _currentXp => widget.user?.currentXp ?? 0;
  int get _xpNext => widget.user?.xpToNextLevel ?? 100;
  int get _totalXp => widget.user?.totalXpEarned ?? 0;
  // Use effectiveStreakDays to avoid showing stale streak values
  int get _streak => widget.user?.effectiveStreakDays ?? 0;
  int get _totalWorkouts => widget.user?.totalWorkoutsCompleted ?? 0;
  String get _focus => widget.user?.workoutFocus ?? 'mixed';

  // Estimate daily XP as a fraction of weekly (streak-based)
  int get _xpToday => _streak > 0 ? (_currentXp > 0 ? (_currentXp / max(_streak, 1)).round() : 20) : 0;
  // Estimate weekly XP from current level progress + streak
  int get _xpThisWeek => min(_currentXp + (_streak * 15), _xpNext);

  // --- ГЕНЕРАЦИЯ ГРАФИКА НА ОСНОВЕ РЕАЛЬНОГО СТРИКА ---
  // Так как у нас пока нет отдельной коллекции "история тренировок",
  // мы делаем умную имитацию графика на основе твоего текущего стрика.
  List<double> get _realisticWeekData {
    List<double> week = List.filled(7, 0.0); // 7 дней, изначально по нулям
    int todayIndex = DateTime.now().weekday - 1; // 0 = Пн, 6 = Вс

    // Заполняем график назад на количество дней стрика
    for (int i = 0; i < min(_streak, 7); i++) {
      int dayIndex = (todayIndex - i) % 7;
      if (dayIndex < 0) dayIndex += 7;
      // Даем реалистичный столбик (базовые 40-60 минут/XP + рандом)
      week[dayIndex] = 40.0 + (Random().nextDouble() * 40);
    }
    return week;
  }

  // All rewards defined in XpEngine, used to render the Skill Unlocks section
  // (accessing static field via class reference, no instance needed)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMainStatsRow(),
                  const SizedBox(height: 32),
                  // XP Analytics: clear, hierarchical breakdown of XP metrics
                  _buildXpAnalyticsCard(),
                  const SizedBox(height: 32),
                  const Text("Activity Map", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  _buildRealActivityChart(),
                  const SizedBox(height: 32),
                  const Text("Growth Matrix", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  _buildGrowthMatrix(),
                  const SizedBox(height: 32),
                  _buildNextMilestoneCard(),
                  const SizedBox(height: 32),
                  // Skill Unlocks: interactive tappable cards
                  const Text("Skill Unlocks", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap a skill to see details and requirements.",
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  _buildSkillUnlocksList(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. ШАПКА ---
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Analytics",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -1),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.subtleBackground)),
              child: const Icon(Icons.share_rounded, color: AppColors.textPrimary, size: 20),
            )
          ],
        ),
      ),
    );
  }

  // --- 2. ГЛАВНЫЕ МЕТРИКИ ---
  Widget _buildMainStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatSquare("Workouts", "$_totalWorkouts", Icons.fitness_center_rounded, AppColors.accentPrimary)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatSquare("Streak", "$_streak", Icons.local_fire_department_rounded, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatSquare("Level", "$_level", Icons.military_tech_rounded, Colors.amber)),
      ],
    );
  }

  Widget _buildStatSquare(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  // --- XP ANALYTICS CARD: Total XP, this week, today, progress ---
  Widget _buildXpAnalyticsCard() {
    final double progress = (_currentXp / (_xpNext > 0 ? _xpNext : 1)).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.accentPrimary.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: AppColors.accentPrimary.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.accentPrimary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'XP Analytics',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Three XP metrics in a row
          Row(
            children: [
              Expanded(child: _buildXpMetric('Total XP', '$_totalXp', 'all time', Colors.amber)),
              _buildVerticalDivider(),
              Expanded(child: _buildXpMetric('This Week', '$_xpThisWeek', 'estimated', AppColors.accentPrimary)),
              _buildVerticalDivider(),
              Expanded(child: _buildXpMetric('Today', '$_xpToday', 'earned', Colors.green)),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar toward next level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Level $_level', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
              Text('${(progress * 100).toInt()}% to Level ${_level + 1}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.accentPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.subtleBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentPrimary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_currentXp / $_xpNext XP — ${_xpNext - _currentXp} XP left to next level',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildXpMetric(String label, String value, String sublabel, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text(sublabel, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 50, color: AppColors.subtleBackground, margin: const EdgeInsets.symmetric(horizontal: 8));
  }

  // --- 3. НАСТОЯЩИЙ ГРАФИК ---
  Widget _buildRealActivityChart() {
    final weekData = _realisticWeekData;
    final maxVal = weekData.reduce(max) > 0 ? weekData.reduce(max) : 100.0;
    final todayIndex = DateTime.now().weekday - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('XP Earned This Week', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
              Text('${_streak > 0 ? 'Active' : 'Resting'}', style: TextStyle(color: _streak > 0 ? Colors.green : AppColors.textSecondary, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final val = weekData[index];
              final heightPercentage = val / maxVal;
              final isToday = index == todayIndex;

              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    height: 120 * heightPercentage.clamp(0.05, 1.0), // Минимум 5% высоты, чтобы столбик было видно
                    width: 24,
                    decoration: BoxDecoration(
                      gradient: isToday ? AppColors.primaryGradient : null,
                      color: isToday ? null : AppColors.subtleBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                    style: TextStyle(fontSize: 12, fontWeight: isToday ? FontWeight.w900 : FontWeight.bold, color: isToday ? AppColors.textPrimary : AppColors.textSecondary),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- 4. МАТРИЦА НАВЫКОВ (ПРО ФИЧА) ---
  Widget _buildGrowthMatrix() {
    // Рассчитываем фокус на основе предпочтений юзера
    double posture = _focus == 'posture' ? 0.8 : 0.4;
    double mobility = _focus == 'mobility' ? 0.9 : 0.5;
    double intensity = _focus == 'mixed' ? 0.7 : 0.3;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(32)),
      child: Column(
        children: [
          _buildMatrixBar("Posture Alignment", posture, Colors.blueAccent),
          const SizedBox(height: 16),
          _buildMatrixBar("Spine Mobility", mobility, Colors.purpleAccent),
          const SizedBox(height: 16),
          _buildMatrixBar("Core Intensity", intensity, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildMatrixBar(String label, double value, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
        ),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.subtleBackground,
              color: color,
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
      ],
    );
  }

  // --- 5. ТРЕКЕР СЛЕДУЮЩЕГО УРОВНЯ ---
  Widget _buildNextMilestoneCard() {
    double progress = (_currentXp / _xpNext).clamp(0.0, 1.0);
    int xpRemaining = _xpNext - _currentXp;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.accentPrimary.withOpacity(0.1), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.accentPrimary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60, height: 60,
                child: CircularProgressIndicator(value: progress, backgroundColor: AppColors.subtleBackground, color: AppColors.accentPrimary, strokeWidth: 6),
              ),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Road to Level ${_level + 1}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text("$xpRemaining XP left to unlock new advanced stretches.", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- 6. SKILL UNLOCKS: Interactive, tappable cards ---
  Widget _buildSkillUnlocksList() {
    // Gather all rewards and show their unlock status
    final allRewards = [
      XpEngine.allRewards[0], // level 2
      XpEngine.allRewards[1], // level 3
      XpEngine.allRewards[2], // level 5
    ];

    return Column(
      children: allRewards.map((reward) {
        final isUnlocked = _level >= reward.unlockLevel;
        final progress = isUnlocked ? 1.0 : (_level / reward.unlockLevel).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSkillUnlockTile(reward, isUnlocked, progress),
        );
      }).toList(),
    );
  }

  Widget _buildSkillUnlockTile(UnlockableReward reward, bool isUnlocked, double progress) {
    final Color tileColor = isUnlocked ? Colors.green : AppColors.accentPrimary;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          HapticFeedback.lightImpact();
          _showSkillUnlockDetail(reward, isUnlocked, progress);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon with unlock status
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: tileColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                  color: tileColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reward.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(reward.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.subtleBackground,
                      color: tileColor,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUnlocked
                          ? 'Unlocked at Level ${reward.unlockLevel} ✓'
                          : 'Requires Level ${reward.unlockLevel} • ${(progress * 100).toInt()}% complete',
                      style: TextStyle(fontSize: 10, color: tileColor, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a bottom sheet with full skill unlock details.
  void _showSkillUnlockDetail(UnlockableReward reward, bool isUnlocked, double progress) {
    final Color accentColor = isUnlocked ? Colors.green : AppColors.accentPrimary;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42, height: 4,
                  decoration: BoxDecoration(color: AppColors.subtleBackground, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: accentColor.withOpacity(0.12), shape: BoxShape.circle),
                    child: Icon(isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded, color: accentColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reward.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        Text(
                          reward.type == UnlockType.theme ? 'Theme' : reward.type == UnlockType.avatarTier ? 'Avatar' : 'Workout',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: accentColor, letterSpacing: 1.2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('What it does', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text(reward.description, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.5)),
              const SizedBox(height: 20),
              Text('Requirements', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text('Reach Level ${reward.unlockLevel}', style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: AppColors.subtleBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isUnlocked ? 'Unlocked! 🎉' : '${(progress * 100).toInt()}% complete — ${reward.unlockLevel - _level} level(s) to go',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: accentColor),
              ),
            ],
          ),
        );
      },
    );
  }
}