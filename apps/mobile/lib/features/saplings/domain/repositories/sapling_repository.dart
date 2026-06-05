import 'package:canopy/features/saplings/domain/entities/sapling.dart';

abstract interface class SaplingRepository {
  Stream<List<Sapling>> getAvailableSaplings();
  Stream<List<Sapling>> getAllSaplings();
  Future<Sapling> getSaplingById(String id);
  Stream<Sapling> watchSaplingById(String id);
  Future<void> adoptSapling({
    required String saplingId,
    required String uid,
    required String displayName,
    String? photoUrl,
  });
  Future<void> unadoptSapling({required String saplingId, required String uid});
}
