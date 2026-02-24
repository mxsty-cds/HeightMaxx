import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Данные для календаря
  final DateTime _today = DateTime.now();
  int _selectedDayIndex = 0; // Сегодняшний день по умолчанию

  // Состояние привычек
  final int _waterDrank = 1200;
  final int _waterGoal = 2500;
  final double _sleepHours = 7.5;
  final int _streak = 12;

  late AnimationController _mainController;

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = _today.weekday - 1; // Установка текущего дня
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  // Вспомогательная функция для эффекта появления с задержкой
  Widget _appearAnimation({required Widget child, required int index}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 150)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _appearAnimation(index: 0, child: _buildWeeklyCalendar()),
                const SizedBox(height: 24),
                _appearAnimation(index: 1, child: _buildHeightProgressCard()),
                const SizedBox(height: 24),
                _appearAnimation(index: 2, child: _buildSectionHeader("Today's Plan")),
                const SizedBox(height: 12),
                _appearAnimation(index: 3, child: _buildMainWorkoutCard()),
                const SizedBox(height: 24),
                _appearAnimation(index: 4, child: _buildSectionHeader("Vital Stats")),
                const SizedBox(height: 12),
                _appearAnimation(index: 5, child: _buildBentoHabitsGrid()),
                const SizedBox(height: 24),
                _appearAnimation(index: 6, child: _buildActivityChart()),
                const SizedBox(height: 24),
                _appearAnimation(index: 7, child: _buildAIInsightCard()),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Горизонтальный Календарь ---
  Widget _buildWeeklyCalendar() {
    final List<String> weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 7,
            itemBuilder: (context, index) {
              bool isSelected = index == _selectedDayIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDayIndex = index);
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentPrimary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.accentPrimary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekDays[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${index + 20}", // Моковые даты
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        )
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

  // --- 2. Мини-график активности (Новое) ---
  Widget _buildActivityChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Weekly Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Icon(Icons.insights, color: AppColors.accentPrimary.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              double barHeight = [40.0, 70.0, 50.0, 90.0, 60.0, 80.0, 30.0][index];
              return Column(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 600 + (index * 100)),
                    height: barHeight,
                    width: 12,
                    decoration: BoxDecoration(
                      gradient: index == 3 ? AppColors.primaryGradient : null,
                      color: index == 3 ? null : AppColors.subtleBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(["M", "T", "W", "T", "F", "S", "S"][index], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              );
            }),
          )
        ],
      ),
    );
  }

  // --- Вспомогательные элементы ---
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 110,
      backgroundColor: AppColors.background,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          "Hey, ${widget.user?.nickname ?? 'Mover'} 👋",
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
    );
  }

  // (Остальные методы: _buildHeightProgressCard, _buildMainWorkoutCard, _buildBentoHabitsGrid, _buildAIInsightCard остаются из прошлой версии, но теперь они обернуты в _appearAnimation)

  Widget _buildHeightProgressCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: AppColors.accentPrimary.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimpleMetric('Current', '175 cm'),
              _buildStreakBadge(),
              _buildSimpleMetric('Goal', '180 cm'),
            ],
          ),
          const SizedBox(height: 20),
          _buildPremiumProgressBar(0.65),
        ],
      ),
    );
  }

  Widget _buildSimpleMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildStreakBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: AppColors.accentPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        const Text('🔥', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text('$_streak Days', style: const TextStyle(color: AppColors.accentPrimary, fontWeight: FontWeight.w800)),
      ]),
    );
  }

  Widget _buildPremiumProgressBar(double progress) {
    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.subtleBackground, borderRadius: BorderRadius.circular(10)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [const BoxShadow(color: AppColors.accentGlow, blurRadius: 10)],
          ),
        ),
      ),
    );
  }

  Widget _buildMainWorkoutCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: AppColors.accentGlow.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onStartWorkout,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TODAY\'S SESSION', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1.5)),
                      SizedBox(height: 4),
                      Text('Spine Decompression', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoHabitsGrid() {
    return Row(
      children: [
        Expanded(child: _buildBentoCard(color: const Color(0xFFE3F2FD), icon: Icons.water_drop, iconColor: Colors.blue, title: 'Hydration', value: '$_waterDrank ml', progress: _waterDrank / _waterGoal)),
        const SizedBox(width: 16),
        Expanded(child: _buildBentoCard(color: const Color(0xFFF3E5F5), icon: Icons.nightlight_round, iconColor: Colors.purple, title: 'Sleep', value: '$_sleepHours h', progress: _sleepHours / 9)),
      ],
    );
  }

  Widget _buildBentoCard({required Color color, required IconData icon, required Color iconColor, required String title, required String value, required double progress}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(28)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress, backgroundColor: AppColors.subtleBackground, color: iconColor, minHeight: 4),
      ]),
    );
  }

  Widget _buildAIInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.accentPrimary.withOpacity(0.1))),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.auto_awesome, color: AppColors.accentPrimary, size: 18), SizedBox(width: 8), Text('AI INSIGHT', style: TextStyle(color: AppColors.accentPrimary, fontWeight: FontWeight.w800, fontSize: 10))]),
        SizedBox(height: 8),
        Text("Your spine hydration is optimal today. Excellent job on your 12-day streak!", style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.4)),
      ]),
    );
  }
}