import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Добавили для кнопки Выхода

import '../models/user.dart';
import '../theme/app_colors.dart';
import '../utils/measurement_utils.dart';
import 'welcome_screen.dart'; // Убедись, что путь правильный для экрана входа
import 'leaderboard_screen.dart';
import 'preferences_screen.dart';
import 'workout_history_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? user; // 1. ТЕПЕРЬ ЭКРАН ПРИНИМАЕТ ДАННЫЕ!

  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _localAvatarPath; // Для локального отображения фотки до загрузки в облако

  // --- ХЕЛПЕРЫ ДЛЯ ДАННЫХ ---
  String get _nickname => widget.user?.nickname.isNotEmpty == true ? widget.user!.nickname : 'Mover';
  int get _level => widget.user?.level ?? 1;
  // Use effectiveStreakDays to avoid showing stale streak values
  String get _streak => '${widget.user?.effectiveStreakDays ?? 0} Days';

  /// Maps level to a rank title so the profile doesn't show a hardcoded label.
  String get _rankTitle {
    if (_level >= 10) return 'ELITE MOVER';
    if (_level >= 7) return 'APEX MOVER';
    if (_level >= 4) return 'PRO MOVER';
    if (_level >= 2) return 'JUNIOR MOVER';
    return 'BEGINNER';
  }

  // Конвертация в футы + дюймы
  String get _heightFt =>
      MeasurementUtils.formatHeight(widget.user?.heightCm);

  String get _formattedWeight =>
      MeasurementUtils.formatWeight(widget.user?.weightKg);

  // --- ЛОГИКА ФОТО ---
  Future<void> _pickAvatarFrom(ImageSource source) async {
    HapticFeedback.lightImpact();
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      setState(() {
        _localAvatarPath = image.path;
      });

      // Бро, тут в будущем мы добавим загрузку этой фотки в Firebase Storage!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar updated locally! (Cloud save coming soon)'), behavior: SnackBarBehavior.floating),
      );

    } catch (error) {
      debugPrint('Avatar picker error: $error');
    }
  }

  Future<void> _pickAvatar() async {
    if (!mounted) return;
    HapticFeedback.mediumImpact();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 42, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: AppColors.subtleBackground, borderRadius: BorderRadius.circular(2))),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: AppColors.textPrimary),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () { Navigator.of(context).pop(); _pickAvatarFrom(ImageSource.gallery); },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_rounded, color: AppColors.textPrimary),
                  title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () { Navigator.of(context).pop(); _pickAvatarFrom(ImageSource.camera); },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- ЛОГИКА ВЫХОДА ИЗ АККАУНТА ---
  Future<void> _signOut() async {
    HapticFeedback.heavyImpact();
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    // Возвращаем юзера на стартовый экран
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
    );
  }

  // --- UI СБОРКА ---
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
              const SizedBox(height: 32),
              _buildRankedCard(),
              const SizedBox(height: 48),
              _buildAccountActions(),
              const SizedBox(height: 32),
              _buildLogoutButton(), // Новая кнопка выхода
              const SizedBox(height: 60), // Отступ для нижнего меню
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    // Определяем, какую картинку показывать: локально выбранную или ту, что в Firebase
    final displayImagePath = _localAvatarPath ?? widget.user?.avatarPath;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child),
        );
      },
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.subtleBackground,
                    border: Border.all(color: AppColors.surface, width: 4),
                    boxShadow: [BoxShadow(color: AppColors.accentSecondary.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 10))],
                    image: displayImagePath != null
                        ? DecorationImage(image: FileImage(File(displayImagePath)), fit: BoxFit.cover)
                        : null,
                    gradient: displayImagePath == null ? AppColors.primaryGradient : null,
                  ),
                  child: displayImagePath == null
                      ? Center(
                    child: Text(
                      _nickname.isNotEmpty ? _nickname[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  )
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
                  child: const Icon(Icons.edit_rounded, size: 16, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(_nickname, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('LEVEL $_level • $_rankTitle', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.accentPrimary)),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatRow() {
    final stats = [
      {'label': 'Height', 'val': _heightFt},
      {'label': 'Weight', 'val': _formattedWeight},
      {'label': 'Streak', 'val': _streak},
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
        boxShadow: [BoxShadow(color: AppColors.textSecondary.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildRankedCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (widget.user != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LeaderboardScreen(currentUser: widget.user!),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGlow.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.leaderboard_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GLOBAL RANKINGS',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'View Leaderboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white70, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        _buildActionTile(Icons.tune_rounded, 'Preferences', () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PreferencesScreen()),
          );
        }),
        const SizedBox(height: 8),
        _buildActionTile(Icons.history_rounded, 'Workout History', () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => WorkoutHistoryScreen(user: widget.user)),
          );
        }),
        const SizedBox(height: 8),
        _buildActionTile(Icons.notifications_none_rounded, 'Notifications', () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
        }),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () { HapticFeedback.lightImpact(); onTap(); },
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.accentPrimary.withValues(alpha: 0.1),
        highlightColor: AppColors.accentPrimary.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 22),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: _signOut,
      style: TextButton.styleFrom(
        foregroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: const Icon(Icons.logout_rounded),
      label: const Text("Sign Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
    );
  }
}