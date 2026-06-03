import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/saplings/data/datasources/firestore_sapling_datasource.dart';
import 'package:canopy/features/saplings/data/models/sapling_model.dart';
import 'package:canopy/features/saplings/data/repositories/sapling_repository_impl.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/entities/sapling_exceptions.dart';

// ---------------------------------------------------------------------------
// Fake datasource
// ---------------------------------------------------------------------------

class _FakeDatasource implements FirestoreSaplingDatasource {
  final List<(String, SaplingModel)> _available;
  final List<(String, SaplingModel)> _all;

  bool adoptCalled = false;
  String? adoptedSaplingId;
  String? adoptedUid;
  bool throwOnAdopt = false;

  _FakeDatasource({
    List<(String, SaplingModel)>? available,
    List<(String, SaplingModel)>? all,
  }) : _available = available ?? [],
       _all = all ?? [];

  @override
  Stream<List<(String, SaplingModel)>> watchAvailableSaplings() =>
      Stream.value(_available);

  @override
  Stream<List<(String, SaplingModel)>> watchAllSaplings() => Stream.value(_all);

  @override
  Future<(String, SaplingModel)> getSaplingById(String id) async {
    final match = _all.where((r) => r.$1 == id).firstOrNull;
    if (match == null) throw SaplingNotFoundException(id);
    return match;
  }

  @override
  Future<void> adoptSapling({
    required String saplingId,
    required String uid,
    required String displayName,
    String? photoUrl,
  }) async {
    if (throwOnAdopt) throw const SaplingAlreadyAdoptedException();
    adoptCalled = true;
    adoptedSaplingId = saplingId;
    adoptedUid = uid;
  }

  @override
  Future<void> unadoptSapling({
    required String saplingId,
    required String uid,
  }) => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SaplingModel _model({String nickname = 'Tree', String status = 'available'}) =>
    SaplingModel(
      nickname: nickname,
      species: 'Oak',
      latin: 'Quercus',
      personality: 'Sturdy',
      colorHex: '#3BA75E',
      street: '1 Main St',
      neighborhood: 'Downtown',
      lat: 13.7,
      lng: 100.5,
      ageLabel: '2yr',
      heightLabel: '2m',
      waterNeedLabel: 'Low',
      lightLabel: 'Full sun',
      status: status,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SaplingRepositoryImpl.getAvailableSaplings', () {
    test(
      'maps stream of (id, SaplingModel) tuples to Sapling entities',
      () async {
        final tuples = [
          ('id-1', _model(nickname: 'Alpha')),
          ('id-2', _model(nickname: 'Beta')),
        ];
        final datasource = _FakeDatasource(available: tuples, all: tuples);
        final repo = SaplingRepositoryImpl(datasource);

        final result = await repo.getAvailableSaplings().first;

        expect(result.length, 2);
        expect(result[0].id, 'id-1');
        expect(result[0].nickname, 'Alpha');
        expect(result[0], isA<Sapling>());
        expect(result[1].id, 'id-2');
        expect(result[1].nickname, 'Beta');
      },
    );

    test('maps empty stream to empty list', () async {
      final datasource = _FakeDatasource();
      final repo = SaplingRepositoryImpl(datasource);

      final result = await repo.getAvailableSaplings().first;
      expect(result, isEmpty);
    });
  });

  group('SaplingRepositoryImpl.adoptSapling', () {
    test('delegates to datasource.adoptSapling with correct params', () async {
      final datasource = _FakeDatasource();
      final repo = SaplingRepositoryImpl(datasource);

      await repo.adoptSapling(
        saplingId: 'tree-99',
        uid: 'user-55',
        displayName: 'Test User',
      );

      expect(datasource.adoptCalled, isTrue);
      expect(datasource.adoptedSaplingId, 'tree-99');
      expect(datasource.adoptedUid, 'user-55');
    });

    test('propagates SaplingAlreadyAdoptedException from datasource', () async {
      final datasource = _FakeDatasource()..throwOnAdopt = true;
      final repo = SaplingRepositoryImpl(datasource);

      await expectLater(
        repo.adoptSapling(
          saplingId: 'tree-99',
          uid: 'user-55',
          displayName: 'Test User',
        ),
        throwsA(isA<SaplingAlreadyAdoptedException>()),
      );
    });
  });
}
