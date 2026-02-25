import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_navigation_bar/responsive_navigation_bar.dart'; // НОВЫЙ ПАКЕТ

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Экраны
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'workout_screen.dart';
import 'profile_screen.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';

class HomePageScreen extends StatefulWidget {
  final UserProfile? user;
  final int initialIndex;

  const HomePageScreen({super.key, this.user, this.initialIndex = 0});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late int _bottomNavIndex;
  late Stream<UserProfile?> _userStream;

  @override
  void initState() {
    super.initState();
    _bottomNavIndex = widget.initialIndex;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          return UserProfile.fromJson(snapshot.data()!);
        }
        return null;
      });
    } else {
      _userStream = Stream.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && widget.user == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.accentPrimary)),
          );
        }

        final UserProfile? liveUser = snapshot.data ?? widget.user;

        final List<Widget> pages = [
          HomeScreen(user: liveUser),
          DashboardScreen(user: liveUser),
          WorkoutScreen(user: liveUser),
          ProfileScreen(user: liveUser),
        ];

        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true, // Позволяет контенту заезжать под бар
          body: IndexedStack(
            index: _bottomNavIndex,
            children: pages,
          ),

          // НОВЫЙ RESPONSIVE NAVIGATION BAR
          bottomNavigationBar: ResponsiveNavigationBar(
            selectedIndex: _bottomNavIndex,
            onTabChange: (int index) {
              HapticFeedback.lightImpact();
              setState(() => _bottomNavIndex = index);
            },
            // Дизайн самого бара
            backgroundColor: AppColors.surface.withOpacity(0.9),
            backgroundBlur: 15.0, // Эффект стекла
            outerPadding: const EdgeInsets.only(bottom: 24, left: 24, right: 24), // Плавающий эффект
            borderRadius: 24,
            activeIconColor: Colors.white,
            inactiveIconColor: AppColors.textSecondary,
            textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),

            // Кнопки
            navigationBarButtons: const <NavigationBarButton>[
              NavigationBarButton(
                text: 'Home',
                icon: Icons.home_rounded,
                backgroundGradient: AppColors.primaryGradient,
              ),
              NavigationBarButton(
                text: 'Stats',
                icon: Icons.bar_chart_rounded,
                backgroundGradient: AppColors.primaryGradient,
              ),
              NavigationBarButton(
                text: 'Train',
                icon: Icons.fitness_center_rounded,
                backgroundGradient: AppColors.primaryGradient,
              ),
              NavigationBarButton(
                text: 'Profile',
                icon: Icons.person_rounded,
                backgroundGradient: AppColors.primaryGradient,
              ),
            ],
          ),
        );
      },
    );
  }
}