import 'package:canopy/features/discoveries/domain/entities/discovery.dart';
import 'package:canopy/features/discoveries/domain/repositories/discovery_repository.dart';

class UpdateDiscovery {
  const UpdateDiscovery(this._repository);

  final DiscoveryRepository _repository;

  Future<void> call(Discovery discovery) =>
      _repository.updateDiscovery(discovery);
}
