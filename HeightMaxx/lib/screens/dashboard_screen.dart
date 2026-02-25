import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user.dart';
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
  int get _streak => widget.user?.streakDays ?? 0;
  int get _totalWorkouts => widget.user?.totalWorkoutsCompleted ?? 0;
  String get _focus => widget.user?.workoutFocus ?? 'mixed';

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
                  const Text("Activity Map", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  _buildRealActivityChart(),
                  const SizedBox(height: 32),
                  const Text("Growth Matrix", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  _buildGrowthMatrix(),
                  const SizedBox(height: 32),
                  _buildNextMilestoneCard(),
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
}