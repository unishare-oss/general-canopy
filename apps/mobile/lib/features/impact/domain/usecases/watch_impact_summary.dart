import 'package:canopy/features/impact/domain/entities/impact_summary.dart';
import 'package:canopy/features/impact/domain/repositories/impact_repository.dart';

class WatchImpactSummary {
  const WatchImpactSummary(this._repository);
  final ImpactRepository _repository;

  Stream<ImpactSummary> call(String uid) => _repository.watchImpactSummary(uid);
}
