import 'package:canopy/features/discoveries/domain/entities/discovery.dart';
import 'package:canopy/features/discoveries/domain/repositories/discovery_repository.dart';

class GetDiscoveryById {
  const GetDiscoveryById(this._repository);

  final DiscoveryRepository _repository;

  Future<Discovery> call(String id) => _repository.getDiscoveryById(id);
}
