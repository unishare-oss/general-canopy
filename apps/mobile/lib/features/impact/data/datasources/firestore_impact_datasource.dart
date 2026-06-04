import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:canopy/features/impact/data/models/achievement_model.dart';
import 'package:canopy/features/impact/data/models/activity_item_model.dart';
import 'package:canopy/features/impact/data/models/impact_summary_model.dart';
import 'package:canopy/features/impact/data/models/leaderboard_entry_model.dart';
import 'package:canopy/features/impact/data/models/sapling_adoption_model.dart';
import 'package:canopy/features/impact/domain/entities/impact_summary.dart';

class FirestoreImpactDatasource {
  FirestoreImpactDatasource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<ImpactSummaryModel> watchImpactSummary(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('impactSummary')
        .doc('current')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return ImpactSummaryModel.fromFirestore(doc);
          return ImpactSummaryModel.fromFirestore(doc);
        });
  }

  Stream<List<SaplingAdoptionModel>> watchSaplingAdoptions(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('saplingAdoptions')
        .snapshots()
        .map(
          (snap) => snap.docs.map(SaplingAdoptionModel.fromFirestore).toList(),
        );
  }

  Stream<List<AchievementModel>> watchAchievements(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('achievements')
        .orderBy('earnedAt')
        .snapshots()
        .map((snap) => snap.docs.map(AchievementModel.fromFirestore).toList());
  }

  Stream<List<LeaderboardEntryModel>> watchLeaderboard(String neighborhood) {
    return _firestore
        .collection('neighborhoodLeaderboard')
        .doc(neighborhood)
        .collection('entries')
        .orderBy('co2OffsetKg', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snap) => snap.docs.map(LeaderboardEntryModel.fromFirestore).toList(),
        );
  }

  Stream<List<ActivityItemModel>> watchActivityFeed(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('activityFeed')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs.map(ActivityItemModel.fromFirestore).toList());
  }

  Future<void> upsertImpactSummary(String uid, ImpactSummary summary) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('impactSummary')
        .doc('current')
        .set({
          'co2OffsetKg': summary.co2OffsetKg,
          'waterGivenLiters': summary.waterGivenLiters,
          'totalSurvivalDays': summary.totalSurvivalDays,
          'adoptedCount': summary.adoptedCount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
  }
}
