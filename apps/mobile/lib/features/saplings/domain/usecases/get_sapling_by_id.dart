import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/repositories/sapling_repository.dart';

class GetSaplingById {
  const GetSaplingById(this._repository);
  final SaplingRepository _repository;
  Future<Sapling> call(String id) => _repository.getSaplingById(id);
}
