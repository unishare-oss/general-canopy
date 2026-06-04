import 'package:canopy/features/impact/domain/entities/achievement.dart';
import 'package:canopy/features/impact/domain/entities/activity_item.dart';
import 'package:canopy/features/impact/domain/entities/impact_summary.dart';
import 'package:canopy/features/impact/domain/entities/leaderboard_entry.dart';
import 'package:canopy/features/impact/domain/entities/sapling_streak.dart';

abstract interface class ImpactRepository {
  Stream<ImpactSummary> watchImpactSummary(String uid);
  Stream<List<SaplingStreak>> watchSaplingStreaks(String uid);
  Stream<List<Achievement>> watchAchievements(String uid);
  Stream<List<LeaderboardEntry>> watchLeaderboard(String neighborhood);
  Stream<List<ActivityItem>> watchActivityFeed(String uid);
}
