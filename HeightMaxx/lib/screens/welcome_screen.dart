/// lib/screens/welcome_screen.dart
///
/// The animated entry screen for HeightMaxx.
/// Focuses on clean, vertical energy with staggered entrance animations
/// to introduce the user to the posture and mobility journey.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'profile_setup_screen.dart';

// Mock import for theme colors.
// import '../theme/app_colors.dart';

// --- Fallback Theme Constants ---
// In a real app, these would come from AppColors.
const Color _bgColor = Color(0xFFFAFAFA);
const Color _accentColor = Color(0xFF4361EE); // Premium elevating blue
const Color _textPrimary = Color(0xFF111111);
const Color _textSecondary = Color(0xFF666666);

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Staggered animation pairs (Fade + Slide)
  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _headerSlide;

  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;

  late final Animation<double> _illustrationOpacity;
  late final Animation<Offset> _illustrationSlide;

  late final Animation<double> _actionsOpacity;
  late final Animation<Offset> _actionsSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Helper function to create staggered curved animations
    CurvedAnimation curved(double begin, double end) {
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );
    }

    final slideBegin = const Offset(0, 0.15);
    final slideEnd = Offset.zero;

    // 0.0 - 0.4: Branding
    _headerOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curved(0.0, 0.4));
    _headerSlide = Tween<Offset>(
      begin: slideBegin,
      end: slideEnd,
    ).animate(curved(0.0, 0.4));

    // 0.2 - 0.6: Tagline
    _taglineOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curved(0.2, 0.6));
    _taglineSlide = Tween<Offset>(
      begin: slideBegin,
      end: slideEnd,
    ).animate(curved(0.2, 0.6));

    // 0.4 - 0.8: Illustration
    _illustrationOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curved(0.4, 0.8));
    _illustrationSlide = Tween<Offset>(
      begin: slideBegin,
      end: slideEnd,
    ).animate(curved(0.4, 0.8));

    // 0.6 - 1.0: Actions
    _actionsOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curved(0.6, 1.0));
    _actionsSlide = Tween<Offset>(
      begin: slideBegin,
      end: slideEnd,
    ).animate(curved(0.6, 1.0));

    // Start the entrance animation sequence
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStartGrowingPressed() {
    HapticFeedback.lightImpact();
    
    // TODO: Fetch current user from your state manager (BLoC/Provider)
    // final user = context.read<UserCubit>().state.user;
    
    // Example logic:
    // if (user.hasCompletedProfile) {
    //   Navigator.of(context).pushReplacementNamed('/dashboard');
    // } else {
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
    //   );
    // }
    
    // Temporary override for development:
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
    );
  }

  void _onLoginPressed() {
    HapticFeedback.selectionClick();
    // TODO: Navigate to login route
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Login screen coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
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
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _headerSlide,
      child: FadeTransition(
        opacity: _headerOpacity,
        child: Column(
          children: [
            // Minimal abstract logo element (upward arrows/chevrons)
            const Icon(
              Icons.keyboard_double_arrow_up_rounded,
              color: _accentColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'HeightMaxx',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
                color: _textPrimary,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return SlideTransition(
      position: _taglineSlide,
      child: FadeTransition(
        opacity: _taglineOpacity,
        child: const Text(
          'Level up your posture & presence.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: _textSecondary,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return SlideTransition(
      position: _illustrationSlide,
      child: FadeTransition(
        opacity: _illustrationOpacity,
        child: SizedBox(
          height: 160,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPillar(height: 60, opacity: 0.3),
              const SizedBox(width: 16),
              _buildPillar(height: 100, opacity: 0.6),
              const SizedBox(width: 16),
              _buildPillar(height: 150, opacity: 1.0, isAccent: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillar({
    required double height,
    required double opacity,
    bool isAccent = false,
  }) {
    return Container(
      width: 24,
      height: height,
      decoration: BoxDecoration(
        color: isAccent
            ? _accentColor
            : _textSecondary.withAlpha((opacity * 255).round()),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isAccent
            ? [
                BoxShadow(
                  color: _accentColor.withAlpha((0.3 * 255).round()),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildActions() {
    return SlideTransition(
      position: _actionsSlide,
      child: FadeTransition(
        opacity: _actionsOpacity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _onStartGrowingPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: _accentColor.withAlpha((0.4 * 255).round()),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Start Growing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _onLoginPressed,
              style: TextButton.styleFrom(
                foregroundColor: _textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'I already have an account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
