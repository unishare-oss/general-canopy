import 'package:canopy/features/discoveries/domain/entities/discovery.dart';
import 'package:canopy/features/discoveries/domain/repositories/discovery_repository.dart';

class WatchAllDiscoveries {
  const WatchAllDiscoveries(this._repository);

  final DiscoveryRepository _repository;

  Stream<List<Discovery>> call() => _repository.watchAllDiscoveries();
}
