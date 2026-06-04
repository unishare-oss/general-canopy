import 'package:canopy/features/impact/domain/entities/sapling_streak.dart';
import 'package:canopy/features/impact/domain/repositories/impact_repository.dart';

class WatchSaplingStreaks {
  const WatchSaplingStreaks(this._repository);
  final ImpactRepository _repository;

  Stream<List<SaplingStreak>> call(String uid) =>
      _repository.watchSaplingStreaks(uid);
}
