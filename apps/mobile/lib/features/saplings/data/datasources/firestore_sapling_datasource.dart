import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:canopy/features/saplings/data/models/sapling_model.dart';
import 'package:canopy/features/saplings/domain/entities/sapling_exceptions.dart';

abstract interface class FirestoreSaplingDatasource {
  Stream<List<(String id, SaplingModel model)>> watchAvailableSaplings();
  Stream<List<(String id, SaplingModel model)>> watchAllSaplings();
  Future<(String id, SaplingModel model)> getSaplingById(String id);
  Future<void> adoptSapling({
    required String saplingId,
    required String uid,
    required String displayName,
    String? photoUrl,
  });
  Future<void> unadoptSapling({required String saplingId, required String uid});
}

class FirestoreSaplingDatasourceImpl implements FirestoreSaplingDatasource {
  FirestoreSaplingDatasourceImpl(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _saplings =>
      _firestore.collection('saplings');

  @override
  Stream<List<(String id, SaplingModel model)>> watchAvailableSaplings() =>
      _saplings
          .where('status', isEqualTo: 'available')
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((doc) => (doc.id, SaplingModel.fromJson(doc.data())))
                .toList(),
          );

  @override
  Stream<List<(String id, SaplingModel model)>> watchAllSaplings() =>
      _saplings.snapshots().map(
        (snap) => snap.docs
            .map((doc) => (doc.id, SaplingModel.fromJson(doc.data())))
            .toList(),
      );

  @override
  Future<(String id, SaplingModel model)> getSaplingById(String id) async {
    final doc = await _saplings.doc(id).get();
    if (!doc.exists || doc.data() == null) {
      throw SaplingNotFoundException(id);
    }
    return (doc.id, SaplingModel.fromJson(doc.data()!));
  }

  @override
  Future<void> adoptSapling({
    required String saplingId,
    required String uid,
    required String displayName,
    String? photoUrl,
  }) async {
    await _firestore.runTransaction((txn) async {
      final ref = _saplings.doc(saplingId);
      final snapshot = await txn.get(ref);
      if (!snapshot.exists || snapshot.data()?['status'] != 'available') {
        throw const SaplingAlreadyAdoptedException();
      }
      txn.update(ref, {
        'status': 'adopted',
        'adoptedBy': uid,
        'adoptedByName': displayName,
        // ignore: use_null_aware_elements
        if (photoUrl != null) 'adoptedByPhotoUrl': photoUrl,
        'adoptedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> unadoptSapling({
    required String saplingId,
    required String uid,
  }) async {
    await _firestore.runTransaction((txn) async {
      final ref = _saplings.doc(saplingId);
      final snapshot = await txn.get(ref);
      final data = snapshot.data();
      if (!snapshot.exists ||
          data?['status'] != 'adopted' ||
          data?['adoptedBy'] != uid) {
        throw const SaplingNotAdoptedByUserException();
      }
      txn.update(ref, {
        'status': 'available',
        'adoptedBy': FieldValue.delete(),
        'adoptedByName': FieldValue.delete(),
        'adoptedByPhotoUrl': FieldValue.delete(),
        'adoptedAt': FieldValue.delete(),
      });
    });
  }
}
