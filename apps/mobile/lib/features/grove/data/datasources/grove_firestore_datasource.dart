import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:canopy/features/grove/data/models/adoption_model.dart';
import 'package:canopy/features/grove/data/models/care_event_model.dart';
import 'package:canopy/features/grove/data/models/sapling_photo_model.dart';

class GroveFirestoreDatasource {
  GroveFirestoreDatasource(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _adoptions(String uid) =>
      _db.collection('users').doc(uid).collection('adoptions');

  Stream<List<(String, AdoptionModel)>> watchMyGrove(String uid) =>
      _adoptions(uid)
          .orderBy('nextActionAt')
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => (d.id, AdoptionModel.fromJson(d.data())))
                .toList(),
          );

  Future<(String, AdoptionModel)> getAdoptionDetail({
    required String uid,
    required String adoptionId,
  }) async {
    final doc = await _adoptions(uid).doc(adoptionId).get();
    if (!doc.exists || doc.data() == null) {
      throw StateError('Adoption $adoptionId not found');
    }
    return (doc.id, AdoptionModel.fromJson(doc.data()!));
  }

  Stream<List<(String, SaplingPhotoModel)>> watchAdoptionPhotos({
    required String uid,
    required String adoptionId,
  }) => _adoptions(uid)
      .doc(adoptionId)
      .collection('photos')
      .orderBy('takenAt')
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => (d.id, SaplingPhotoModel.fromJson(d.data())))
            .toList(),
      );

  Future<List<(String, CareEventModel)>> getCareHistory({
    required String uid,
    required String adoptionId,
  }) async {
    final snap = await _adoptions(uid)
        .doc(adoptionId)
        .collection('history')
        .orderBy('performedAt', descending: true)
        .get();
    return snap.docs
        .map((d) => (d.id, CareEventModel.fromJson(d.data())))
        .toList();
  }
}
