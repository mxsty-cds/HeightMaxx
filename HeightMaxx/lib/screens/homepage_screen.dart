import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/services.dart';

// Импорты твоих экранов (убедись, что пути правильные)
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'workout_screen.dart';
import 'profile_screen.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';

class HomePageScreen extends StatefulWidget {
  final UserProfile? user;
  final int initialIndex;

  const HomePageScreen({
    super.key,
    this.user,
    this.initialIndex = 0
  });

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late int _bottomNavIndex;

  // Список иконок для панели (4 штуки, так как 5-я по центру)
  final List<IconData> _iconList = [
    Icons.home_rounded,
    Icons.auto_awesome_mosaic_rounded, // Для миссий/XP
    Icons.bar_chart_rounded,           // Статистика (можно заменить на Workout list)
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _bottomNavIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    // Список страниц, которые мы запомнили
    final List<Widget> _pages = [
      HomeScreen(user: widget.user),     // Твой дашборд с ростом
      DashboardScreen(user: widget.user), // Экран с уровнями и XP
      const WorkoutScreen(),             // Список упражнений
      const ProfileScreen(),             // Настройки профиля
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      // Магия: контент заезжает под прозрачный/парящий бар
      extendBody: true,

      // IndexedStack сохраняет состояние (скролл, введенный текст) на каждой вкладке
      body: IndexedStack(
        index: _bottomNavIndex,
        children: _pages,
      ),

      // Центральная кнопка - "Пульс" приложения
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.textPrimary, // Темная или акцентная
        elevation: 10,
        shape: const CircleBorder(),
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient, // Твой фирменный градиент
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGlow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 35,
          ),
        ),
        onPressed: () {
          HapticFeedback.mediumImpact();
          // Мгновенный переход на вкладку тренировок или открытие плеера
          setState(() => _bottomNavIndex = 2);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? AppColors.accentPrimary : Colors.grey.withOpacity(0.6);
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_iconList[index], size: 28, color: color),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: isActive
                    ? Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                )
                    : const SizedBox(height: 4),
              )
            ],
          );
        },
        backgroundColor: AppColors.surface,
        activeIndex: _bottomNavIndex,
        splashColor: AppColors.accentPrimary,
        notchAndCornersAnimation: null, // Можно добавить анимацию появления
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.softEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) {
          HapticFeedback.lightImpact();
          setState(() => _bottomNavIndex = index);
        },
        shadow: Shadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, -5),
        ),
      ),
    );
  }
}