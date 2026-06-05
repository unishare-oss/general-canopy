import 'package:canopy/features/saplings/data/datasources/firestore_sapling_datasource.dart';
import 'package:canopy/features/saplings/data/models/sapling_model.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/repositories/sapling_repository.dart';

class SaplingRepositoryImpl implements SaplingRepository {
  const SaplingRepositoryImpl(this._datasource);
  final FirestoreSaplingDatasource _datasource;

  @override
  Stream<List<Sapling>> getAvailableSaplings() => _datasource
      .watchAvailableSaplings()
      .map((records) => records.map((r) => r.$2.toEntity(r.$1)).toList());

  @override
  Stream<List<Sapling>> getAllSaplings() => _datasource.watchAllSaplings().map(
    (records) => records.map((r) => r.$2.toEntity(r.$1)).toList(),
  );

  @override
  Future<Sapling> getSaplingById(String id) async {
    final (docId, model) = await _datasource.getSaplingById(id);
    return model.toEntity(docId);
  }

  @override
  Stream<Sapling> watchSaplingById(String id) =>
      _datasource.watchSaplingById(id).map((r) => r.$2.toEntity(r.$1));

  @override
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
  }) => _datasource.createSapling(
    SaplingModel(
      nickname: nickname,
      species: species,
      latin: latin,
      personality: personality,
      street: street,
      neighborhood: neighborhood,
      lat: lat,
      lng: lng,
      colorHex: colorHex,
      photoUrl: photoUrl,
      ageLabel: '~1 year',
      heightLabel: '1.0 m',
      waterNeedLabel: 'Moderate',
      lightLabel: 'Full sun',
      wateringIntervalDays: 3,
      status: 'available',
    ),
  );

  @override
  Future<void> adoptSapling({
    required String saplingId,
    required String uid,
    required String displayName,
    String? photoUrl,
  }) => _datasource.adoptSapling(
    saplingId: saplingId,
    uid: uid,
    displayName: displayName,
    photoUrl: photoUrl,
  );

  @override
  Future<void> unadoptSapling({
    required String saplingId,
    required String uid,
  }) => _datasource.unadoptSapling(saplingId: saplingId, uid: uid);
}
