import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:canopy/features/auth/presentation/providers/current_user_provider.dart';
import 'package:canopy/features/grove/presentation/providers/grove_providers.dart';
import 'package:canopy/features/impact/data/datasources/firestore_impact_datasource.dart';
import 'package:canopy/features/impact/data/repositories/impact_repository_impl.dart';
import 'package:canopy/features/impact/domain/entities/achievement.dart';
import 'package:canopy/features/impact/domain/entities/activity_item.dart';
import 'package:canopy/features/impact/domain/entities/impact_equivalent.dart';
import 'package:canopy/features/impact/domain/entities/impact_summary.dart';
import 'package:canopy/features/impact/domain/entities/leaderboard_entry.dart';
import 'package:canopy/features/impact/domain/entities/sapling_streak.dart';
import 'package:canopy/features/impact/domain/repositories/impact_repository.dart';
import 'package:canopy/features/impact/domain/usecases/compute_impact_equivalents.dart';
import 'package:canopy/features/impact/domain/usecases/watch_achievements.dart';
import 'package:canopy/features/impact/domain/usecases/watch_activity_feed.dart';
import 'package:canopy/features/impact/domain/usecases/watch_impact_summary.dart';
import 'package:canopy/features/impact/domain/usecases/watch_leaderboard.dart';
import 'package:canopy/features/impact/domain/usecases/watch_sapling_streaks.dart';

final impactRepositoryProvider = Provider<ImpactRepository>(
  (ref) => ImpactRepositoryImpl(
    FirestoreImpactDatasource(FirebaseFirestore.instance),
  ),
);

final impactSummaryProvider = StreamProvider.autoDispose<ImpactSummary>((ref) {
  final uid = ref
      .watch(currentUserProvider)
      .maybeWhen(data: (u) => u?.id, orElse: () => null);
  if (uid == null) return Stream.value(ImpactSummary.zero());
  return WatchImpactSummary(ref.watch(impactRepositoryProvider))(uid);
});

final saplingStreaksProvider = StreamProvider.autoDispose<List<SaplingStreak>>((
  ref,
) {
  final uid = ref
      .watch(currentUserProvider)
      .maybeWhen(data: (u) => u?.id, orElse: () => null);
  if (uid == null) return Stream.value([]);
  return WatchSaplingStreaks(ref.watch(impactRepositoryProvider))(uid);
});

final achievementsProvider = StreamProvider.autoDispose<List<Achievement>>((
  ref,
) {
  final uid = ref
      .watch(currentUserProvider)
      .maybeWhen(data: (u) => u?.id, orElse: () => null);
  if (uid == null) return Stream.value([]);
  return WatchAchievements(ref.watch(impactRepositoryProvider))(uid);
});

final leaderboardProvider = StreamProvider.autoDispose
    .family<List<LeaderboardEntry>, String>(
      (ref, neighborhood) =>
          WatchLeaderboard(ref.watch(impactRepositoryProvider))(neighborhood),
    );

final activityFeedProvider = StreamProvider.autoDispose<List<ActivityItem>>((
  ref,
) {
  final uid = ref
      .watch(currentUserProvider)
      .maybeWhen(data: (u) => u?.id, orElse: () => null);
  if (uid == null) return Stream.value([]);
  return WatchActivityFeed(ref.watch(impactRepositoryProvider))(uid);
});

// Derives adoptedCount as max(impactSummary, saplingStreaks, groveAdoptions)
// so the count is accurate even when impactSummary/current or saplingAdoptions
// haven't been written yet (trees adopted before the backfill fix).
final effectiveImpactSummaryProvider = Provider.autoDispose<ImpactSummary>((
  ref,
) {
  final summary = ref.watch(impactSummaryProvider).maybeWhen(
    data: (s) => s,
    orElse: ImpactSummary.zero,
  );
  final streakCount = ref.watch(saplingStreaksProvider).maybeWhen(
    data: (s) => s.length,
    orElse: () => 0,
  );
  final groveCount = ref.watch(myGroveProvider).maybeWhen(
    data: (s) => s.length,
    orElse: () => 0,
  );
  final count = [summary.adoptedCount, streakCount, groveCount]
      .fold(0, (a, b) => a > b ? a : b);
  if (count == summary.adoptedCount) return summary;
  return ImpactSummary(
    co2OffsetKg: summary.co2OffsetKg,
    waterGivenLiters: summary.waterGivenLiters,
    totalSurvivalDays: summary.totalSurvivalDays,
    adoptedCount: count,
    lastUpdated: summary.lastUpdated,
  );
});

final impactEquivalentsProvider = Provider.autoDispose<List<ImpactEquivalent>>((
  ref,
) {
  final summary = ref.watch(effectiveImpactSummaryProvider);
  return const ComputeImpactEquivalents()(summary);
});
