/// lib/screens/profile_setup_screen.dart
///
/// Simplified multi-step biometric and habit onboarding flow.
library;

import 'package:flutter/material.dart';
import '../models/user_factors.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _currentStep = 0;

  // Form state
  int? _age = 18;
  Sex? _sex;
  double? _heightCm = 170;
  double? _weightKg = 65;
  ActivityLevel? _activityLevel;
  GrowthGoal? _growthGoal;

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _completeSetup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _completeSetup() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 3,
                  minHeight: 6,
                  backgroundColor: AppColors.subtleBackground,
                  valueColor: AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            ),
            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepContent(),
                  ],
                ),
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.accent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _currentStep == 2 ? 'Complete' : 'Next',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Basic Info', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text('Tell us about yourself', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
        const SizedBox(height: 40),
        const Text('Age', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 12),
        Slider(
          value: _age?.toDouble() ?? 18,
          min: 12,
          max: 60,
          divisions: 48,
          activeColor: AppColors.accent,
          label: '${_age ?? 18} years',
          onChanged: (val) => setState(() => _age = val.toInt()),
        ),
        const SizedBox(height: 32),
        const Text('Biological Sex', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: Sex.values.map((sex) {
            return ChoiceChip(
              label: Text(sex.name.toUpperCase()),
              selected: _sex == sex,
              selectedColor: AppColors.accentLight,
              onSelected: (selected) => setState(() => _sex = selected ? sex : null),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Body Metrics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text('How do you measure up?', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
        const SizedBox(height: 40),
        const Text('Height (cm)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 12),
        Slider(
          value: _heightCm ?? 170,
          min: 120,
          max: 220,
          divisions: 100,
          activeColor: AppColors.accent,
          label: '${_heightCm?.round() ?? 170} cm',
          onChanged: (val) => setState(() => _heightCm = val),
        ),
        const SizedBox(height: 32),
        const Text('Weight (kg)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 12),
        Slider(
          value: _weightKg ?? 65,
          min: 30,
          max: 150,
          divisions: 120,
          activeColor: AppColors.accent,
          label: '${_weightKg?.round() ?? 65} kg',
          onChanged: (val) => setState(() => _weightKg = val),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Goals', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text('What matters most to you?', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
        const SizedBox(height: 40),
        const Text('Activity Level', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ActivityLevel.values.map((level) {
            return ChoiceChip(
              label: Text(level.name),
              selected: _activityLevel == level,
              selectedColor: AppColors.accentLight,
              onSelected: (selected) => setState(() => _activityLevel = selected ? level : null),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        const Text('Primary Goal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: GrowthGoal.values.map((goal) {
            final label = goal.name
                .replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2')
                .replaceAll('_', ' ');
            return ChoiceChip(
              label: Text(label),
              selected: _growthGoal == goal,
              selectedColor: AppColors.accentLight,
              onSelected: (selected) => setState(() => _growthGoal = selected ? goal : null),
            );
          }).toList(),
        ),
      ],
    );
  }
}