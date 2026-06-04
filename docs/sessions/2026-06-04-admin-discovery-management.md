# Session: 2026-06-04-admin-discovery-management

**Date:** 2026-06-04  
**Member:** Slade  
**Agent:** flutter-engineer  
**Task:** Implement admin discovery management (SPEC-0003)

## Context

PROP-0002 and SPEC-0003 are both APPROVED. Folder structure scaffolded. All stub files are in place.

Reference spec: `tech-specs/0003-admin-discovery-management.md`  
Reference implementation pattern: `lib/features/saplings/` (all layers)  
Map screen to modify: `lib/features/map/presentation/screens/map_screen.dart`  
Router to modify: `lib/core/router/router.dart`  
Firestore rules to modify: `firestore.rules`

## Plan

1. Implement `admin` domain layer — `AdminStatus` entity, `AdminRepository` interface, `CheckAdminStatus` and `GrantAdmin` use cases.
2. Implement `admin` data layer — `FirestoreAdminDatasource`, `AdminRepositoryImpl`.
3. Wire `admin` presentation layer — `adminRepositoryProvider`, `isAdminProvider` (`@riverpod FutureProvider`).
4. Implement `discoveries` domain layer — `Discovery` entity, `DiscoveryRepository` interface, five use cases.
5. Implement `discoveries` data layer — `DiscoveryModel` (Freezed), `FirestoreDiscoveryDatasource`, `DiscoveryRepositoryImpl`.
6. Wire `discoveries` presentation layer — `discoveryRepositoryProvider`, `watchAllDiscoveriesProvider`.
7. Build `DiscoveryDetailScreen` (read-only + admin overflow menu for edit/delete).
8. Build `CreateEditDiscoveryScreen` (admin-only form, create + edit modes).
9. Modify `MapScreen` — add second `MarkerLayer` for discoveries + admin FAB.
10. Register `/discovery/create`, `/discovery/:id`, `/discovery/:id/edit` in GoRouter.
11. Update `firestore.rules` and `firestore.indexes.json` per SPEC-0003.
12. Create `tools/seed_admins.js`.
13. Run `dart run build_runner build --delete-conflicting-outputs`.
14. Run `flutter analyze` and `dart format .`.

## Notes

<!-- Running notes during the session -->

## Handoff

**To:** qa-engineer  
**Done:**  
**Not done:**  
**Watch out for:**
- `isAdminProvider` is a `FutureProvider` (not Stream) — admin status is not expected to change mid-session.
- `watchAllDiscoveriesProvider` is a `StreamProvider` — real-time updates required.
- `createDiscovery` returns `String` (new doc ID) so the caller can navigate to the detail screen immediately.
- Firestore rules use `get()` on every write — this is intentional (Option 1B from proposal).
- The `admins` collection `read` rule is open to all authenticated users — this is deliberate (app needs it to evaluate `isAdminProvider` without a Cloud Function).
- First admin bootstrap: `tools/seed_admins.js --emulator` for local dev; Console for production.
