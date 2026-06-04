import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:canopy/features/saplings/data/models/sapling_model.dart';
import 'package:canopy/features/saplings/domain/entities/sapling_exceptions.dart';

abstract interface class FirestoreSaplingDatasource {
  Stream<List<(String id, SaplingModel model)>> watchAvailableSaplings();
  Stream<List<(String id, SaplingModel model)>> watchAllSaplings();
  Future<(String id, SaplingModel model)> getSaplingById(String id);
  Stream<(String id, SaplingModel model)> watchSaplingById(String id);
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
  Stream<(String id, SaplingModel model)> watchSaplingById(String id) =>
      _saplings.doc(id).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) throw SaplingNotFoundException(id);
        return (doc.id, SaplingModel.fromJson(doc.data()!));
      });

  DocumentReference<Map<String, dynamic>> _adoptionRef(
    String uid,
    String saplingId,
  ) => _firestore
      .collection('users')
      .doc(uid)
      .collection('adoptions')
      .doc(saplingId);

  DocumentReference<Map<String, dynamic>> _saplingAdoptionRef(
    String uid,
    String saplingId,
  ) => _firestore
      .collection('users')
      .doc(uid)
      .collection('saplingAdoptions')
      .doc(saplingId);

  DocumentReference<Map<String, dynamic>> _impactSummaryRef(String uid) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('impactSummary')
          .doc('current');

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
      final data = snapshot.data()!;
      final wateringInterval = (data['wateringIntervalDays'] as int?) ?? 3;

      txn.update(ref, {
        'status': 'adopted',
        'adoptedBy': uid,
        'adoptedByName': displayName,
        // ignore: use_null_aware_elements
        if (photoUrl != null) 'adoptedByPhotoUrl': photoUrl,
        'adoptedAt': FieldValue.serverTimestamp(),
      });

      txn.set(_adoptionRef(uid, saplingId), {
        'saplingId': saplingId,
        'nickname': data['nickname'],
        'species': data['species'],
        'street': data['street'] ?? '',
        'neighborhood': data['neighborhood'],
        'colorHex': data['color'],
        'photoUrl': data['photoUrl'],
        'coverPhotoUrl': data['photoUrl'],
        'adoptedAt': FieldValue.serverTimestamp(),
        'healthScore': 80,
        'nextActionAt': Timestamp.fromDate(
          DateTime.now().add(Duration(days: wateringInterval)),
        ),
        'nextActionType': 'water',
      });

      txn.set(_saplingAdoptionRef(uid, saplingId), {
        'saplingId': saplingId,
        'nickname': data['nickname'],
        'streakDays': 0,
        'lastCheckIn': null,
        'adoptedAt': FieldValue.serverTimestamp(),
        'wateringIntervalDays': wateringInterval,
      });

      txn.set(
        _impactSummaryRef(uid),
        {'adoptedCount': FieldValue.increment(1)},
        SetOptions(merge: true),
      );
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
      txn.delete(_adoptionRef(uid, saplingId));
      txn.delete(_saplingAdoptionRef(uid, saplingId));
      txn.set(
        _impactSummaryRef(uid),
        {'adoptedCount': FieldValue.increment(-1)},
        SetOptions(merge: true),
      );
    });
  }
}
