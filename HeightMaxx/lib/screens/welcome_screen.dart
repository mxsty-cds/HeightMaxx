// lib/screens/welcome_screen.dart
//
// The animated entry screen for HeightMaxx.
// Refined to feature a dominant, highly polished primary CTA
// and a cleaner visual hierarchy.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'profile_setup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic)),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStartGrowingPressed() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildTagline(),
                  const Spacer(flex: 3),
                  _buildIllustration(),
                  const Spacer(flex: 3),
                  _buildActions(),
                  const SizedBox(height: 32),
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
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.keyboard_double_arrow_up_rounded,
            color: AppColors.accent,
            size: 56,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'HeightMaxx',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return const Text(
      'Unlock your vertical potential.\nBuild the habit of perfect posture.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPillar(height: 50, opacity: 0.2),
          const SizedBox(width: 16),
          _buildPillar(height: 90, opacity: 0.5),
          const SizedBox(width: 16),
          _buildPillar(height: 140, opacity: 1.0, isAccent: true),
        ],
      ),
    );
  }

  Widget _buildPillar({required double height, required double opacity, bool isAccent = false}) {
    return Container(
      width: 28,
      height: height,
      decoration: BoxDecoration(
        color: isAccent ? AppColors.accent : AppColors.textMuted.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isAccent
            ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))]
            : null,
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dominant Primary CTA
        ElevatedButton(
          onPressed: _onStartGrowingPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: AppColors.accent.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            'Start Growing',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Demoted Secondary Action
        TextButton(
          onPressed: () {}, // TODO: Login route
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textMuted,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'I already have an account',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}