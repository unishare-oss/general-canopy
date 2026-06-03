---
title: "0001: Authentication and Onboarding Flow"
description: "Adapt the Unishare auth boilerplate for Canopy: strip academic fields, add Canopy-specific profile, and introduce a 4-step post-auth onboarding quiz."
---

# PROP-0001: Authentication and Onboarding Flow

**Status:** ACCEPTED
**Author:**
**Date:** 2026-06-03
**Spec:** (pending)
**Approved by:** Slade

---

## Problem

Canopy requires authentication for two equally important reasons.

**Personalization.** Users adopt specific street trees, build a personal grove, set check-in frequency preferences, and receive watering reminders tuned to their neighborhood. None of that state is meaningful without a stable identity to attach it to. A guest can browse the map and read tree profiles, but the moment they attempt to adopt or log a care activity the system has nothing to commit the action to.

**Data integrity.** The city forestry team relies on Canopy's care logs as an auditable record: who watered which tree, when, and how much. Duplicate adoptions (two accounts claiming the same tree) corrupt the dataset. Attributing logs to a named, verified user — rather than an ephemeral device ID — is the foundational requirement for the forestry dashboard to be trustworthy.

The existing boilerplate ships a working auth stack (Firebase Auth, Firestore user document, GoRouter redirect guard, Riverpod stream provider), but every entity, model, use case, and screen carries Unishare-specific fields: `universityId`, `departmentId`, `enrollmentYear`, `bio`, and the `role: 'student'` default. The `AcademicProfileBottomSheet` widget and `departments_provider` / `universities_provider` providers have no place in a tree-care app. Shipping them untouched would mean dead code in production and a confusing profile surface for users.

There is also no onboarding flow. The prototype (`Canopy/app/canopy-app.jsx`) specifies a 4-step `OnboardingQuiz` (welcome, neighborhood, check-in frequency, plant experience) that must run immediately after first sign-up — before the user reaches the home screen. Nothing in the boilerplate implements this gate.

---

## Goals

1. Three sign-in methods at launch: Email + password, Google Sign-In, and anonymous guest.
2. Guest users can browse the map and tree profiles freely. Any action that requires commitment (adopt, log care, set reminders) must redirect them to the sign-in/sign-up screen with a contextual prompt.
3. New registered users (both email and Google first-time sign-in) are immediately routed through the 4-step onboarding quiz before reaching the home screen.
4. The onboarding quiz collects: neighborhood, check-in frequency, and plant experience level. All four steps can be navigated with back/skip/next; the final CTA ("Find me a tree") commits the data and navigates to `/discover`.
5. Returning users who have already completed onboarding skip the quiz entirely.
6. The `AppUser` domain entity carries only Canopy-relevant fields: `id`, `name`, `email`, `photoUrl`, `neighborhood`, `checkInFrequency`, `plantExperience`, `notificationPreferences`, `isAnonymous`, `providerIds`, `onboardingComplete`.
7. The guest-to-registered upgrade path preserves any locally cached browse state (e.g., a tree the guest was viewing) and routes back to the original context after sign-up.
8. All auth and onboarding code must conform to the project's Clean Architecture constraints: zero Flutter or Firebase imports in the domain layer.

---

## Non-Goals

The following are explicitly out of scope for this proposal and its resulting spec:

- Apple Sign-In (can be added post-launch without breaking the architecture)
- Phone / SMS authentication
- Biometric (Face ID / fingerprint) authentication
- Two-factor authentication
- Password reset via in-app flow (Firebase's default email reset link is acceptable at launch)
- Social features such as following other users or sharing a grove
- Admin or forestry-team role management (separate proposal required)
- In-app notification delivery (notification preferences are stored here; actual delivery is a separate feature)

---

## Options

### Option A — Adapt the existing boilerplate (recommended)

Retain the full Clean Architecture stack already wired: `FirebaseAuthDatasource`, `FirestoreUserDatasource`, `AuthRepositoryImpl`, `authStateProvider`, `guestModeProvider`, and the GoRouter redirect guard. Make targeted changes:

- **Domain layer:** Replace `AppUser` fields (`universityId`, `departmentId`, `enrollmentYear`, `bio`, `role`) with Canopy fields (`neighborhood`, `checkInFrequency`, `plantExperience`, `notificationPreferences`, `onboardingComplete`). Add `UpdateUserProfile` use case; delete `UpdateAcademicProfile`.
- **Data layer:** Update `AppUserModel` and `FirestoreUserDatasource` to match the new schema. Remove the `universities` and `departments` Firestore collection references entirely. Add `onboardingComplete` flag to the Firestore user document; use it in `authStateChanges` to determine whether to route to onboarding.
- **Presentation layer:** Strip `universities_provider.dart` and `departments_provider.dart`. Delete `AcademicProfileBottomSheet`; replace with a new `OnboardingQuizScreen` (full-screen, 4-step, integrated into GoRouter as `/onboarding`). Update `AuthScreen` (`welcome_screen.dart`) to remove the university dropdown and Unishare copy; update subheading and email hint text to be app-agnostic. Add a router redirect rule: authenticated users whose `onboardingComplete == false` are sent to `/onboarding` before `/grove`.

**Upside:** Approximately 70% of the implementation is already correct and tested. The Firebase Auth flow, the `authStateChanges` stream, the GoRouter redirect logic, the `AuthTextField` and `GoogleSignInButton` widgets, and the `signInAnonymously` path all work today. Risk is low; the delta is well-scoped.

**Downside:** Editors must touch 12-15 files across all three layers. Without discipline, Unishare remnants (e.g., `role: 'student'` default, comment references to academic profiles) can be left behind. Requires a careful audit pass before the PR is merged.

### Option B — Delete the boilerplate auth feature and build from scratch

Remove `apps/mobile/lib/features/auth/` entirely and create a new `auth` feature with Canopy-specific naming from the first line. No Unishare assumptions carry forward.

**Upside:** Zero risk of legacy field leakage. The code tells a coherent Canopy story from day one. Easier to reason about for new contributors who have never seen Unishare.

**Downside:** Discards working Firebase Auth integration, a fully wired GoRouter guard, Riverpod stream providers, and two reusable widgets (`AuthTextField`, `GoogleSignInButton`) that have no Unishare coupling at all. Estimated additional effort: 3-5 days of rework that produces no new user value. Introduces regression risk on the auth flow itself during the rewrite. Contradicts the boilerplate's stated purpose of providing a validated foundation.

---

## Recommendation

**Option A — Adapt the boilerplate.**

The boilerplate's Clean Architecture layering is already correct; the only problem is domain vocabulary (Unishare fields) and two presentation-layer artifacts (`AcademicProfileBottomSheet`, `universities_provider`, `departments_provider`). Surgical replacement of those artifacts costs a fraction of a full rewrite and carries significantly lower regression risk on the auth flow itself. Option B would be warranted only if the boilerplate's architectural approach were wrong — it is not.

**Reversal cost if the team changes its mind:** Low. Because Option A keeps layer boundaries clean, a future decision to scrap and rewrite would start from the same Clean Architecture foundation regardless. The Firestore user document schema (defined in the tech spec) is the only artifact that would need migration; Firebase Auth credentials are provider-agnostic and survive any app rewrite.

---

## Open Questions

1. **Firestore user document schema.** The proposal names the fields; the tech spec must nail down exact Firestore field names, types, and whether `checkInFrequency` and `plantExperience` are stored as strings (enum values) or integers. A decision is needed before the data layer is coded.

2. **Onboarding data write timing.** The prototype's final CTA is "Find me a tree" (step 4). Should the quiz answers be written to Firestore only when the user taps that final CTA, or incrementally as each step is completed? Incremental writes let the app resume a partially completed quiz after a crash; deferred writes reduce Firestore write operations but lose progress on force-quit. This is a UX and cost trade-off that the product owner should resolve.

3. **Guest-to-registered upgrade path in detail.** When an anonymous user taps "adopt" and is prompted to sign in, then completes sign-up, should the app: (a) merge the Firebase anonymous UID into the new account using `linkWithCredential` so any local draft state survives, or (b) treat them as a new user and discard the anonymous session? Option (a) is more complex but preserves context. The tech spec must specify which approach is required.

4. **Onboarding quiz skip behavior.** The prototype renders a "Skip" button on every step. If a user skips, `onboardingComplete` should still be set to `true` so they are not re-shown the quiz on next launch. However, skipped fields (`neighborhood`, `checkInFrequency`, `plantExperience`) would be null. The spec must define how null onboarding fields affect tree recommendations and reminder scheduling downstream.

5. **Neighborhood data source.** The prototype hardcodes four example districts. For production, the district list must come from somewhere (Firestore collection, Remote Config, or bundled asset). The choice affects the data layer design; it must be decided before the datasource is implemented.

6. **`notificationPreferences` schema.** This field is named in Goal 6 but its internal structure is unspecified (e.g., boolean flags per reminder type, or a map of `{type: string, enabled: bool, reminderDays: int}`). The tech spec must define the schema before the domain entity is written.

---

## Acceptance Criteria

- A user can create an account with email + password; the account persists across app restarts.
- A user can sign in with Google; a new Firestore user document is created on first Google sign-in and not re-created on subsequent sign-ins.
- A guest user can open the app, browse the map, and view tree profiles without creating an account.
- When a guest user attempts to adopt a tree, they are redirected to the sign-in/sign-up screen; after completing sign-up they are returned to the adoption context.
- After sign-up (email or Google, first time only), the user is routed to the onboarding quiz (`/onboarding`) before any tab of the main shell is shown.
- The onboarding quiz has exactly 4 steps matching the prototype: (1) welcome/intro, (2) neighborhood selection, (3) check-in frequency, (4) plant experience.
- Completing or skipping the quiz writes `onboardingComplete: true` to the Firestore user document and navigates the user to `/discover`.
- A returning registered user whose `onboardingComplete == true` goes directly to `/grove` on launch without seeing the quiz.
- The `AppUser` domain entity contains no fields named `universityId`, `departmentId`, `enrollmentYear`, `bio`, or `role`. Running `grep -r "universityId\|departmentId\|enrollmentYear" apps/mobile/lib/features/auth/domain` returns zero results.
- `departments_provider.dart` and `universities_provider.dart` do not exist in the delivered code.
- `academic_profile_dialog.dart` does not exist in the delivered code.
- The `AuthRepository` interface (domain layer) contains no reference to `updateAcademicProfile`.
- `flutter analyze` reports zero errors on the auth and onboarding feature directories.
- Every new screen has a corresponding widget test.
- The auth redirect guard correctly handles the three routing cases: unauthenticated non-guest to `/welcome`, authenticated user with `onboardingComplete == false` to `/onboarding`, authenticated user with `onboardingComplete == true` to `/grove`.
