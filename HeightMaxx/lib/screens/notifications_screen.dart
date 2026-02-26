// lib/screens/notifications_screen.dart
//
// Displays in-app notifications and reminders.
// Currently shows a structured placeholder list.
// TODO: Wire up to a real notifications service / Firestore collection.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // TODO: Load real notifications from backend/Firestore.
  final List<_NotificationItem> _notifications = _buildPlaceholderNotifications();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                setState(() {
                  for (final n in _notifications) {
                    n.isRead = true;
                  }
                });
              },
              child: const Text(
                'Mark all read',
                style: TextStyle(
                    color: AppColors.accentPrimary,
                    fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _notifications[index];
                return _NotificationCard(
                  item: item,
                  onTap: () => setState(() => item.isRead = true),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No new notifications.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// TODO: Replace with a real Notification model fetched from Firestore.
class _NotificationItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String timeAgo;
  bool isRead;

  _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
  });
}

List<_NotificationItem> _buildPlaceholderNotifications() {
  return [
    _NotificationItem(
      icon: Icons.local_fire_department_rounded,
      iconColor: Colors.orange,
      title: 'Streak Alert!',
      body: 'Don\'t forget to train today to keep your streak alive.',
      timeAgo: '2h ago',
    ),
    _NotificationItem(
      icon: Icons.bolt_rounded,
      iconColor: AppColors.accentPrimary,
      title: 'New Level Unlocked',
      body: 'Congrats! You\'ve reached a new level. Check your rewards.',
      timeAgo: '1d ago',
      isRead: true,
    ),
    _NotificationItem(
      icon: Icons.leaderboard_rounded,
      iconColor: Colors.amber,
      title: 'Leaderboard Update',
      body: 'You moved up 3 spots on the global leaderboard this week!',
      timeAgo: '2d ago',
    ),
    _NotificationItem(
      icon: Icons.fitness_center_rounded,
      iconColor: Colors.green,
      title: 'Workout Reminder',
      body: 'Your scheduled Spine Decompression session starts in 30 minutes.',
      timeAgo: '3d ago',
      isRead: true,
    ),
  ];
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.isRead ? AppColors.surface : AppColors.accentPrimary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w900,
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accentPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.timeAgo,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
