import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- Данные пользователя (Mock) ---
  final double height = 175;
  final double weight = 70;
  final int streak = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Красивая шапка, которая сжимается при скролле
          _buildSliverAppBar(),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 2. Сетка метрик (Height, Weight, Streak)
                _appearAnimation(index: 1, child: _buildBiometricsGrid()),

                const SizedBox(height: 32),
                _appearAnimation(index: 2, child: _buildSectionLabel("Account")),
                const SizedBox(height: 16),

                // 3. Группа настроек
                _appearAnimation(index: 3, child: _buildSettingsGroup([
                  _buildSettingsTile(Icons.person_outline_rounded, "Personal Info", "Name, email, etc."),
                  _buildSettingsTile(Icons.notifications_none_rounded, "Notifications", "Manage alerts"),
                  _buildSettingsTile(Icons.lock_outline_rounded, "Security", "Password & privacy"),
                ])),

                const SizedBox(height: 32),
                _appearAnimation(index: 4, child: _buildSectionLabel("Support")),
                const SizedBox(height: 16),

                _appearAnimation(index: 5, child: _buildSettingsGroup([
                  _buildSettingsTile(Icons.help_outline_rounded, "Help Center", null),
                  _buildSettingsTile(Icons.star_border_rounded, "Rate Us", null),
                ])),

                const SizedBox(height: 48),

                // 4. Кнопка выхода (Исправлена!)
                _appearAnimation(index: 6, child: _buildLogoutButton()),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- ШАПКА ---
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildAvatar(),
              const SizedBox(height: 16),
              const Text(
                "Alex Johnson",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              const Text(
                "LEVEL 12 • PRO MOVER",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.accentPrimary, letterSpacing: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
      child: const CircleAvatar(
        radius: 54,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
        ),
      ),
    );
  }

  // --- МЕТРИКИ (BENTO GRID) ---
  Widget _buildBiometricsGrid() {
    return Row(
      children: [
        _buildMetricCard("Height", "$height", "cm", AppColors.accentPrimary),
        const SizedBox(width: 12),
        _buildMetricCard("Weight", "$weight", "kg", AppColors.accentSecondary),
        const SizedBox(width: 12),
        _buildMetricCard("Streak", "$streak", "days", Colors.orange),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, String unit, Color color) {
    return Expanded( // Expanded спасает от Right Overflow
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            FittedBox( // FittedBox сжимает текст, если он не влезает
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(width: 2),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(unit, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ГРУППА НАСТРОЕК ---
  Widget _buildSettingsGroup(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: List.generate(tiles.length, (index) {
          return Column(
            children: [
              tiles[index],
              if (index != tiles.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 1, color: AppColors.background),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String? subtitle) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => HapticFeedback.lightImpact(),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: AppColors.textPrimary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    if (subtitle != null)
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- КНОПКА ВЫХОДА (ИСПРАВЛЕННАЯ) ---
  Widget _buildLogoutButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () => HapticFeedback.mediumImpact(),
        style: TextButton.styleFrom(
          foregroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text("Log Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.textSecondary),
    );
  }

  Widget _appearAnimation({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 15 * (1 - value)), child: child),
        );
      },
      child: child,
    );
  }
}