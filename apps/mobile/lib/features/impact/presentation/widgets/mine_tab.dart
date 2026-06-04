import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:canopy/features/impact/domain/entities/achievement.dart';
import 'package:canopy/features/impact/domain/entities/impact_summary.dart';
import 'package:canopy/features/impact/domain/entities/sapling_streak.dart';
import 'package:canopy/features/impact/presentation/providers/impact_providers.dart';
import 'package:canopy/features/impact/presentation/widgets/badge_section.dart';
import 'package:canopy/features/impact/presentation/widgets/equivalents_section.dart';
import 'package:canopy/features/impact/presentation/widgets/impact_hero_card.dart';
import 'package:canopy/features/impact/presentation/widgets/stat_card.dart';
import 'package:canopy/features/impact/presentation/widgets/streak_section.dart';
import 'package:canopy/shared/theme/app_colors.dart';

class MineTab extends ConsumerWidget {
  const MineTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(impactSummaryProvider);
    final streaksAsync = ref.watch(saplingStreaksProvider);
    final achievementsAsync = ref.watch(achievementsProvider);
    final equivalents = ref.watch(impactEquivalentsProvider);

    final summary = summaryAsync.maybeWhen(
      data: (s) => s,
      orElse: ImpactSummary.zero,
    );
    final streaks = streaksAsync.maybeWhen(
      data: (s) => s,
      orElse: () => <SaplingStreak>[],
    );
    final achievements = achievementsAsync.maybeWhen(
      data: (a) => a,
      orElse: () => <Achievement>[],
    );

    final maxStreakDays = streaks.isEmpty
        ? 0
        : streaks.map((s) => s.streakDays).fold(0, (a, b) => a > b ? a : b);

    final carMilesOffset = equivalents.isNotEmpty
        ? equivalents.first.value
        : 0.0;

    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 100),
          children: [
            ImpactHeroCard(
              summary: summary,
              maxStreakDays: maxStreakDays,
              carMilesOffset: carMilesOffset,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                    value: '${summary.adoptedCount}',
                    unit: '',
                    label: 'Adopted',
                    iconColor: ac.success,
                  ),
                  StatCard(
                    value: '$maxStreakDays',
                    unit: 'd',
                    label: 'Streak',
                    iconColor: ac.amber,
                  ),
                  StatCard(
                    value: summary.waterGivenLiters.toStringAsFixed(0),
                    unit: 'L',
                    label: 'Water given',
                    iconColor: ac.info,
                  ),
                  StatCard(
                    value: summary.co2OffsetKg.toStringAsFixed(0),
                    unit: 'kg',
                    label: 'CO₂ absorbed',
                    iconColor: ac.success,
                  ),
                ],
              ),
            ),
            EquivalentsSection(equivalents: equivalents),
            StreakSection(streaks: streaks),
            BadgeSection(achievements: achievements),
            const SizedBox(height: 16),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _share(summary),
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            child: const Icon(Icons.share_rounded),
          ),
        ),
      ],
    );
  }

  Future<void> _share(ImpactSummary summary) async {
    final text =
        'My Canopy grove has offset ${summary.co2OffsetKg.toStringAsFixed(1)} kg '
        'of CO₂ and given ${summary.waterGivenLiters.toStringAsFixed(1)} L '
        'of water to ${summary.adoptedCount} sapling${summary.adoptedCount == 1 ? '' : 's'}. '
        '🌳 #Canopy';
    try {
      await Share.share(text);
    } catch (_) {}
  }
}
