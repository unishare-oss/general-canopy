import 'package:canopy/features/grove/domain/entities/adopted_sapling.dart';
import 'package:canopy/features/grove/domain/repositories/grove_repository.dart';

class WatchMyGrove {
  const WatchMyGrove(this._repository);
  final GroveRepository _repository;

  Stream<List<AdoptedSapling>> call(String uid) =>
      _repository.watchMyGrove(uid);
}
