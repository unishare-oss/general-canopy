import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/entities/sapling_exceptions.dart';
import 'package:canopy/features/saplings/domain/repositories/sapling_repository.dart';
import 'package:canopy/features/saplings/presentation/providers/discover_queue_provider.dart';
import 'package:canopy/features/saplings/presentation/providers/sapling_repository_provider.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeSaplingRepository implements SaplingRepository {
  bool throwOnAdopt = false;
  bool throwAlreadyAdopted = false;
  String? adoptedSaplingId;

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
    adoptedSaplingId = saplingId;
    if (throwAlreadyAdopted) throw const SaplingAlreadyAdoptedException();
    if (throwOnAdopt) throw Exception('Generic error');
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Sapling _sapling(String id, {SaplingStatus status = SaplingStatus.available}) =>
    Sapling(
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
      status: status,
    );

ProviderContainer _makeContainer(_FakeSaplingRepository repo) =>
    ProviderContainer(
      overrides: [saplingRepositoryProvider.overrideWithValue(repo)],
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DiscoverQueueNotifier', () {
    late _FakeSaplingRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = _FakeSaplingRepository();
      container = _makeContainer(fakeRepo);
    });

    tearDown(() => container.dispose());

    test('initial state is empty', () {
      final state = container.read(discoverQueueProvider);
      expect(state.queue, isEmpty);
      expect(state.passed, isEmpty);
      expect(state.isAdopting, isFalse);
      expect(state.adoptError, isNull);
    });

    test('initialize populates queue with available saplings only', () {
      final saplings = [
        _sapling('a'),
        _sapling('b', status: SaplingStatus.adopted),
        _sapling('c'),
      ];
      container.read(discoverQueueProvider.notifier).initialize(saplings);

      final queue = container.read(discoverQueueProvider).queue;
      expect(queue.length, 2);
      expect(queue.map((s) => s.id), containsAllInOrder(['a', 'c']));
    });

    test('pass removes sapling from queue and adds id to passed', () {
      final saplings = [_sapling('x'), _sapling('y')];
      container.read(discoverQueueProvider.notifier).initialize(saplings);

      container.read(discoverQueueProvider.notifier).pass('x');

      final state = container.read(discoverQueueProvider);
      expect(state.queue.map((s) => s.id), isNot(contains('x')));
      expect(state.passed, contains('x'));
    });

    test('initialize second call excludes passed IDs', () {
      final saplings = [_sapling('a'), _sapling('b'), _sapling('c')];
      container.read(discoverQueueProvider.notifier).initialize(saplings);
      container.read(discoverQueueProvider.notifier).pass('b');

      // Re-initialize with the same list (simulates a new Firestore emission).
      container.read(discoverQueueProvider.notifier).initialize(saplings);

      final queue = container.read(discoverQueueProvider).queue;
      expect(queue.map((s) => s.id), isNot(contains('b')));
    });

    test('adopt removes sapling from queue on success', () async {
      final saplings = [_sapling('tree-1'), _sapling('tree-2')];
      container.read(discoverQueueProvider.notifier).initialize(saplings);

      await container
          .read(discoverQueueProvider.notifier)
          .adopt(saplingId: 'tree-1', uid: 'user-uid');

      final state = container.read(discoverQueueProvider);
      expect(state.isAdopting, isFalse);
      expect(state.adoptError, isNull);
      expect(state.queue.map((s) => s.id), isNot(contains('tree-1')));
      expect(fakeRepo.adoptedSaplingId, 'tree-1');
    });

    test('adopt sets adoptError on SaplingAlreadyAdoptedException', () async {
      fakeRepo.throwAlreadyAdopted = true;
      final saplings = [_sapling('tree-3')];
      container.read(discoverQueueProvider.notifier).initialize(saplings);

      await container
          .read(discoverQueueProvider.notifier)
          .adopt(saplingId: 'tree-3', uid: 'user-uid');

      final state = container.read(discoverQueueProvider);
      expect(state.isAdopting, isFalse);
      expect(state.adoptError, isNotNull);
      expect(state.adoptError, contains('just adopted'));
    });

    test('adopt sets generic adoptError on unexpected exception', () async {
      fakeRepo.throwOnAdopt = true;
      final saplings = [_sapling('tree-4')];
      container.read(discoverQueueProvider.notifier).initialize(saplings);

      await container
          .read(discoverQueueProvider.notifier)
          .adopt(saplingId: 'tree-4', uid: 'user-uid');

      final state = container.read(discoverQueueProvider);
      expect(state.adoptError, isNotNull);
      expect(state.isAdopting, isFalse);
    });

    test('dismissError clears adoptError', () async {
      fakeRepo.throwAlreadyAdopted = true;
      final saplings = [_sapling('tree-5')];
      container.read(discoverQueueProvider.notifier).initialize(saplings);

      await container
          .read(discoverQueueProvider.notifier)
          .adopt(saplingId: 'tree-5', uid: 'uid');

      // Confirm error is set.
      expect(container.read(discoverQueueProvider).adoptError, isNotNull);

      container.read(discoverQueueProvider.notifier).dismissError();

      expect(container.read(discoverQueueProvider).adoptError, isNull);
    });
  });
}
