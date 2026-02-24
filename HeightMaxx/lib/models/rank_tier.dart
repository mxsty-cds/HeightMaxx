// lib/models/rank_tier.dart
//
// Defines the competitive rank tiers for the HeightMaxx leaderboard.

import 'package:flutter/material.dart';

class RankTier {
  final String name;
  final int minScore;
  final Color color;
  final IconData icon;

  const RankTier({
    required this.name,
    required this.minScore,
    required this.color,
    required this.icon,
  });
}

/// A centralized registry of all available rank tiers.
class RankSystem {
  static const List<RankTier> tiers = [
    RankTier(name: 'Bronze', minScore: 0, color: Color(0xFFCD7F32), icon: Icons.shield_outlined),
    RankTier(name: 'Silver', minScore: 200, color: Color(0xFF9CA3AF), icon: Icons.shield),
    RankTier(name: 'Gold', minScore: 500, color: Color(0xFFF59E0B), icon: Icons.workspace_premium),
    RankTier(name: 'Platinum', minScore: 1000, color: Color(0xFF06B6D4), icon: Icons.diamond_outlined),
    RankTier(name: 'Diamond', minScore: 2500, color: Color(0xFF3B82F6), icon: Icons.diamond),
    RankTier(name: 'Master', minScore: 5000, color: Color(0xFF8B5CF6), icon: Icons.military_tech),
    RankTier(name: 'Giant', minScore: 10000, color: Color(0xFFEF4444), icon: Icons.whatshot),
  ];

  /// Calculates the current tier based on a user's total score.
  static RankTier getRankForScore(int score) {
    // Reverse the list to find the highest tier the user qualifies for
    for (var tier in tiers.reversed) {
      if (score >= tier.minScore) {
        return tier;
      }
    }
    return tiers.first; // Default to Bronze
  }

  /// Calculates the next tier the user is working towards.
  static RankTier? getNextRank(int score) {
    for (var tier in tiers) {
      if (score < tier.minScore) {
        return tier;
      }
    }
    return null; // User is at the highest rank (Giant)
  }
}