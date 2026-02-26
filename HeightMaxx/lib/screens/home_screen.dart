import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user.dart';
import '../models/user_factors.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_insight_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.user, this.onStartWorkout});

  final UserProfile? user;
  final VoidCallback? onStartWorkout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateTime _today = DateTime.now();
  late int _selectedDayIndex;

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = _today.weekday - 1;
  }

  // --- ЛОГИКА ДАННЫХ И КОНВЕРТАЦИИ ---

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _displayName {
    if (widget.user == null) return 'Mover';
    return widget.user!.nickname.isNotEmpty
        ? widget.user!.nickname
        : widget.user!.fullName.split(' ').first;
  }

  // Переводим CM в FT на лету! (1 фут = 30.48 см)
  String get _currentHeight {
    if (widget.user?.heightCm == null) return '-- ft';
    final ft = widget.user!.heightCm! / 30.48;
    return '${ft.toStringAsFixed(1)} ft';
  }

  String get _targetHeight {
    if (widget.user?.heightCm == null) return '-- ft';
    final baseCm = widget.user!.heightCm!;
    // Если цель рост - накидываем ~2 дюйма (5 см). Иначе просто осанка (~2 см).
    final targetCm = widget.user!.growthGoal == GrowthGoal.heightmaxx
        ? baseCm + 5.0
        : baseCm + 2.0;
    final ft = targetCm / 30.48;
    return '${ft.toStringAsFixed(1)} ft';
  }

  double get _growthProgress => widget.user?.progressToNextLevel ?? 0.0;

  // Use effectiveStreakDays to avoid showing stale streak values from Firebase
  int get _streakDays => widget.user?.effectiveStreakDays ?? 0;
  int get _level => widget.user?.level ?? 1;

  // --- АНИМАЦИИ ---
  Widget _appearAnimation({required Widget child, required int index}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 150)),
      curve: Curves.easeOutCubic,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }

  // --- UI СБОРКА ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // AI Insight is shown first for immediate, actionable guidance
                _appearAnimation(index: 0, child: const AiInsightCard()),
                const SizedBox(height: 24),
                _appearAnimation(index: 1, child: _buildWeeklyCalendar()),
                const SizedBox(height: 24),
                // НОВАЯ КРУТАЯ ФИЧА: Дейлик
                _appearAnimation(index: 2, child: _buildDailyQuestCard()),
                const SizedBox(height: 24),
                _appearAnimation(index: 3, child: _buildHeightProgressCard()),
                const SizedBox(height: 24),
                _appearAnimation(
                  index: 4,
                  child: _buildSectionHeader("Today's Plan"),
                ),
                const SizedBox(height: 12),
                _appearAnimation(index: 5, child: _buildMainWorkoutCard()),
                const SizedBox(height: 24),
                _appearAnimation(
                  index: 6,
                  child: _buildSectionHeader("Vital Stats"),
                ),
                const SizedBox(height: 12),
                _appearAnimation(index: 7, child: _buildVitalStatsGrid()),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- КОМПОНЕНТЫ ---

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: AppColors.background,
      elevation: 0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    "$_displayName 👋",
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'LVL $_level',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // КРУТАЯ ФИЧА: Ежедневный Квест
  Widget _buildDailyQuestCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accentSecondary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentSecondary.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentSecondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.blueAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DAILY QUEST",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Complete 1 Stretch Session",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "+50 XP",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ИСПРАВЛЕННЫЙ КАРД РОСТА (БОЛЬШЕ НЕТ OVERFLOW)
  Widget _buildHeightProgressCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPrimary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Expanded не даст тексту вылезти за края!
              Expanded(
                child: _buildSimpleMetric(
                  'Current',
                  _currentHeight,
                  CrossAxisAlignment.start,
                ),
              ),

              _buildStreakBadge(),

              Expanded(
                child: _buildSimpleMetric(
                  'Goal',
                  _targetHeight,
                  CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPremiumProgressBar(_growthProgress),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'XP Progress',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(widget.user?.currentXp ?? 0)} / ${(widget.user?.xpToNextLevel ?? 100)}',
                style: const TextStyle(
                  color: AppColors.accentPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMetric(
    String label,
    String value,
    CrossAxisAlignment alignment,
  ) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        // FittedBox сожмет текст, если он слишком длинный
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakBadge() {
    final streak = _streakDays;
    // "Day 1" for streaks of 0 or 1 (first day or no activity yet — encouragement).
    // "X Days" for established streaks.
    final label = streak <= 1 ? 'Day 1' : '$streak Days';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumProgressBar(double progress) {
    return Container(
      height: 14,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.subtleBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: AppColors.accentGlow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Weekly calendar with activity dots indicating completed sessions.
  Widget _buildWeeklyCalendar() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final startOfWeek = _today.subtract(Duration(days: _today.weekday - 1));
    final streak = _streakDays;
    final todayIndex = _today.weekday - 1; // 0 = Mon

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Activity',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 7,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedDayIndex;
              final dayDate = startOfWeek.add(Duration(days: index));
              final isToday =
                  dayDate.day == _today.day && dayDate.month == _today.month;
              // NOTE: Activity dots are approximated from the streak window.
              // When per-day activity history is available, replace with real data.
              // A day is "active" if it falls within the current streak window (today backwards)
              final daysBeforeToday = todayIndex - index;
              final wasActive =
                  daysBeforeToday >= 0 && daysBeforeToday < streak;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDayIndex = index);
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 65,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentPrimary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.accentPrimary.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekDays[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white70
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${dayDate.day}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Activity dot: green if completed, accent if today, grey placeholder
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: wasActive
                              ? (isSelected ? Colors.white : Colors.green)
                              : (isToday && !isSelected
                                    ? AppColors.accentPrimary
                                    : Colors.transparent),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainWorkoutCard() {
    final focus = widget.user?.workoutFocus?.toUpperCase() ?? 'MIXED';

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGlow.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            if (widget.onStartWorkout != null) widget.onStartWorkout!();
          },
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$focus SESSION',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Spine Decompression',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.user?.workoutMinutesPerSession ?? 20} MIN • INTENSE',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.accentPrimary,
                    size: 36,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
    );
  }

  /// Vital Stats grid: shows specific, labelled metrics with units.
  Widget _buildVitalStatsGrid() {
    final workoutsThisWeek = _streakDays.clamp(0, 7); // Approximate from streak
    final xpToNext = widget.user?.xpToNextLevel ?? 100;
    final currentXp = widget.user?.currentXp ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildVitalStatTile(
                icon: Icons.water_drop_rounded,
                iconColor: Colors.blueAccent,
                title: 'Hydration',
                value: widget.user?.hydrationLevel == HydrationLevel.high
                    ? '2.5 L'
                    : '1.2 L',
                subtitle: 'Today',
                progress: widget.user?.hydrationLevel == HydrationLevel.high
                    ? 0.85
                    : 0.45,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildVitalStatTile(
                icon: Icons.nights_stay_rounded,
                iconColor: Colors.deepPurpleAccent,
                title: 'Sleep',
                value: widget.user?.sleepQuality == SleepQuality.good
                    ? '8.0 h'
                    : '6.5 h',
                subtitle: 'Last night',
                progress: widget.user?.sleepQuality == SleepQuality.good
                    ? 0.9
                    : 0.65,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildVitalStatTile(
                icon: Icons.fitness_center_rounded,
                iconColor: Colors.orangeAccent,
                title: 'Sessions',
                value: '$workoutsThisWeek / 7',
                subtitle: 'This week',
                progress: workoutsThisWeek / 7,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildVitalStatTile(
                icon: Icons.bolt_rounded,
                iconColor: AppColors.accentPrimary,
                title: 'XP to Next',
                value: '${xpToNext - currentXp} XP',
                subtitle: 'Level ${_level + 1}',
                progress: currentXp / (xpToNext > 0 ? xpToNext : 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Reusable tile widget for a single vital stat with label, value, unit and progress.
  Widget _buildVitalStatTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.subtleBackground,
            color: iconColor,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}
