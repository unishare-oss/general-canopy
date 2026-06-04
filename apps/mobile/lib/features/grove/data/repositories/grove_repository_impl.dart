import 'package:canopy/features/grove/data/datasources/grove_firestore_datasource.dart';
import 'package:canopy/features/grove/domain/entities/adopted_sapling.dart';
import 'package:canopy/features/grove/domain/entities/care_event.dart';
import 'package:canopy/features/grove/domain/entities/sapling_photo.dart';
import 'package:canopy/features/grove/domain/repositories/grove_repository.dart';

class GroveRepositoryImpl implements GroveRepository {
  GroveRepositoryImpl(this._datasource);
  final GroveFirestoreDatasource _datasource;

  @override
  Stream<List<AdoptedSapling>> watchMyGrove(String uid) => _datasource
      .watchMyGrove(uid)
      .map((list) => list.map((r) => r.$2.toEntity(r.$1)).toList());

  @override
  Future<AdoptedSapling> getAdoptionDetail({
    required String uid,
    required String adoptionId,
  }) async {
    final r = await _datasource.getAdoptionDetail(
      uid: uid,
      adoptionId: adoptionId,
    );
    return r.$2.toEntity(r.$1);
  }

  @override
  Stream<List<SaplingPhoto>> watchAdoptionPhotos({
    required String uid,
    required String adoptionId,
  }) => _datasource
      .watchAdoptionPhotos(uid: uid, adoptionId: adoptionId)
      .map((list) => list.map((r) => r.$2.toEntity(r.$1)).toList());

  @override
  Future<List<CareEvent>> getCareHistory({
    required String uid,
    required String adoptionId,
  }) async {
    final list = await _datasource.getCareHistory(
      uid: uid,
      adoptionId: adoptionId,
    );
    return list.map((r) => r.$2.toEntity(r.$1)).toList();
  }

  @override
  Future<void> logCareEvent({
    required String uid,
    required String adoptionId,
    required String saplingId,
    required CareEventType type,
    double waterLiters = 2.0,
  }) => _datasource.logCareEvent(
    uid: uid,
    adoptionId: adoptionId,
    saplingId: saplingId,
    type: type,
    waterLiters: waterLiters,
  );
}
