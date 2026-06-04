import 'package:canopy/features/impact/domain/entities/achievement.dart';
import 'package:canopy/features/impact/domain/repositories/impact_repository.dart';

class WatchAchievements {
  const WatchAchievements(this._repository);
  final ImpactRepository _repository;

  Stream<List<Achievement>> call(String uid) =>
      _repository.watchAchievements(uid);
}
