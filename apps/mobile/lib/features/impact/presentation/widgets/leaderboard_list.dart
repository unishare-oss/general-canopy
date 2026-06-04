import 'package:flutter/material.dart';
import 'package:canopy/features/impact/domain/entities/leaderboard_entry.dart';
import 'package:canopy/shared/theme/app_colors.dart';

class LeaderboardList extends StatelessWidget {
  const LeaderboardList({super.key, required this.entries});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No one here yet — be the first!',
            style: tt.bodyMedium?.copyWith(color: ac.textMuted),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, i) => _LeaderboardTile(entry: entries[i]),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    final isTopThree = entry.rank <= 3;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${entry.rank}',
              style: tt.labelLarge?.copyWith(
                color: isTopThree ? cs.primary : ac.textMuted,
                fontWeight: isTopThree ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: ac.muted),
            child: Center(
              child: Text(
                entry.displayName.isNotEmpty
                    ? entry.displayName[0].toUpperCase()
                    : '?',
                style: tt.labelLarge?.copyWith(color: cs.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.displayName,
              style: tt.bodyMedium?.copyWith(color: cs.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${entry.co2OffsetKg.toStringAsFixed(1)} kg',
            style: tt.bodySmall?.copyWith(
              color: ac.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
