import 'package:flutter/material.dart';
import 'package:canopy/features/impact/domain/entities/activity_item.dart';
import 'package:canopy/features/impact/domain/entities/activity_type.dart';
import 'package:canopy/shared/theme/app_colors.dart';

class ActivityFeedList extends StatelessWidget {
  const ActivityFeedList({super.key, required this.items});

  final List<ActivityItem> items;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No activity yet',
            style: tt.bodyMedium?.copyWith(color: ac.textMuted),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, i) => _FeedTile(item: items[i]),
    );
  }
}

class _FeedTile extends StatelessWidget {
  const _FeedTile({required this.item});

  final ActivityItem item;

  IconData _iconFor(ActivityType type) => switch (type) {
    ActivityType.adopted => Icons.park_rounded,
    ActivityType.watered => Icons.water_drop_rounded,
    ActivityType.milestoneReached => Icons.emoji_events_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    final now = DateTime.now();
    final diff = now.difference(item.timestamp);
    final timeLabel = diff.inDays > 0
        ? '${diff.inDays}d ago'
        : diff.inHours > 0
        ? '${diff.inHours}h ago'
        : 'Just now';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withValues(alpha: 0.1),
            ),
            child: Icon(_iconFor(item.type), size: 18, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  timeLabel,
                  style: tt.bodySmall?.copyWith(color: ac.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
