import 'package:canopy/features/discoveries/domain/entities/discovery.dart';
import 'package:canopy/features/discoveries/domain/repositories/discovery_repository.dart';

class CreateDiscovery {
  const CreateDiscovery(this._repository);

  final DiscoveryRepository _repository;

  Future<String> call(Discovery discovery) =>
      _repository.createDiscovery(discovery);
}
