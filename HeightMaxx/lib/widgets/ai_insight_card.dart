// lib/widgets/ai_insight_card.dart
//
// A dynamic, animated card displaying motivational and biometric insights.
// Allows the user to shuffle through tips with a smooth fade transition.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class AiInsightCard extends StatefulWidget {
  const AiInsightCard({super.key});

  @override
  State<AiInsightCard> createState() => _AiInsightCardState();
}

class _AiInsightCardState extends State<AiInsightCard> {
  final Random _random = Random();
  int _currentIndex = 0;

  // A curated list of on-brand, actionable insights.
  final List<String> _insights = [
    'Your spine hydration is optimal today. Excellent job staying consistent!',
    'Try adding 5 minutes of dead-hanging to your routine for deep decompression.',
    'Consistent sleep between 8–9 hours naturally boosts growth hormone production.',
    'Perfect posture isn\'t built in a day. Focus on small, frequent alignments.',
    'Hydration directly affects spinal disc volume. Keep drinking water!',
    'A strong core acts as a natural corset, supporting your spine and maximizing height.',
  ];

  @override
  void initState() {
    super.initState();
    // Start with a random tip
    _currentIndex = _random.nextInt(_insights.length);
  }

  void _shuffleInsight() {
    HapticFeedback.selectionClick();
    setState(() {
      int newIndex;
      do {
        newIndex = _random.nextInt(_insights.length);
      } while (newIndex == _currentIndex && _insights.length > 1);
      _currentIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentSecondary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.subtleBackground, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.accentPrimary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'AI INSIGHT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _shuffleInsight,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.subtleBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shuffle_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Smooth text transition
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: Text(
              _insights[_currentIndex],
              key: ValueKey<int>(_currentIndex), // Key forces the Switcher to animate
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}