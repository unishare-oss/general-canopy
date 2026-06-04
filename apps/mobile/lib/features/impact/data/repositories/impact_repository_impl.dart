import 'package:canopy/features/impact/data/datasources/firestore_impact_datasource.dart';
import 'package:canopy/features/impact/domain/entities/achievement.dart';
import 'package:canopy/features/impact/domain/entities/activity_item.dart';
import 'package:canopy/features/impact/domain/entities/impact_summary.dart';
import 'package:canopy/features/impact/domain/entities/leaderboard_entry.dart';
import 'package:canopy/features/impact/domain/entities/sapling_streak.dart';
import 'package:canopy/features/impact/domain/repositories/impact_repository.dart';

class ImpactRepositoryImpl implements ImpactRepository {
  const ImpactRepositoryImpl(this._datasource);

  final FirestoreImpactDatasource _datasource;

  @override
  Stream<ImpactSummary> watchImpactSummary(String uid) =>
      _datasource.watchImpactSummary(uid).map((m) => m.toEntity());

  @override
  Stream<List<SaplingStreak>> watchSaplingStreaks(String uid) => _datasource
      .watchSaplingAdoptions(uid)
      .map((list) => list.map((m) => m.toEntity()).toList());

  @override
  Stream<List<Achievement>> watchAchievements(String uid) => _datasource
      .watchAchievements(uid)
      .map((list) => list.map((m) => m.toEntity()).toList());

  @override
  Stream<List<LeaderboardEntry>> watchLeaderboard(String neighborhood) =>
      _datasource.watchLeaderboard(neighborhood).map((list) {
        return list.indexed
            .map((entry) => entry.$2.toEntity(entry.$1 + 1))
            .toList();
      });

  @override
  Stream<List<ActivityItem>> watchActivityFeed(String uid) => _datasource
      .watchActivityFeed(uid)
      .map((list) => list.map((m) => m.toEntity()).toList());
}
