import 'package:canopy/features/saplings/data/datasources/firestore_sapling_datasource.dart';
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
  Future<void> adoptSapling({required String saplingId, required String uid}) =>
      _datasource.adoptSapling(saplingId: saplingId, uid: uid);
}
