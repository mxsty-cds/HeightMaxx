import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';

/// A reusable, tappable card widget representing a single [HeightTask] mission.
///
/// Displays the task title, optional description, XP reward, category, and
/// completion status. The entire card is tappable via [onTap] to trigger
/// state changes (e.g., marking the task as complete).
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onTap});

  /// The mission data to display.
  final HeightTask task;

  /// Callback function triggered when the card is tapped.
  final VoidCallback? onTap;

  // --- Layout Constants ---
  static const double _borderRadius = 20.0;
  static const EdgeInsets _cardPadding = EdgeInsets.all(20.0);
  static const double _iconSize = 18.0;

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;

    // We wrap the card in a Container to provide the outer decoration (shadow/border)
    // and margin, then use Material+InkWell internally for the ripple effect.
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.white, // Assuming a clean white surface for cards
        borderRadius: BorderRadius.circular(_borderRadius),
        // When completed, show a subtle accent border instead of a shadow
        border: isDone
            ? Border.all(
                color: AppColors.accentPrimary.withAlpha((0.5 * 255).round()),
                width: 1.5,
              )
            : null,
        boxShadow: [
          // Only show elevation shadow if the task is active (not done)
          if (!isDone)
            BoxShadow(
              color: Colors.black.withAlpha((0.06 * 255).round()),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
        ],
      ),
      // Clip material to the rounded corners
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_borderRadius),
          splashColor: AppColors.accentPrimary.withAlpha((0.1 * 255).round()),
          highlightColor: AppColors.accentPrimary.withAlpha((0.05 * 255).round()),
          child: Padding(
            padding: _cardPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTopRow(context, isDone),
                const SizedBox(height: 16),
                _buildFooterRow(context, isDone),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the title, description, and XP badge section.
  Widget _buildTopRow(BuildContext context, bool isDone) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Title and Description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  // Subtle strikethrough if completed
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.accentPrimary.withAlpha(
                    (0.5 * 255).round(),
                  ),
                  decorationThickness: 2.0,
                ),
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Right side: XP Badge
        _buildXpBadge(context, isDone),
      ],
    );
  }

  /// Builds the pill-shaped XP reward indicator.
  Widget _buildXpBadge(BuildContext context, bool isDone) {
    // Slightly mute the accent color if the task is already completed
    final badgeColor = isDone
        ? AppColors.accentPrimary.withAlpha((0.7 * 255).round())
        : AppColors.accentPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        '+${task.xpReward} XP',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: badgeColor,
        ),
      ),
    );
  }

  /// Builds the bottom section with category, time estimate, and completion status.
  Widget _buildFooterRow(BuildContext context, bool isDone) {
    return Row(
      children: [
        // Category Label (Small Caps style)
        Text(
          task.category.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
            color: AppColors.textSecondary.withAlpha((0.8 * 255).round()),
          ),
        ),

        // Optional Time Estimate separator and value
        if (task.estimatedMinutes != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '•',
              style: TextStyle(
                color: AppColors.textSecondary.withAlpha((0.5 * 255).round()),
              ),
            ),
          ),
          Icon(
            Icons.access_time_rounded,
            size: _iconSize * 0.9,
            color: AppColors.textSecondary.withAlpha((0.8 * 255).round()),
          ),
          const SizedBox(width: 4),
          Text(
            '~${task.estimatedMinutes} min',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withAlpha((0.8 * 255).round()),
            ),
          ),
        ],

        const Spacer(),

        // Completion Indicator showing checkmark if done
        if (isDone)
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.accentPrimary,
                size: _iconSize,
              ),
              const SizedBox(width: 6),
              Text(
                'Completed',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentPrimary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
