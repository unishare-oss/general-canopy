import 'package:canopy/features/saplings/domain/entities/sapling.dart';

abstract interface class SaplingRepository {
  Stream<List<Sapling>> getAvailableSaplings();
  Stream<List<Sapling>> getAllSaplings();
  Future<Sapling> getSaplingById(String id);
  Stream<Sapling> watchSaplingById(String id);
  Future<String> createSapling({
    required String nickname,
    required String species,
    required String latin,
    required String personality,
    required String street,
    required String neighborhood,
    required double lat,
    required double lng,
    required String colorHex,
    String? photoUrl,
  });
  Future<void> adoptSapling({
    required String saplingId,
    required String uid,
    required String displayName,
    String? photoUrl,
  });
  Future<void> unadoptSapling({required String saplingId, required String uid});
}
