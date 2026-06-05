import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:canopy/features/grove/data/models/adoption_model.dart';
import 'package:canopy/features/grove/data/models/care_event_model.dart';
import 'package:canopy/features/grove/data/models/sapling_photo_model.dart';
import 'package:canopy/features/grove/domain/entities/care_event.dart';

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

  Future<void> logCareEvent({
    required String uid,
    required String adoptionId,
    required String saplingId,
    required CareEventType type,
    double waterLiters = 2.0,
  }) async {
    final adoptionRef = _adoptions(uid).doc(adoptionId);
    final historyRef = adoptionRef.collection('history').doc();
    final saplingAdoptionRef = _db
        .collection('users')
        .doc(uid)
        .collection('saplingAdoptions')
        .doc(saplingId);
    final impactRef = _db
        .collection('users')
        .doc(uid)
        .collection('impactSummary')
        .doc('current');

    final typeString = _careEventTypeToString(type);

    await _db.runTransaction((txn) async {
      final adoptionSnap = await txn.get(adoptionRef);
      final currentHealth = (adoptionSnap.data()?['healthScore'] as int?) ?? 80;
      final newHealth = (currentHealth + 5).clamp(0, 100);
      // Actual gain after clamping (e.g. 0 when already at 100), so the care
      // history shows the true health change rather than a flat +5.
      final healthScoreDelta = newHealth - currentHealth;
      final nextActionAt = DateTime.now().add(const Duration(days: 3));

      // 1. Write care history entry
      txn.set(historyRef, {
        'type': typeString,
        'performedAt': FieldValue.serverTimestamp(),
        'healthScoreDelta': healthScoreDelta,
      });

      // 2. Update adoption health + next action
      txn.update(adoptionRef, {
        'healthScore': newHealth,
        'nextActionAt': Timestamp.fromDate(nextActionAt),
      });

      // 3. Increment streak on saplingAdoptions
      txn.set(saplingAdoptionRef, {
        'streakDays': FieldValue.increment(1),
        'lastCheckIn': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 4. Update impact summary
      final impactUpdate = <String, dynamic>{
        'totalSurvivalDays': FieldValue.increment(1),
      };
      if (type == CareEventType.water) {
        impactUpdate['waterGivenLiters'] = FieldValue.increment(waterLiters);
      }
      txn.set(impactRef, impactUpdate, SetOptions(merge: true));
    });
  }
}

String _careEventTypeToString(CareEventType type) => switch (type) {
  CareEventType.water => 'water',
  CareEventType.fertilize => 'fertilize',
  CareEventType.prune => 'prune',
  CareEventType.inspect => 'inspect',
  CareEventType.adopted => 'adopted',
};
