import 'package:canopy/features/impact/domain/entities/leaderboard_entry.dart';
import 'package:canopy/features/impact/domain/repositories/impact_repository.dart';

class WatchLeaderboard {
  const WatchLeaderboard(this._repository);
  final ImpactRepository _repository;

  Stream<List<LeaderboardEntry>> call(String neighborhood) =>
      _repository.watchLeaderboard(neighborhood);
}
