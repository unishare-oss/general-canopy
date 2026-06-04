import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:canopy/features/discoveries/data/models/discovery_model.dart';

abstract interface class FirestoreDiscoveryDatasource {
  Stream<List<(String id, DiscoveryModel model)>> watchAllDiscoveries();
  Future<(String id, DiscoveryModel model)> getDiscoveryById(String id);
  Future<String> createDiscovery(Map<String, dynamic> data);
  Future<void> updateDiscovery(String id, Map<String, dynamic> data);
  Future<void> deleteDiscovery(String id);
}

class FirestoreDiscoveryDatasourceImpl implements FirestoreDiscoveryDatasource {
  FirestoreDiscoveryDatasourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _discoveries =>
      _firestore.collection('discoveries');

  @override
  Stream<List<(String id, DiscoveryModel model)>> watchAllDiscoveries() =>
      _discoveries
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((doc) => (doc.id, DiscoveryModel.fromJson(doc.data())))
                .toList(),
          );

  @override
  Future<(String id, DiscoveryModel model)> getDiscoveryById(String id) async {
    final doc = await _discoveries.doc(id).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Discovery not found: $id');
    }
    return (doc.id, DiscoveryModel.fromJson(doc.data()!));
  }

  @override
  Future<String> createDiscovery(Map<String, dynamic> data) async {
    final ref = await _discoveries.add(data);
    return ref.id;
  }

  @override
  Future<void> updateDiscovery(String id, Map<String, dynamic> data) =>
      _discoveries.doc(id).update(data);

  @override
  Future<void> deleteDiscovery(String id) => _discoveries.doc(id).delete();
}
