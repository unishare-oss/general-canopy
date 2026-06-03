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
  }) async {
    capturedSaplingId = saplingId;
    capturedUid = uid;
  }
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

        await useCase(saplingId: 'sapling-42', uid: 'user-99');

        expect(repo.capturedSaplingId, 'sapling-42');
        expect(repo.capturedUid, 'user-99');
      },
    );

    test('call() propagates exceptions from repository', () async {
      // Override to throw
      final throwingRepo = _ThrowingRepo();
      final useCase = AdoptSapling(throwingRepo);

      expect(
        () => useCase(saplingId: 'id', uid: 'uid'),
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
  Future<void> adoptSapling({required String saplingId, required String uid}) {
    throw Exception('Network error');
  }
}
