import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/repositories/sapling_repository.dart';

class GetAvailableSaplings {
  const GetAvailableSaplings(this._repository);
  final SaplingRepository _repository;
  Stream<List<Sapling>> call() => _repository.getAvailableSaplings();
}
