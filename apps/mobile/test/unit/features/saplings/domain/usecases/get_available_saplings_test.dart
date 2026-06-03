import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/repositories/sapling_repository.dart';
import 'package:canopy/features/saplings/domain/usecases/get_available_saplings.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeSaplingRepository implements SaplingRepository {
  final List<Sapling> _available;

  _FakeSaplingRepository(this._available);

  @override
  Stream<List<Sapling>> getAvailableSaplings() => Stream.value(_available);

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
  species: 'Oak',
  latin: 'Quercus',
  personality: 'Sturdy',
  street: '1 Main St',
  neighborhood: 'Downtown',
  lat: 13.7,
  lng: 100.5,
  ageLabel: '2yr',
  heightLabel: '2m',
  waterNeedLabel: 'Low',
  lightLabel: 'Full sun',
  wateringIntervalDays: 3,
  colorHex: '#3BA75E',
  status: SaplingStatus.available,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GetAvailableSaplings', () {
    test('call() returns the stream from repository unchanged', () async {
      final saplings = [_sapling('a'), _sapling('b')];
      final repo = _FakeSaplingRepository(saplings);
      final useCase = GetAvailableSaplings(repo);

      final result = await useCase().first;

      expect(result, equals(saplings));
    });

    test('call() returns an empty stream when no saplings available', () async {
      final repo = _FakeSaplingRepository([]);
      final useCase = GetAvailableSaplings(repo);

      final result = await useCase().first;

      expect(result, isEmpty);
    });
  });
}
