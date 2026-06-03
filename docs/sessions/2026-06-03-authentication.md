---
date: 2026-06-03
task: authentication
---

# Session: 2026-06-03-authentication

**Date:** 2026-06-03  
**Member:**  
**Agent:** flutter-engineer  
**Task:** Implement authentication and onboarding flow per SPEC-0001

## Context

PROP-0001 (ACCEPTED) and SPEC-0001 (APPROVED) are in place. The boilerplate ships a working Firebase Auth stack but carries Unishare-specific vocabulary throughout. This session strips the Unishare artifacts and adds the Canopy profile fields and onboarding quiz.

Reference:
- Spec: `tech-specs/0001-authentication.md`
- Proposal: `tech-proposals/0001-authentication.md`
- Design prototype: `Canopy/app/canopy-app.jsx` (OnboardingQuiz component)

## Plan

1. **Domain layer** — Modify `app_user.dart` (swap Unishare → Canopy fields). Delete `update_academic_profile.dart`. Stub files for `check_in_frequency.dart`, `plant_experience.dart`, `notification_preferences.dart` are already created — no further action needed. Modify `auth_repository.dart` (remove `updateAcademicProfile`, add `updateUserProfile`, `linkAnonymousAccount`).

2. **Data layer** — Modify `app_user_model.dart` (update JSON field mapping). Modify `firebase_auth_datasource.dart` (add `linkWithCredential`). Modify `firestore_user_datasource.dart` (remove Unishare collection refs, add Canopy field reads/writes). Modify `auth_repository_impl.dart` (implement new methods, remove old).

3. **Presentation — deletions** — Delete `academic_profile_dialog.dart`, `departments_provider.dart`, `universities_provider.dart`.

4. **Presentation — modifications** — Modify `welcome_screen.dart` (remove university dropdown, update copy). Wire `update_user_profile.dart` use case into `onboarding_provider.dart`.

5. **Presentation — new screens/widgets** — Implement `onboarding_screen.dart` (4-step PageView). Implement `onboarding_step_neighborhood.dart`, `onboarding_step_frequency.dart`, `onboarding_step_experience.dart`.

6. **Router** — Add `/onboarding` route in `core/router/`. Extend redirect guard for three cases (see spec).

7. **Run `build_runner`** after any Riverpod provider changes.

8. **Tests** — write 12 test files per the spec test plan.

## Notes

<!-- Running notes during the session — discoveries, blockers, pivots. -->

## Handoff

**To:** security-reviewer  
**Done:**  
**Not done:**  
**Watch out for:** `linkWithCredential` error path — if the Google/email credential belongs to an existing account, Firebase throws `credential-already-in-use`. The spec maps this to `AuthFailureType.emailAlreadyInUse` — confirm the error code mapping in `firebase_auth_datasource.dart`.
