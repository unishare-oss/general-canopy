import 'package:flutter/material.dart';
import 'package:canopy/features/impact/domain/entities/sapling_streak.dart';
import 'package:canopy/shared/theme/app_colors.dart';

class StreakSection extends StatelessWidget {
  const StreakSection({super.key, required this.streaks});

  final List<SaplingStreak> streaks;

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
            'Survival streak',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (streaks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'No saplings yet',
              style: tt.bodyMedium?.copyWith(color: ac.textMuted),
            ),
          )
        else
          ...streaks.map((s) => _StreakTile(streak: s)),
      ],
    );
  }
}

class _StreakTile extends StatelessWidget {
  const _StreakTile({required this.streak});

  final SaplingStreak streak;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    final indicatorColor = streak.isActive ? ac.success : ac.amber;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: indicatorColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              streak.nickname,
              style: tt.bodyMedium?.copyWith(color: cs.onSurface),
            ),
          ),
          Text(
            '${streak.streakDays} d',
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
