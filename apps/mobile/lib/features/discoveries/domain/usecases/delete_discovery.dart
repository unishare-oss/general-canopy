import 'package:canopy/features/discoveries/domain/repositories/discovery_repository.dart';

class DeleteDiscovery {
  const DeleteDiscovery(this._repository);

  final DiscoveryRepository _repository;

  Future<void> call(String id) => _repository.deleteDiscovery(id);
}
