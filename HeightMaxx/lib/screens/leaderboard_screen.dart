// lib/screens/leaderboard_screen.dart
//
// A dynamic, competitive progression screen. Combines a personal rank
// dashboard with a global, sorted leaderboard list.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../models/rank_tier.dart';
import '../utils/leaderboard_utils.dart';
import '../theme/app_colors.dart';

class LeaderboardScreen extends StatefulWidget {
  final UserProfile currentUser;

  const LeaderboardScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<UserProfile> _leaderboard = [];
  bool _isGlobal = true; // Toggle for Global vs Friends

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  void _loadLeaderboard() {
    // 1. Generate Bots
    List<UserProfile> users = LeaderboardUtils.generateBotUsers(25);
    
    // 2. Inject Current User
    users.add(widget.currentUser);

    // 3. Sort by computed score (Descending)
    users.sort((a, b) {
      int scoreA = LeaderboardUtils.getScoreForUser(a);
      int scoreB = LeaderboardUtils.getScoreForUser(b);
      return scoreB.compareTo(scoreA); // Highest first
    });

    setState(() {
      _leaderboard = users;
    });
  }

  int get _currentUserRankIndex {
    return _leaderboard.indexWhere((u) => u.id == widget.currentUser.id) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildPersonalRankHeader(),
            _buildTabToggles(),
            Expanded(
              child: _buildLeaderboardList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            tooltip: 'Back',
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Global Leaderboard',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                // User rank chip shown prominently in the header
                if (_leaderboard.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "You're #$_currentUserRankIndex this week",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPersonalRankHeader() {
    final int myScore = LeaderboardUtils.getScoreForUser(widget.currentUser);
    final RankTier myTier = RankSystem.getRankForScore(myScore);
    final RankTier? nextTier = RankSystem.getNextRank(myScore);
    final int myRankPosition = _currentUserRankIndex;

    double progressToNext = 1.0;
    int pointsNeeded = 0;
    
    if (nextTier != null) {
      final int range = nextTier.minScore - myTier.minScore;
      final int currentProgress = myScore - myTier.minScore;
      progressToNext = (currentProgress / range).clamp(0.0, 1.0);
      pointsNeeded = nextTier.minScore - myScore;
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: myTier.color.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: myTier.color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    myTier.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: myTier.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Global #$myRankPosition',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    tooltip: 'Close leaderboard',
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: myTier.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(myTier.icon, color: myTier.color, size: 32),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressToNext,
              minHeight: 10,
              backgroundColor: AppColors.subtleBackground,
              valueColor: AlwaysStoppedAnimation<Color>(myTier.color),
            ),
          ),
          const SizedBox(height: 12),
          
          // Encouragement Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$myScore Pts',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              if (nextTier != null)
                Text(
                  'Only $pointsNeeded pts to ${nextTier.name}!',
                  style: TextStyle(fontWeight: FontWeight.w700, color: myTier.color),
                )
              else
                const Text(
                  'Max Rank Achieved!',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabToggles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.subtleBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(child: _buildTabButton('Global', true)),
            Expanded(child: _buildTabButton('Friends', false)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isGlobalTab) {
    final isSelected = _isGlobal == isGlobalTab;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _isGlobal = isGlobalTab);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    if (!_isGlobal) {
      return const Center(
        child: Text('Add friends to see them here!', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      itemCount: _leaderboard.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = _leaderboard[index];
        final isMe = user.id == widget.currentUser.id;
        final rank = index + 1;
        final score = LeaderboardUtils.getScoreForUser(user);
        final tier = RankSystem.getRankForScore(score);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 50).clamp(0, 500)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: isMe ? Border.all(color: AppColors.accentPrimary, width: 2) : null,
              boxShadow: [
                BoxShadow(
                  color: isMe ? AppColors.accentGlow : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isMe ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Rank Number
                SizedBox(
                  width: 32,
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: rank <= 3 ? tier.color : AppColors.textMuted,
                    ),
                  ),
                ),
                
                // Rank Badge
                Icon(tier.icon, color: tier.color, size: 24),
                const SizedBox(width: 16),
                
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMe ? 'You' : user.nickname,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${user.totalGrowthCm?.toStringAsFixed(1) ?? "0.0"} cm • ${user.streakDays}🔥',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                
                // Score
                Text(
                  score.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}