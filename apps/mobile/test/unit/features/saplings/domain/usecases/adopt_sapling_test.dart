import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/repositories/sapling_repository.dart';
import 'package:canopy/features/saplings/domain/usecases/adopt_sapling.dart';

// ---------------------------------------------------------------------------
// Fake repository — records adoptSapling call args
// ---------------------------------------------------------------------------

class _FakeSaplingRepository implements SaplingRepository {
  String? capturedSaplingId;
  String? capturedUid;

  @override
  Stream<List<Sapling>> getAvailableSaplings() => Stream.value([]);

  @override
  Stream<List<Sapling>> getAllSaplings() => Stream.value([]);

  @override
  Future<Sapling> getSaplingById(String id) => throw UnimplementedError();

  @override
  Future<void> adoptSapling({
    required String saplingId,
    required String uid,
    required String displayName,
    String? photoUrl,
  }) async {
    capturedSaplingId = saplingId;
    capturedUid = uid;
  }

  @override
  Future<void> unadoptSapling({
    required String saplingId,
    required String uid,
  }) => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AdoptSapling', () {
    test(
      'call(saplingId, uid) delegates to repository.adoptSapling with exact params',
      () async {
        final repo = _FakeSaplingRepository();
        final useCase = AdoptSapling(repo);

        await useCase(
          saplingId: 'sapling-42',
          uid: 'user-99',
          displayName: 'Test User',
        );

        expect(repo.capturedSaplingId, 'sapling-42');
        expect(repo.capturedUid, 'user-99');
      },
    );

    test('call() propagates exceptions from repository', () async {
      // Override to throw
      final throwingRepo = _ThrowingRepo();
      final useCase = AdoptSapling(throwingRepo);

      expect(
        () => useCase(saplingId: 'id', uid: 'uid', displayName: 'User'),
        throwsA(isA<Exception>()),
      );
    });
  });
}

class _ThrowingRepo implements SaplingRepository {
  @override
  Stream<List<Sapling>> getAvailableSaplings() => Stream.value([]);

  @override
  Stream<List<Sapling>> getAllSaplings() => Stream.value([]);

  @override
  Future<Sapling> getSaplingById(String id) => throw UnimplementedError();

  @override
  Future<void> adoptSapling({
    required String saplingId,
    required String uid,
    required String displayName,
    String? photoUrl,
  }) {
    throw Exception('Network error');
  }

  @override
  Future<void> unadoptSapling({
    required String saplingId,
    required String uid,
  }) => throw UnimplementedError();
}

