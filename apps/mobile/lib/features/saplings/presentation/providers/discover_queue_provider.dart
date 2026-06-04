import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/entities/sapling_exceptions.dart';
import 'package:canopy/features/saplings/domain/usecases/adopt_sapling.dart';
import 'package:canopy/features/saplings/presentation/providers/sapling_repository_provider.dart';

part 'discover_queue_provider.g.dart';

class DiscoverQueueState {
  const DiscoverQueueState({
    this.queue = const [],
    this.passed = const [],
    this.isAdopting = false,
    this.adoptError,
  });

  final List<Sapling> queue;
  final List<String> passed;
  final bool isAdopting;
  final String? adoptError;

  DiscoverQueueState copyWith({
    List<Sapling>? queue,
    List<String>? passed,
    bool? isAdopting,
    String? adoptError,
    bool clearAdoptError = false,
  }) => DiscoverQueueState(
    queue: queue ?? this.queue,
    passed: passed ?? this.passed,
    isAdopting: isAdopting ?? this.isAdopting,
    adoptError: clearAdoptError ? null : (adoptError ?? this.adoptError),
  );
}

@riverpod
class DiscoverQueueNotifier extends _$DiscoverQueueNotifier {
  @override
  DiscoverQueueState build() => const DiscoverQueueState();

  void initialize(List<Sapling> saplings) {
    final passedIds = state.passed.toSet();
    final filtered = saplings
        .where((s) => s.isAvailable && !passedIds.contains(s.id))
        .toList();
    // Only rebuild if the queue content actually changed.
    if (_sameIds(filtered, state.queue)) return;
    state = state.copyWith(queue: filtered);
  }

  void pass(String saplingId) {
    state = state.copyWith(
      queue: state.queue.where((s) => s.id != saplingId).toList(),
      passed: [...state.passed, saplingId],
    );
  }

  Future<void> adopt({
    required String saplingId,
    required String uid,
    required String displayName,
    String? photoUrl,
  }) async {
    state = state.copyWith(isAdopting: true, clearAdoptError: true);
    try {
      await AdoptSapling(ref.read(saplingRepositoryProvider))(
        saplingId: saplingId,
        uid: uid,
        displayName: displayName,
        photoUrl: photoUrl,
      );
      state = state.copyWith(
        isAdopting: false,
        queue: state.queue.where((s) => s.id != saplingId).toList(),
      );
    } on SaplingAlreadyAdoptedException {
      state = state.copyWith(
        isAdopting: false,
        adoptError: 'This sapling was just adopted by someone else.',
        queue: state.queue.where((s) => s.id != saplingId).toList(),
      );
    } catch (_) {
      state = state.copyWith(
        isAdopting: false,
        adoptError: 'Adoption failed. Please try again.',
      );
    }
  }

  void dismissError() => state = state.copyWith(clearAdoptError: true);

  bool _sameIds(List<Sapling> a, List<Sapling> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }
}
