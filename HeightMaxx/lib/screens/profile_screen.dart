// lib/screens/profile_screen.dart
//
// A clean, structured profile screen displaying user metrics and account actions.
// Designed for maximum readability and minimal visual clutter.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- Mock Data ---
  // TODO: Replace with real data from the UserProfile model.
  final double height = 175;
  final double weight = 70;
  final double goal = 180;
  final int workoutDays = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 40),
              _buildUserInfoSection(),
              const SizedBox(height: 40),
              _buildButtonsSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the grouped card containing the user's biometric and goal data.
  Widget _buildUserInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User info:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow('Height', '${height.toStringAsFixed(0)} cm'),
              const Divider(height: 32, color: AppColors.subtleBackground, thickness: 1),
              _buildInfoRow('Weight', '${weight.toStringAsFixed(0)} kg'),
              const Divider(height: 32, color: AppColors.subtleBackground, thickness: 1),
              _buildInfoRow('Goal', '${goal.toStringAsFixed(0)} cm'),
              const Divider(height: 32, color: AppColors.subtleBackground, thickness: 1),
              // Omit the bottom divider for the last item
              _buildInfoRow('Workout days', '$workoutDays days per week'),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper method to create a clean, spaced row for a label/value pair.
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Builds the vertical list of profile actions with clear visual hierarchy.
  Widget _buildButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buttons:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Primary Action
        ElevatedButton(
          onPressed: () {
            // TODO: Navigate to Edit Profile screen
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPrimary, // Use accent for primary emphasis
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: AppColors.accentPrimary.withValues(alpha: 0.3),
            minimumSize: const Size(double.infinity, 56),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Edit profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Neutral Action 1
        TextButton(
          onPressed: () {
            // TODO: Trigger Reset Plan confirmation dialog
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            minimumSize: const Size(double.infinity, 56),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Reset plan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Neutral Action 2
        TextButton(
          onPressed: () {
            // TODO: Navigate to Settings screen
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            minimumSize: const Size(double.infinity, 56),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}