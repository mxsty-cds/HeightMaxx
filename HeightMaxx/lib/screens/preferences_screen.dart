// lib/screens/preferences_screen.dart
//
// User preferences screen. Currently shows structured placeholder sections
// ready for real settings to be wired in as features are built out.
// TODO: Persist preference values to Firestore / SharedPreferences.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // TODO: Load initial values from a settings service / SharedPreferences.
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  bool _soundEffects = true;
  String _units = 'Imperial (ft)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Preferences',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _buildSectionHeader('General'),
          const SizedBox(height: 12),
          _buildSwitchTile(
            icon: Icons.notifications_rounded,
            iconColor: AppColors.accentPrimary,
            title: 'Push Notifications',
            subtitle: 'Workout reminders and updates',
            value: _notificationsEnabled,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              setState(() => _notificationsEnabled = v);
            },
          ),
          const SizedBox(height: 8),
          _buildSwitchTile(
            icon: Icons.volume_up_rounded,
            iconColor: Colors.orangeAccent,
            title: 'Sound Effects',
            subtitle: 'In-workout audio cues',
            value: _soundEffects,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              setState(() => _soundEffects = v);
            },
          ),
          const SizedBox(height: 8),
          _buildSwitchTile(
            icon: Icons.dark_mode_rounded,
            iconColor: Colors.deepPurpleAccent,
            title: 'Dark Mode',
            subtitle: 'Switch to dark theme',
            value: _darkMode,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              setState(() => _darkMode = v);
              // TODO: Apply dark theme via ThemeNotifier when added.
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Measurement Units'),
          const SizedBox(height: 12),
          _buildRadioTile(
            icon: Icons.straighten_rounded,
            iconColor: Colors.blueAccent,
            title: 'Imperial (ft / lbs)',
            value: 'Imperial (ft)',
          ),
          const SizedBox(height: 8),
          _buildRadioTile(
            icon: Icons.straighten_rounded,
            iconColor: Colors.green,
            title: 'Metric (cm / kg)',
            value: 'Metric (cm)',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Account'),
          const SizedBox(height: 12),
          _buildNavigationTile(
            icon: Icons.lock_outline_rounded,
            iconColor: Colors.redAccent,
            title: 'Change Password',
            // TODO: Navigate to change password screen.
            onTap: () => _showComingSoon(context, 'Change Password'),
          ),
          const SizedBox(height: 8),
          _buildNavigationTile(
            icon: Icons.delete_outline_rounded,
            iconColor: Colors.red,
            title: 'Delete Account',
            // TODO: Implement account deletion with confirmation.
            onTap: () => _showComingSoon(context, 'Delete Account'),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.accentPrimary,
        ),
      ),
    );
  }

  Widget _buildRadioTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    final isSelected = _units == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _units = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppColors.accentPrimary, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.accentPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }
}
