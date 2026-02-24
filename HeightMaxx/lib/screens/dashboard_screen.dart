import 'package:flutter/material.dart';

// Твои импорты
import '../models/user.dart';
import 'leaderboard_screen.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.user});
  final UserProfile? user;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  int _selectedChartIndex = 4; // Выбранный день на графике (Пятница)

  void _openLeaderboard() {
    final currentUser = widget.user ?? UserProfile(
      id: 'guest_user',
      username: 'guest',
      nickname: 'Guest',
      fullName: 'Guest',
      totalGrowthCm: 0,
      totalWorkoutsCompleted: 0,
    );

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) => LeaderboardScreen(currentUser: currentUser),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          );
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildAnalyticsSection(), // ГРАФИК ТУТ
                  const SizedBox(height: 32),
                  _buildSkillTree(), // ДРЕВО НАВЫКОВ
                  const SizedBox(height: 32),
                  _buildBentoSocialSection(), // СОЦИАЛКА И РЕЙТИНГ
                  const SizedBox(height: 32),
                  _buildSectionHeader("Active Missions"),
                  const SizedBox(height: 16),
                  _buildMissionList(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. КРУТОЙ ГРАФИК АНАЛИТИКИ ---
  Widget _buildAnalyticsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("XP Analytics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              _buildMultiplierBadge(),
            ],
          ),
          const SizedBox(height: 30),
          _buildBarChart(),
          const SizedBox(height: 20),
          const Center(
            child: Text("You earned 450 XP this week. Top 5%!",
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final List<double> data = [0.3, 0.5, 0.8, 0.4, 0.9, 0.6, 0.7];
    final List<String> days = ["M", "T", "W", "T", "F", "S", "S"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.length, (index) {
        bool isSelected = index == _selectedChartIndex;
        return GestureDetector(
          onTap: () => setState(() => _selectedChartIndex = index),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 120 * data[index],
                width: 34,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : AppColors.subtleBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [BoxShadow(color: AppColors.accentGlow, blurRadius: 8)] : [],
                ),
                child: isSelected ? const Center(child: Icon(Icons.bolt, color: Colors.white, size: 16)) : null,
              ),
              const SizedBox(height: 12),
              Text(days[index], style: TextStyle(
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              )),
            ],
          ),
        );
      }),
    );
  }

  // --- 2. SKILL TREE (НОВАЯ ФИЧА) ---
  Widget _buildSkillTree() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Skill Unlocks"),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSkillItem("Flexibility", Icons.accessibility_new, 0.8, Colors.green),
              _buildSkillItem("Core Power", Icons.fitness_center, 0.4, Colors.blue),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillItem(String title, IconData icon, double progress, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ],
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.subtleBackground,
            color: color,
            borderRadius: BorderRadius.circular(10),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  // --- 3. СОЦИАЛКА (BENTO GRID) ---
  Widget _buildBentoSocialSection() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _openLeaderboard,
            child: Container(
              padding: const EdgeInsets.all(20),
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.black, Colors.grey.shade900]),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Leaderboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                  const Spacer(),
                  _buildFriendRow("Diyor", "1st", "🔥"),
                  const SizedBox(height: 8),
                  _buildFriendRow("Alex", "2nd", "💪"),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Container(
            height: 160,
            decoration: BoxDecoration(color: AppColors.accentPrimary, borderRadius: BorderRadius.circular(32)),
            child: const Center(child: Icon(Icons.share_rounded, color: Colors.white, size: 40)),
          ),
        ),
      ],
    );
  }

  // --- ХЕЛПЕРЫ ---

  Widget _buildModernHeader() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: const Text("Dashboard", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildMultiplierBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: const Text("x1.5 Multiplier 🔥", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }

  Widget _buildFriendRow(String name, String rank, String emoji) {
    return Row(
      children: [
        CircleAvatar(radius: 12, backgroundColor: Colors.white24, child: Text(emoji, style: const TextStyle(fontSize: 10))),
        const SizedBox(width: 8),
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(rank, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5));
  }

  Widget _buildMissionList() {
    // Здесь твои TaskCard из предыдущего кода
    return const Center(child: Text("Missions will load here...", style: TextStyle(color: AppColors.textSecondary)));
  }
}