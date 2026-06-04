import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:canopy/features/auth/presentation/providers/current_user_provider.dart';
import 'package:canopy/features/impact/domain/entities/leaderboard_entry.dart';
import 'package:canopy/features/impact/presentation/providers/impact_providers.dart';
import 'package:canopy/features/impact/presentation/widgets/leaderboard_list.dart';
import 'package:canopy/shared/theme/app_colors.dart';

class LeadersTab extends ConsumerWidget {
  const LeadersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final neighborhood = ref
        .watch(currentUserProvider)
        .maybeWhen(data: (u) => u?.neighborhood, orElse: () => null);

    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    if (neighborhood == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Complete your profile to see your neighborhood ranking.',
            style: tt.bodyMedium?.copyWith(color: ac.textMuted),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final leaderboardAsync = ref.watch(leaderboardProvider(neighborhood));
    final entries = leaderboardAsync.maybeWhen(
      data: (e) => e,
      orElse: () => <LeaderboardEntry>[],
    );

    return LeaderboardList(entries: entries);
  }
}
