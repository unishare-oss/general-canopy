import 'package:canopy/features/discoveries/domain/entities/discovery.dart';

abstract interface class DiscoveryRepository {
  Stream<List<Discovery>> watchAllDiscoveries();
  Future<Discovery> getDiscoveryById(String id);
  Future<String> createDiscovery(Discovery discovery);
  Future<void> updateDiscovery(Discovery discovery);
  Future<void> deleteDiscovery(String id);
}
