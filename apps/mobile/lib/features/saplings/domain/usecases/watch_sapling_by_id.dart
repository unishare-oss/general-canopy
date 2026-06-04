import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/repositories/sapling_repository.dart';

class WatchSaplingById {
  const WatchSaplingById(this._repository);
  final SaplingRepository _repository;
  Stream<Sapling> call(String id) => _repository.watchSaplingById(id);
}
