import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/repositories/sapling_repository.dart';
import 'package:canopy/features/saplings/domain/usecases/get_sapling_by_id.dart';

// ---------------------------------------------------------------------------
// Fake repository — records getSaplingById call and returns a stub
// ---------------------------------------------------------------------------

class _FakeSaplingRepository implements SaplingRepository {
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
  }) => throw UnimplementedError();

  String? capturedId;
  final Sapling? _stubResult;

  _FakeSaplingRepository({Sapling? stubResult}) : _stubResult = stubResult;

  @override
  Stream<List<Sapling>> getAvailableSaplings() => Stream.value([]);

  @override
  Stream<List<Sapling>> getAllSaplings() => Stream.value([]);

  @override
  Future<Sapling> getSaplingById(String id) async {
    capturedId = id;
    if (_stubResult == null) throw Exception('Not found');
    return _stubResult;
  }

  @override
  Stream<Sapling> watchSaplingById(String id) => throw UnimplementedError();

  @override
  Future<void> adoptSapling({
    required String saplingId,
    required String uid,
    required String displayName,
    String? photoUrl,
  }) => throw UnimplementedError();

  @override
  Future<void> unadoptSapling({
    required String saplingId,
    required String uid,
  }) => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Sapling _sapling(String id) => Sapling(
  id: id,
  nickname: 'Tree $id',
  species: 'Maple',
  latin: 'Acer',
  personality: 'Calm',
  street: '5 Oak Ave',
  neighborhood: 'Riverside',
  lat: 13.8,
  lng: 100.6,
  ageLabel: '1yr',
  heightLabel: '1.5m',
  waterNeedLabel: 'Medium',
  lightLabel: 'Partial shade',
  wateringIntervalDays: 4,
  colorHex: '#E2A130',
  status: SaplingStatus.available,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GetSaplingById', () {
    test('call(id) forwards the id to repository.getSaplingById', () async {
      final stub = _sapling('tree-77');
      final repo = _FakeSaplingRepository(stubResult: stub);
      final useCase = GetSaplingById(repo);

      final result = await useCase('tree-77');

      expect(repo.capturedId, 'tree-77');
      expect(result, equals(stub));
    });

    test('call() propagates exception when repository throws', () async {
      final repo = _FakeSaplingRepository(); // no stub → throws
      final useCase = GetSaplingById(repo);

      await expectLater(useCase('missing-id'), throwsA(isA<Exception>()));
      expect(repo.capturedId, 'missing-id');
    });
  });
}
