// lib/screens/profile_screen.dart
//
// A premium, animated profile screen with core metrics and account actions.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock User Data (Replace with your actual state management)
  late UserProfile _user;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize with mock data for demonstration
    _user = const UserProfile(
      id: 'usr_1',
      username: 'apex_mover',
      nickname: 'Alex',
      level: 12,
      heightCm: 175,
      weightKg: 70,
      streakDays: 14,
      // avatarPath: null, // Starts null to show fallback
    );
  }

  Future<void> _pickAvatarFrom(ImageSource source) async {
    HapticFeedback.lightImpact();
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null || !mounted) {
        return;
      }

      setState(() {
        _user = _user.copyWith(avatarPath: image.path);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Could not open camera. Please check camera permissions.'
                  : 'Could not open gallery. Please check photo permissions.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      debugPrint('Avatar picker error: $error');
    }
  }

  /// Prompts the user to select an image source (camera or gallery).
  Future<void> _pickAvatar() async {
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.subtleBackground,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: AppColors.textPrimary),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAvatarFrom(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_rounded, color: AppColors.textPrimary),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAvatarFrom(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
              _buildAnimatedHeader(),
              const SizedBox(height: 40),
              _buildAnimatedStatRow(),
              const SizedBox(height: 48),
              _buildAccountActions(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the Avatar, Name, and Gamified Title with a smooth slide-up animation.
  Widget _buildAnimatedHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          // Interactive Avatar
          GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.subtleBackground,
                    border: Border.all(color: AppColors.surface, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentSecondary.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    // Show selected image, or fallback to gradient initial
                    image: _user.avatarPath != null
                        ? DecorationImage(
                            image: FileImage(File(_user.avatarPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    gradient: _user.avatarPath == null ? AppColors.primaryGradient : null,
                  ),
                  child: _user.avatarPath == null
                      ? Center(
                          child: Text(
                            _user.nickname.isNotEmpty ? _user.nickname[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        )
                      : null,
                ),
                // Small edit badge
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                  ),
                  child: const Icon(Icons.edit_rounded, size: 16, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _user.nickname,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'LEVEL ${_user.level} • APEX MOVER',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.accentPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the horizontal scrollable row of core metrics with staggered entrance.
  Widget _buildAnimatedStatRow() {
    final stats = [
      {'label': 'Height', 'val': '${_user.heightCm?.toStringAsFixed(0) ?? "--"} cm'},
      {'label': 'Weight', 'val': '${_user.weightKg?.toStringAsFixed(0) ?? "--"} kg'},
      {'label': 'Streak', 'val': '${_user.streakDays} Days'},
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: List.generate(stats.length, (index) {
              // Stagger calculation
              final delayOffset = (index * 0.2).clamp(0.0, 1.0);
              final itemOpacity = ((value - delayOffset) / (1 - delayOffset)).clamp(0.0, 1.0);

              return Opacity(
                opacity: itemOpacity,
                child: Transform.translate(
                  offset: Offset(40 * (1 - itemOpacity), 0),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: _buildStatCard(stats[index]['label']!, stats[index]['val']!),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the clean, minimal account action buttons.
  Widget _buildAccountActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        _buildActionTile(Icons.tune_rounded, 'Preferences', () {}),
        const SizedBox(height: 8),
        _buildActionTile(Icons.history_rounded, 'Workout History', () {}),
        const SizedBox(height: 8),
        _buildActionTile(Icons.notifications_none_rounded, 'Notifications', () {}),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.accentPrimary.withValues(alpha: 0.1),
        highlightColor: AppColors.accentPrimary.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}