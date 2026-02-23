// lib/screens/welcome_screen.dart
//
// The entry point. Features a glowing hero element and staggered,
// upward-sliding entrance animations to reinforce "vertical growth."

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'homepage_screen.dart';
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
      duration: const Duration(milliseconds: 1000),
    );

    // Smooth ease-out for a premium, non-bouncy feel
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(curve);

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
                  _buildHeroLogo(),
                  const SizedBox(height: 48),
                  _buildTypography(),
                  const Spacer(flex: 3),
                  _buildPrimaryCTA(),
                  const SizedBox(height: 16),
                  _buildSecondaryCTA(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroLogo() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGlow,
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'H',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypography() {
    return Column(
      children: [
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
        const SizedBox(height: 16),
        Text(
          'Unlock your vertical potential.\nBuild the habit of perfect posture.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryCTA() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGlow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _onStartGrowingPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Let Ink/Gradient show
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ).copyWith(
          backgroundColor: WidgetStateProperty.all(AppColors.accentPrimary),
        ),
        child: const Text(
          'Start Growing',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary, // High contrast dark text on cyan
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryCTA() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePageScreen()),
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Text(
        'I already have an account',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}