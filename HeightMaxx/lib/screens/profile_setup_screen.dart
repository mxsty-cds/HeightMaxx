// lib/screens/profile_setup_screen.dart
//
// Multi-step biometric and habit onboarding flow.
// Updated to capture user nickname and finalize profile fields.

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/user_factors.dart';
import '../screens/dashboard_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_stepper.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nicknameController = TextEditingController();
  int _currentIndex = 0;

  // Temporary state for the form
  int _age = 18;
  Sex? _sex;
  int _heightCm = 170;
  final int _weightKg = 65;
  ActivityLevel? _activityLevel;
  GrowthGoal? _growthGoal;

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard if open
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeSetup();
    }
  }

  void _completeSetup() {
    final rawNickname = _nicknameController.text.trim();

    final finalDisplayName = rawNickname.isNotEmpty ? rawNickname : 'Mover';
    final finalId = 'usr_${DateTime.now().millisecondsSinceEpoch}';

    final newUser = UserProfile.fromJson({
      'id': finalId,
      'displayName': finalDisplayName,
      'username': finalDisplayName.toLowerCase().replaceAll(' ', '_'),
      'nickname': finalDisplayName,
      'age': _age,
      'sex': _sex?.name,
      'heightCm': _heightCm.toDouble(),
      'weightKg': _weightKg.toDouble(),
      'activityLevel': _activityLevel?.name,
      'growthGoal': _growthGoal?.name,
      'profileCreatedAt': DateTime.now().toIso8601String(),
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => DashboardScreen(user: newUser)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: [
                  _buildStep1BasicInfo(),
                  _buildStep2Metrics(),
                  _buildStep3Habits(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: LinearProgressIndicator(
        value: (_currentIndex + 1) / 3,
        backgroundColor: AppColors.subtleBackground,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
        borderRadius: BorderRadius.circular(8),
        minHeight: 6,
      ),
    );
  }

  Widget _buildStep1BasicInfo() {
    return _buildStepContainer(
      title: 'Let\'s build your profile',
      subtitle: 'This helps us personalize your growth journey.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What should we call you?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          TextField(
            controller: _nicknameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. Alex (Optional)',
              hintStyle: TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 40),
          const Text('Select Your Age', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          PremiumStepper(
            value: _age,
            minValue: 10,
            maxValue: 80,
            unit: 'Years',
            onChanged: (val) => setState(() => _age = val),
          ),
        ],
      ),
    );
  }

  // Note: _buildStep2Metrics, _buildStep3Habits, _buildStepContainer, 
  // and _buildBottomControls remain exactly the same as the previous implementation.
  // ... (omitted here for brevity, paste them exactly as generated in the previous step)
  
  Widget _buildStep2Metrics() {
    return _buildStepContainer(
      title: 'Current Metrics',
      subtitle: 'Used to calculate your personal posture baseline.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Height', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          PremiumStepper(
            value: _heightCm,
            minValue: 100,
            maxValue: 250,
            unit: 'cm',
            onChanged: (val) => setState(() => _heightCm = val),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Habits() {
    return _buildStepContainer(
      title: 'Habits & Goals',
      subtitle: 'How do you move throughout the day?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ActivityLevel.values.map((a) => ChoiceChip(
              label: Text(a.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700)),
              selected: _activityLevel == a,
              selectedColor: AppColors.accentLight,
              backgroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (selected) => setState(() => _activityLevel = selected ? a : null),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContainer({required String title, required String subtitle, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 48),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppColors.accent.withValues(alpha: 0.4),
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: _nextPage,
        child: Text(
          _currentIndex == 2 ? 'Complete Profile' : 'Continue',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ),
    );
  }
}