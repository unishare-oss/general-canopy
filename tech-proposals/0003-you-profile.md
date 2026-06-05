---
title: "0003: You Profile"
description: "Replace the You tab placeholder with a profile screen: view/edit profile and sign out."
---

# PROP-0003: You Profile

**Status:** PROPOSED
**Author:** bambi
**Date:** 2026-06-04
**Spec:** [SPEC-0003](../tech-specs/0003-you-profile.md)
**Approved by:** (fill in when accepted)

---

## Problem

The You tab (`/you`) is still a `TabPlaceholder`. Requirement F1.6 ("View and edit
user profile", MVP) is unimplemented: a signed-in guardian cannot see or change the
profile data collected at onboarding (neighborhood, check-in frequency, plant
experience), cannot manage notification preferences, and there is no sign-out
button anywhere in the app — the `SignOut` usecase and confirm dialog exist but no
screen calls them.

## Proposed Solution

Build the You feature as a **presentation-only** layer that consumes the existing
auth stack. The `AppUser` entity, `UpdateUserProfile` usecase, `AuthRepository`,
and `FirestoreUserDatasource` (`users/{uid}`) already support every field we need;
Firestore rules already allow owner updates. The new code is:

- A single scrollable `YouScreen` (read-first): avatar/name/email header, tappable
  field rows (name, neighborhood, check-in frequency, plant experience) that open
  bottom sheets, two notification `SwitchListTile`s that save on toggle, and a
  sign-out button using the existing `confirmSignOut` dialog.
- A `YouProfileController` Riverpod notifier holding `{isSaving, error}` that calls
  `updateUserProfile` and invalidates `currentUserProvider` after a save (the
  `authStateChanges` stream does not re-emit on Firestore writes, so the screen
  reads profile data from `currentUserProvider`).
- Guests (anonymous users) see a create-account prompt that routes to
  `/welcome?redirect=/you`, mirroring the Discover guest gate.

## Alternatives Considered

### A — Full Clean Architecture stack under `features/you/`

A parallel domain/data layer (ProfileRepository, datasource, models).
**Rejected:** would duplicate the auth feature's existing entity, usecase,
repository, and datasource for zero behavioral gain.

### B — Separate view and edit screens

A read-only profile screen plus a `/you/edit` form screen.
**Rejected:** the profile is five fields and two toggles; a view/edit split adds
navigation overhead. Inline rows + bottom sheets match the app's existing
bottom-sheet pattern (adopt confirmation).

### C — Reuse the onboarding step widgets for editing

`onboarding_step_{neighborhood,frequency,experience}.dart` already render the
option pickers. **Rejected:** they are coupled to `onboardingProvider` and the
4-step layout; decoupling them is a refactor of stable files with conflict risk.
Slim You-scoped sheet widgets copy the ~30-line card visuals instead (a shared
`SelectableOptionTile` extraction is noted as a future refactor).

## Open Questions

1. Should editing be blocked while offline, or rely on Firestore's offline queue?
   (Current answer: rely on Firestore defaults, same as onboarding.)

## Acceptance Criteria

- Signed-in user sees avatar (photo or initials), name, email, neighborhood,
  check-in frequency, plant experience, and notification toggles; unset optional
  fields display "Not set".
- User can edit name, neighborhood, frequency, experience, and both notification
  preferences; changes persist to `users/{uid}` and the screen reflects them
  without an app restart.
- Save failures surface a dismissible error; controls are disabled while saving.
- Sign out asks for confirmation and returns the user to the welcome screen.
- Anonymous/guest users see a create-account prompt instead of the editor.
- Avatar upload (F1.7), account deletion (F1.8), and password reset are out of scope.
