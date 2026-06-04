---
title: "0002: Impact Dashboard"
description: "Give users a personal environmental dashboard showing CO₂ offset, water contribution, sapling streaks, achievement badges, a neighborhood leaderboard, and an activity feed — with native social sharing."
---

# PROP-0002: Impact Dashboard

**Status:** PROPOSED
**Author:** Architect Agent
**Date:** 2026-06-04
**Spec:** [SPEC-0002](../tech-specs/0002-impact.md)
**Approved by:** (pending)

---

## Problem

Canopy's core value proposition is that individual tree-care actions aggregate into measurable environmental benefit. Right now, users who adopt and water saplings receive no feedback about the real-world impact of those actions. There is no answer to the questions "How much CO₂ have my trees offset?" or "How does my grove compare to my neighborhood?" Without that feedback loop, users lack intrinsic motivation to maintain check-in streaks, and churn risk increases after the novelty of the first adoption fades.

Three concrete gaps drive this proposal:

1. **No impact quantification.** The app stores per-sapling adoptions and watering check-ins but never aggregates them into user-facing environmental metrics (CO₂, water, survival days).
2. **No progress recognition.** Users who maintain multi-week check-in streaks or hit adoption milestones receive no acknowledgment. Achievement psychology (first adopter, week warrior) is a proven retention lever in environmental apps.
3. **No social context.** Users cannot see how their contribution compares to neighbors, removing an important community hook that is central to the Canopy pitch to city forestry partners.

The Impact screen stub already exists at `features/impact/presentation/screens/impact_screen.dart` but renders only a placeholder. This proposal designs the full feature that replaces it.

---

## Goals

1. Display an Impact Summary card: CO₂ offset (kg), water given (liters), and total sapling survival days aggregated across all of the user's adopted saplings.
2. Translate raw metrics into real-world equivalents: car miles offset, showers-worth of water saved.
3. Show per-sapling check-in streak (consecutive days) with an active/lapsed status indicator.
4. Award and display achievement badges for milestones: First Adopter, Week Warrior, Month Milestone, Carbon Hero, Water Guardian, and Neighborhood Champion.
5. Display a neighborhood leaderboard (top 20 users ranked by CO₂ offset) scoped to the authenticated user's neighborhood.
6. Provide a scrollable activity feed (last 20 entries) showing chronological adoption and care events.
7. Allow users to share their impact summary or a specific badge to social media via the native share sheet.
8. All new domain entities and use case interfaces must be pure Dart with zero Flutter or Firebase imports.

---

## Non-Goals

The following are explicitly out of scope for this proposal and its resulting spec:

- Push notifications triggered by streak milestones or leaderboard position changes (separate notification feature)
- City-wide or global leaderboards (neighborhood scope is sufficient at launch)
- PDF certificate generation (share sheet uses plain text + a pre-rendered stat string)
- In-app social following or commenting on other users' activity
- Cloud Functions or server-side aggregation (all metrics are computed at the client using Firestore streams; a future server-side aggregation proposal may supersede this)
- Gamification beyond the six named badges (badge definitions are extensible; new badges require no architectural change)
- Animated impact visualization or 3D tree rendering
- Historical trend charts (line graph of CO₂ over time)

---

## Options

### Option A — Client-side aggregation with a denormalized summary document (recommended)

Store a pre-computed `users/{uid}/impactSummary` document that is updated by the client whenever a watering check-in or adoption event occurs. Keep per-sapling streak state in `users/{uid}/saplingAdoptions/{saplingId}`. Achievements and activity feed live in sibling sub-collections. The leaderboard is a root-level collection (`neighborhoodLeaderboard/{neighborhood}/entries/{uid}`) updated by the same client write that updates the summary.

**Upside:** All reads are point-document or small sub-collection reads — no cross-collection joins in the critical render path. The Firestore listener architecture maps cleanly onto Riverpod `StreamProvider`. No Cloud Functions dependency means zero additional infrastructure cost and no cold-start latency. The data layer is straightforward: one datasource per sub-collection.

**Downside:** The client is responsible for keeping the denormalized summary consistent with the raw check-in data. A crashed or offline client can produce a temporary inconsistency (e.g., summary not updated after a successful check-in). Leaderboard entries are written by clients, which means the leaderboard Firestore security rules must be carefully scoped (users can only write their own entry). The summary document is not the authoritative source of truth — a future reconciliation job would need to replay raw events.

### Option B — Cloud Functions aggregation on every check-in write

Every watering check-in triggers a Firestore-triggered Cloud Function that recomputes the user's impact summary and updates the leaderboard entry atomically on the server.

**Upside:** Summary and leaderboard are always consistent with raw event data. The client never performs aggregation logic — it only reads. Easier to audit and reconcile for the city forestry reporting requirement.

**Downside:** Requires Firebase Blaze plan (paid tier), introduces Cloud Functions as a new dependency requiring separate deployment, and adds cold-start latency (200–800 ms) on every check-in. Cloud Functions development, testing, and deployment are outside the current skill set documented for this project. This is a disproportionate infrastructure investment for a metric that users see on a dashboard — not in real time during a check-in.

### Option C — Pure client-side computation from raw check-in sub-collection (no summary document)

Compute CO₂, water, and streaks entirely in the client by reading all check-in documents for all adopted saplings on every dashboard open. No pre-computed document.

**Upside:** No denormalization means no consistency risk. The math is done in a pure Dart use case — easily testable.

**Downside:** A user with 10 adopted saplings and 6 months of check-ins would load hundreds of Firestore documents per dashboard visit. Read cost scales with usage and will become expensive both financially and in latency. Leaderboard computation becomes impossible without server-side support (you cannot read all users' check-ins to rank them from the client). This option does not support the leaderboard requirement.

### Option D — Hybrid: summary document for dashboard, raw sub-collection for audit

Pre-computed summary document (as in Option A) for the dashboard read path. The authoritative raw check-in events remain in a separate sub-collection. A background reconciliation Cloud Function can be added later without changing the client.

**Upside:** Combines the read-path performance of Option A with the long-term reconciliation path of Option B. Architecturally cleanest for future evolution.

**Downside:** Two sources of truth exist during the period before a Cloud Function is added. This is the same consistency risk as Option A, with the added complexity of a sub-collection the client writes to but does not read in the dashboard path. Given the team has no Cloud Functions tooling today, Option D defers the reconciliation value while paying the consistency risk cost now — the same net position as Option A, with extra write overhead.

---

## Recommendation

**Option A — Client-side aggregation with a denormalized summary document.**

The app does not yet have Cloud Functions infrastructure, and the check-in frequency (at most once per sapling per day) means the consistency window between a check-in and a summary update is bounded and user-visible immediately. The six named badge milestones and the leaderboard are low-stakes data (motivational, not financial), so a transient inconsistency during an offline session is acceptable. Option A delivers all seven goals within the existing Dart + Firestore stack, with no new backend dependencies, in a time frame proportional to the feature's complexity.

**Reversal cost if the team changes its mind:** Medium. Moving to Option B (Cloud Functions) requires writing trigger functions that replay the existing client-side aggregation logic in TypeScript, migrating the summary document schema if it needs to change, and adding Cloud Functions to the Firebase project and CI pipeline. The Firestore sub-collection structure designed in Option A is compatible with a future Cloud Function reading the same documents — the client write path is the only thing that changes.

---

## Open Questions

1. **Check-in event source of truth.** This proposal assumes watering check-ins are written to `users/{uid}/saplingAdoptions/{saplingId}` by the (forthcoming) Grove/Care feature. The Impact feature reads from this sub-collection to compute streaks. The Grove feature's data model must be compatible with the field names specified in the tech spec (`lastCheckIn`, `streakDays`, `adoptedAt`). Coordination with the Grove feature spec is required before this spec is approved.

2. **CO₂ calculation authority.** The simplified constants (0.0575 kg CO₂/day/sapling, 2 liters/watering) are estimates. The city forestry partner may supply authoritative values that differ. The constants should be defined in a single location (`lib/features/impact/domain/constants/impact_constants.dart`) so they can be updated in one place. The team should confirm whether the forestry partner needs to approve the constants before launch.

3. **Leaderboard security rules.** Users write their own leaderboard entry. The Firestore rule must allow a user to write only the document keyed to their own UID within the neighborhood's leaderboard sub-collection. The security-reviewer agent must audit this rule before the feature ships.

4. **Badge award trigger.** Badges are awarded when a threshold is crossed (e.g., `co2OffsetKg >= 10` for Carbon Hero). The client must check badge eligibility on every summary update and write the badge document if it does not yet exist. This is an idempotent write. The spec must define the complete badge threshold table so the Flutter engineer can implement the eligibility check in a pure Dart use case.

5. **Activity feed population.** The activity feed (`users/{uid}/activityFeed`) must be written to by whatever feature performs adoptions and check-ins (the Grove feature). This proposal defines the read interface and document schema; the write responsibility belongs to the Grove feature. If the Grove feature ships after Impact, the feed will be empty at Impact launch — this is acceptable, but the team should align on the sequencing.

6. **Leaderboard neighborhood scope at onboarding.** The leaderboard is scoped to `AppUser.neighborhood`. A user who has not completed onboarding (neighborhood is null) has no leaderboard to show. The Impact screen must handle the null neighborhood case gracefully (e.g., a prompt to complete onboarding or a hidden leaderboard section).

---

## Acceptance Criteria

- Given a user who has adopted 2 saplings and each has been alive for 30 days, the dashboard displays a CO₂ offset value of at least 3.45 kg (2 × 30 × 0.0575).
- Given a user who has logged 10 watering check-ins across all saplings, the dashboard displays a water given value of at least 20 liters.
- Given a sapling with 7 consecutive daily check-ins, the streak card for that sapling displays 7 days and an active status indicator.
- Given a sapling with the last check-in more than `wateringIntervalDays + 1` days ago, its streak card displays a lapsed status.
- Given a user whose CO₂ offset crosses 10 kg, the Carbon Hero badge appears in the badge grid.
- The leaderboard displays at most 20 entries, scoped to the authenticated user's neighborhood, ordered by CO₂ offset descending.
- Tapping the share FAB opens the native share sheet with a pre-formatted impact string.
- The domain layer (`features/impact/domain/`) contains zero imports of `package:flutter` or `package:cloud_firestore`.
- `flutter analyze` reports zero errors on `lib/features/impact/`.
- Every new screen and widget with non-trivial logic has a corresponding widget or unit test.
