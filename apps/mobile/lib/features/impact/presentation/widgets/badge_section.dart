import 'package:flutter/material.dart';
import 'package:canopy/features/impact/domain/entities/achievement.dart';
import 'package:canopy/shared/theme/app_colors.dart';

class BadgeSection extends StatelessWidget {
  const BadgeSection({super.key, required this.achievements});

  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'Badges',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (achievements.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'No badges yet — keep growing!',
              style: tt.bodyMedium?.copyWith(color: ac.textMuted),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: achievements.map((a) => _BadgeTile(a)).toList(),
            ),
          ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile(this.achievement);

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: cs.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: tt.labelSmall?.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
