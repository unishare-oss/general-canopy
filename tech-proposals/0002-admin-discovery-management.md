---
title: "0002: Admin Discovery Management"
description: "Introduce an admin role and give admins the ability to create, edit, and delete discoveries (map pins / points of interest) from within the app, enforced server-side by Firestore security rules."
---

# PROP-0002: Admin Discovery Management

**Status:** ACCEPTED  
**Author:** Architect  
**Date:** 2026-06-04  
**Spec:** (pending)  
**Approved by:** Slade — 2026-06-04

---

## Problem

Canopy currently has no admin tier. Every authenticated user — including anonymous guests — is treated identically by both the app and Firestore. There is no way for any user, regardless of who they are, to create, edit, or delete discoveries (map pins / points of interest surfaced on the map screen). The `saplings` collection exists and is seeded outside the app, but the new `discoveries` entity type has no collection, no CRUD path, and no management surface at all.

The absence of an admin role creates two compounding problems.

First, there is no operational path to publish or maintain discovery content once the app is in production. The team cannot rely on direct Firebase Console access indefinitely — it does not scale, it requires Firebase project credentials, and it produces no audit trail.

Second, and more critically, any role-gating implemented only in client code is not enforceable. A motivated user with a patched APK or direct Firestore SDK access can bypass any client-side check. Firestore security rules — which execute server-side in Google's infrastructure and cannot be bypassed by the client — must be the authoritative enforcement point. The current `firestore.rules` file has no concept of an admin identity at all; adding client-only guards without fixing the rules would provide false security.

The feature therefore requires: (1) a server-enforceable admin identity mechanism, (2) Firestore rules that gate all `discoveries` writes to that identity, and (3) an in-app management surface so admins never need Firebase Console access.

---

## Goals

1. Define an admin role that is enforced server-side in Firestore security rules, not only in client code.
2. Allow admins to create a new discovery from the map screen without leaving the app.
3. Allow admins to edit the fields of an existing discovery from the discovery detail screen or the map screen.
4. Allow admins to delete an existing discovery from within the app.
5. Allow an existing admin to grant the admin role to another user from within the app (no Firebase Console access required).
6. Regular authenticated users (including anonymous guests) must receive a Firestore permission-denied error if they attempt any write to the `discoveries` collection, regardless of client-side state.
7. The admin management surface must not be visible to non-admin users — client-side UI hiding is acceptable as a UX measure, but it is secondary to rule enforcement.

---

## Non-Goals

- Revoking the admin role (can be added in a follow-up; revocation requires the same mechanism as granting and should be specified separately once role governance is clearer).
- A dedicated admin web dashboard or back-office portal.
- Discovery media uploads (photo / video attachment to discoveries). Storage rules and upload flows are a separate feature.
- Fine-grained role tiers (e.g. "moderator" vs. "super-admin"). A single binary admin flag is sufficient at this stage.
- Push notifications to users when a new discovery is published.
- Audit logging of who created or modified a discovery (worthwhile but deferred to a later iteration).

---

## Options

### Option 1A — Admin role via Firebase Auth custom claims

A server-side callable Cloud Function (or Firebase Admin SDK script) sets a custom JWT claim `{ "admin": true }` on a user's Firebase Auth token. Firestore rules read `request.auth.token.admin == true` to gate writes. An in-app "Grant Admin" flow calls a restricted Cloud Function that checks whether the caller is already an admin before setting the claim on the target user.

**Pros:**
- The claim travels inside the JWT, so every Firestore rule evaluation has access to it with zero additional reads.
- Rules stay simple and readable: `allow write: if request.auth.token.admin == true`.
- Custom claims are a first-class Firebase Auth feature; no extra collection to maintain or synchronize.
- Resistant to client-side spoofing: JWTs are signed by Firebase and cannot be forged.

**Cons:**
- Requires at least one Cloud Function to set claims (the Firebase Admin SDK cannot run on-device). If the project has no Cloud Functions yet, this adds infrastructure.
- Token refresh latency: after a claim is set, the target user must refresh their ID token before the claim takes effect (up to 1 hour, or immediately on forced token refresh). Granting admin to someone does not take effect instantly unless the app forces a token refresh.
- Cloud Function deployment is outside the Flutter/Dart toolchain, adding operational surface.

**Effort:** M (Flutter work is small; Cloud Function scaffolding and deployment pipeline are the bulk of the effort)

---

### Option 1B — Admin role via a Firestore `admins` collection

A top-level `admins/{userId}` document exists for every admin. Firestore rules use `get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.isAdmin == true` to gate writes. An in-app "Grant Admin" flow writes a new document to `admins/{targetUid}` — but only if the calling user's own `admins/{uid}` document exists (enforced by a rule condition on the write).

**Pros:**
- No Cloud Functions required; the entire implementation lives in Flutter + Firestore rules.
- Admin status is immediately visible and queryable (useful for the "Grant Admin" UI to show a list of current admins).
- Consistent with the existing pattern in the codebase (Firestore documents as the source of truth for user-scoped data).

**Cons:**
- Every Firestore write rule for `discoveries` must perform an extra `get()` call to the `admins` collection. Each `get()` in a rule counts as a billable read; high-write scenarios (e.g., an admin creating many discoveries in a session) incur double the Firestore reads.
- The `admins` collection must itself be locked down carefully (only admins can write to it; bootstrapping the very first admin requires a one-time Console or script operation).
- Admin status check is a synchronous `get()` in rules — if the `admins` document does not exist, the rule evaluation fails with a permission error, which is correct but requires careful error handling in the app.

**Effort:** S-M (no Cloud Functions; the main effort is Firestore rules design and the grant-admin use case)

---

### Option 1C — Hybrid: custom claims for rules enforcement, Firestore `admins` collection for app-layer reads

Custom claims gate all Firestore writes (same as Option 1A). A mirrored `admins/{userId}` document is maintained for app-layer queries (e.g., showing a list of current admins, checking admin status in the Riverpod provider without decoding the JWT manually). The Cloud Function that sets the claim also writes the mirror document.

**Pros:**
- Rules enforcement is claim-based (fast, no extra reads).
- App layer has a simple, queryable source of truth for admin identity.
- Best of both 1A and 1B for their respective strengths.

**Cons:**
- Two sources of truth that must be kept in sync. If the Cloud Function fails midway, the claim is set but the mirror document is absent (or vice versa), producing inconsistent state.
- Higher implementation complexity than either option alone.
- Still requires Cloud Functions.

**Effort:** L

---

### Option 2A — UX: Floating Action Button (FAB) on the map screen

An admin-only FAB appears in the bottom-right corner of the map screen. Tapping it opens a full-screen or modal form to create a new discovery. The FAB is conditionally rendered based on admin status from the Riverpod provider. Edit and delete actions are accessible from the discovery detail bottom sheet via an overflow menu (three-dot icon), also conditionally rendered for admins.

**Pros:**
- The FAB is the canonical Flutter pattern for "primary create action" on a screen with spatial content. Users already understand it from Google Maps and similar apps.
- Consistent with Material Design 3 conventions already in use in the app.
- Low implementation complexity — a single `Stack` with a conditionally visible `FloatingActionButton` over the existing `FlutterMap` widget.
- Easy to gate entirely: `if (isAdmin) FloatingActionButton(...) else const SizedBox.shrink()`.

**Cons:**
- The FAB can obscure map content at the bottom-right of the viewport.
- On the map screen the bottom-right is already partially used (the legend button sits top-right; a FAB would be a new element). Placement must be tested on small-screen devices to avoid overlap with map controls.

**Effort:** S

---

### Option 2B — UX: Long-press context menu on the map

An admin long-pressing an empty area of the map sees a context menu with "Add discovery here", pre-filling the coordinates. Tapping an existing discovery marker shows edit/delete options.

**Pros:**
- Coordinates are captured at the tap point, reducing manual lat/lng entry in the form.
- No persistent UI element — the map chrome stays clean for non-admins and admins alike.

**Cons:**
- Discoverability is near-zero. Admins must know to long-press; there is no affordance that the gesture is available.
- The `flutter_map` package's `onLongPress` callback is available but requires careful handling to distinguish between a long-press on a marker vs. the base map layer.
- Harder to test in widget tests (long-press gesture simulation is less reliable than a button tap).

**Effort:** M

---

## Recommendation

**Admin role mechanism: Option 1B — Firestore `admins` collection.**

Option 1B requires no Cloud Functions, which keeps the infrastructure footprint minimal at this stage of the project. The billing cost of the extra `get()` in rules is negligible at the current scale (a small number of admins performing infrequent writes). The `admins` collection is immediately readable from the app, making the "Grant Admin" flow and the admin status Riverpod provider straightforward to implement without JWT decoding. The bootstrapping problem (first admin) is a one-time operation acceptable for a team-operated app.

Option 1A becomes the right choice if the project later introduces Cloud Functions for other reasons (e.g., push notifications, scheduled jobs) and the team wants to eliminate the extra Firestore read per write rule. The reversal cost is medium: the Firestore rules must be rewritten, the `admins` collection retired, and a Cloud Function scaffolded — but no user-facing code changes.

**UX affordance: Option 2A — FAB on the map screen.**

The FAB is discoverable, consistent with the existing Material 3 design system in the app, and trivially implemented as a conditionally rendered widget over the existing `Stack` in `MapScreen`. Long-press (Option 2B) is not appropriate when discoverability is a requirement — admins may be infrequent users of the creation flow and cannot be expected to discover an undocumented gesture.

**Reversal cost if the team changes its mind:**
- Switching role mechanism from 1B to 1A requires new Cloud Function infrastructure, a rewrite of `firestore.rules` for `discoveries` and `admins`, a forced token-refresh strategy, and deletion of the `admins` collection. Estimated cost: 2-3 days. No user data is lost; admin grants would need to be re-applied via the new mechanism.
- Switching UX from FAB to long-press is a presentation-layer-only change with no domain or data impact. Estimated cost: half a day.

---

## Open Questions

1. **First admin bootstrap.** Who sets the first `admins/{uid}` document, and how? Options are: a one-time `firebase firestore:import` script, a Firestore emulator seed fixture, or a documented manual Console step. The answer determines whether the bootstrap process needs to be automated in the repo's tooling.

2. **Admin revocation.** The Non-Goals section defers revocation, but the team should confirm this is acceptable before the spec is written. If an admin leaves the organization, there must be some path (even a Console operation) to delete their `admins/{uid}` document. A minimal revocation use case may be lower effort than expected and could be included in the initial scope.

3. **Discovery data model.** "Discoveries" are described as map pins / points of interest, but their schema is undefined. At minimum they need an `id`, `lat`, `lng`, `title`, and `description`. Additional fields (category, photo URL, published/draft status, associated sapling reference) must be defined before the data layer is specified. The tech spec must nail down the exact Firestore document shape.

4. **Discovery visibility.** Can regular authenticated users read all discoveries (analogous to how saplings are readable by all authenticated users), or are discoveries filtered by neighborhood, user preferences, or some other predicate? The answer affects both the Firestore rule for reads and whether a composite index is required.

5. **Relation between discoveries and saplings.** The map screen currently renders `saplings`. Will discoveries render as a separate marker layer, or can a discovery reference a sapling? If discoveries are a distinct layer, the `MarkerLayer` composition in `MapScreen` must be redesigned. The tech spec must clarify the rendering architecture.

6. **Concurrent admin sessions.** If two admins edit the same discovery simultaneously, the last write wins by default. Is optimistic-lock conflict detection (using Firestore transactions or a `updatedAt` field comparison) required at launch, or is last-write-wins acceptable for the MVP?

7. **Draft vs. published state.** Should admins be able to save a discovery as a draft (visible only to admins) before publishing it for all users? A `status: 'draft' | 'published'` field is a small schema addition but requires the read rule to distinguish admin vs. regular-user reads.

---

## Acceptance Criteria

- A user whose `admins/{uid}` document exists in Firestore can create a discovery from the map screen using the admin FAB.
- A user whose `admins/{uid}` document exists can edit any field of an existing discovery from the discovery detail screen.
- A user whose `admins/{uid}` document exists can delete an existing discovery from the discovery detail screen.
- An existing admin can grant the admin role to another registered user by entering that user's identifier from within the app; the target user's `admins/{uid}` document is created as a result.
- A non-admin authenticated user who attempts to write to the `discoveries` collection (via the Firestore SDK directly, bypassing client UI) receives a Firestore `permission-denied` error. This must be verified by a test that calls Firestore directly with a non-admin credential.
- An anonymous (guest) user who attempts to write to the `discoveries` collection receives a Firestore `permission-denied` error.
- The admin FAB is not rendered for non-admin users. A non-admin user sees no difference in the map screen UI compared to the current state.
- The edit and delete controls on a discovery detail screen are not rendered for non-admin users.
- Removing the `admins/{uid}` document (simulating role revocation) causes subsequent write attempts by that user to be rejected by Firestore rules within one session restart (i.e., the admin status is not cached indefinitely by the app).
- `flutter analyze` reports zero errors on all new and modified files.
- Every new screen and the admin FAB have corresponding widget tests.
- Firestore security rules changes are deployed and verified against the Firestore emulator before merging.
