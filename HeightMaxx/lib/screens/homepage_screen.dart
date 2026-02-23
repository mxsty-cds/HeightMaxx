import 'package:flutter/material.dart';

import '../models/user.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';
import 'home_screen.dart';
import 'workout_screen.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key, this.user, this.initialIndex = 0});

  final UserProfile? user;
  final int initialIndex;

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      DashboardScreen(user: widget.user),
      const WorkoutScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag_rounded),
            label: 'Missions',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center_rounded),
            label: 'Workout',
          ),
        ],
      ),
    );
  }
}
