import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:canopy/features/discoveries/data/datasources/firestore_discovery_datasource.dart';
import 'package:canopy/features/discoveries/domain/entities/discovery.dart';
import 'package:canopy/features/discoveries/domain/repositories/discovery_repository.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  const DiscoveryRepositoryImpl(this._datasource);

  final FirestoreDiscoveryDatasource _datasource;

  @override
  Stream<List<Discovery>> watchAllDiscoveries() => _datasource
      .watchAllDiscoveries()
      .map((records) => records.map((r) => r.$2.toEntity(r.$1)).toList());

  @override
  Future<Discovery> getDiscoveryById(String id) async {
    final (docId, model) = await _datasource.getDiscoveryById(id);
    return model.toEntity(docId);
  }

  @override
  Future<String> createDiscovery(Discovery discovery) {
    final data = {
      'title': discovery.title,
      'description': discovery.description,
      'category': discovery.category,
      'lat': discovery.lat,
      'lng': discovery.lng,
      'neighborhood': discovery.neighborhood,
      'colorHex': discovery.colorHex,
      'createdBy': discovery.createdBy,
      if (discovery.photoUrl != null) 'photoUrl': discovery.photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
    return _datasource.createDiscovery(data);
  }

  @override
  Future<void> updateDiscovery(Discovery discovery) {
    final data = <String, dynamic>{
      'title': discovery.title,
      'description': discovery.description,
      'category': discovery.category,
      'lat': discovery.lat,
      'lng': discovery.lng,
      'neighborhood': discovery.neighborhood,
      'colorHex': discovery.colorHex,
      if (discovery.photoUrl != null)
        'photoUrl': discovery.photoUrl
      else
        'photoUrl': FieldValue.delete(),
    };
    return _datasource.updateDiscovery(discovery.id, data);
  }

  @override
  Future<void> deleteDiscovery(String id) => _datasource.deleteDiscovery(id);
}
