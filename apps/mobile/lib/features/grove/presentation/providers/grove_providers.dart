import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:canopy/features/auth/presentation/providers/current_user_provider.dart';
import 'package:canopy/features/grove/data/datasources/grove_firestore_datasource.dart';
import 'package:canopy/features/grove/data/repositories/grove_repository_impl.dart';
import 'package:canopy/features/grove/domain/entities/adopted_sapling.dart';
import 'package:canopy/features/grove/domain/entities/care_event.dart';
import 'package:canopy/features/grove/domain/entities/sapling_photo.dart';
import 'package:canopy/features/grove/domain/repositories/grove_repository.dart';
import 'package:canopy/features/grove/domain/usecases/get_adoption_detail.dart';
import 'package:canopy/features/grove/domain/usecases/get_care_history.dart';
import 'package:canopy/features/grove/domain/usecases/watch_adoption_photos.dart';
import 'package:canopy/features/grove/domain/usecases/watch_my_grove.dart';

part 'grove_providers.g.dart';

// ── Infrastructure ──────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
GroveFirestoreDatasource groveFirestoreDatasource(Ref ref) =>
    GroveFirestoreDatasource(FirebaseFirestore.instance);

@Riverpod(keepAlive: true)
GroveRepository groveRepository(Ref ref) =>
    GroveRepositoryImpl(ref.watch(groveFirestoreDatasourceProvider));

// ── Use cases ───────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
WatchMyGrove watchMyGrove(Ref ref) =>
    WatchMyGrove(ref.watch(groveRepositoryProvider));

@Riverpod(keepAlive: true)
GetAdoptionDetail getAdoptionDetail(Ref ref) =>
    GetAdoptionDetail(ref.watch(groveRepositoryProvider));

@Riverpod(keepAlive: true)
WatchAdoptionPhotos watchAdoptionPhotos(Ref ref) =>
    WatchAdoptionPhotos(ref.watch(groveRepositoryProvider));

@Riverpod(keepAlive: true)
GetCareHistory getCareHistory(Ref ref) =>
    GetCareHistory(ref.watch(groveRepositoryProvider));

// ── UI-state providers ───────────────────────────────────────────────────────

@riverpod
Stream<List<AdoptedSapling>> myGrove(Ref ref) {
  final uid = ref.watch(currentUserProvider).asData?.value?.id ?? '';
  if (uid.isEmpty) return const Stream.empty();
  return ref.watch(watchMyGroveProvider).call(uid);
}

@riverpod
Future<AdoptedSapling> adoptionDetail(Ref ref, String uid, String adoptionId) =>
    ref.watch(getAdoptionDetailProvider).call(uid: uid, adoptionId: adoptionId);

@riverpod
Stream<List<SaplingPhoto>> adoptionPhotos(
  Ref ref,
  String uid,
  String adoptionId,
) => ref
    .watch(watchAdoptionPhotosProvider)
    .call(uid: uid, adoptionId: adoptionId);

@riverpod
Future<List<CareEvent>> careHistory(Ref ref, String uid, String adoptionId) =>
    ref.watch(getCareHistoryProvider).call(uid: uid, adoptionId: adoptionId);
