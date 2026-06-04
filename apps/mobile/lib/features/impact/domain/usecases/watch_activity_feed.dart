import 'package:canopy/features/impact/domain/entities/activity_item.dart';
import 'package:canopy/features/impact/domain/repositories/impact_repository.dart';

class WatchActivityFeed {
  const WatchActivityFeed(this._repository);
  final ImpactRepository _repository;

  Stream<List<ActivityItem>> call(String uid) =>
      _repository.watchActivityFeed(uid);
}
