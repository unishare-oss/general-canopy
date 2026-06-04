---
title: "0001: Client-side aggregation with denormalized summary document for the Impact feature"
description: "Decision to compute and store impact metrics (CO₂, water, survival days) in a client-maintained denormalized document rather than via Cloud Functions or on-the-fly Firestore queries."
---

# 0001 — Client-side aggregation with denormalized summary document for the Impact feature

**Status:** ACCEPTED
**Author:** Architect Agent
**Date:** 2026-06-04

## Problem

The Impact feature must display aggregated environmental metrics (CO₂ offset, water given, total survival days) that are derived from per-sapling check-in events written by the Grove/Care feature. Four valid aggregation strategies exist, each with different infrastructure, consistency, and cost trade-offs. A decision is needed before the data layer is coded, because the choice determines the Firestore document structure, the security rules, and whether Cloud Functions infrastructure must be provisioned.

## Options Considered

| # | Option | Upside | Downside |
|---|--------|--------|----------|
| 1 | Client-side aggregation with a denormalized summary document at `users/{uid}/impactSummary/current` | No new infrastructure; maps cleanly to Riverpod StreamProvider; read path is a single point-document; all logic is testable pure Dart | Client is responsible for keeping the summary consistent; a crashed or offline write leaves a temporary gap |
| 2 | Cloud Functions trigger on every check-in write | Summary always consistent with raw events; server is authoritative | Requires Firebase Blaze plan, TypeScript Cloud Functions tooling, cold-start latency on every check-in; disproportionate infrastructure cost for motivational metrics |
| 3 | Pure client-side computation from raw check-in sub-collection (no summary document) | No denormalization risk; math is pure Dart | Read cost scales with adoption history; leaderboard is impossible without server aggregation; latency grows with user tenure |
| 4 | Hybrid: summary document (Option 1) + raw sub-collection for future Cloud Function reconciliation | Cleanest long-term path | Same consistency risk as Option 1 today, with added write overhead; the reconciliation value is deferred until Cloud Functions are introduced |

## Decision

**Chosen:** Option 1 — Client-side aggregation with a denormalized summary document.

The Impact feature stores metrics that are motivational rather than financial or legal, so a bounded consistency gap (the window between a check-in write and a summary update, which is at most one client session) is acceptable. The project has no Cloud Functions infrastructure today, and introducing it purely for dashboard aggregation is disproportionate to the risk. Option 1 delivers all dashboard requirements within the existing Dart + Firestore stack; if the city forestry reporting requirement later demands server-authoritative aggregation, Option 4 is a backward-compatible upgrade path — the summary document schema is preserved.

## Reversal Cost

Medium. Moving to Cloud Functions aggregation (Option 2 or 4) requires writing TypeScript trigger functions that reproduce the client-side aggregation logic, provisioning the Blaze plan, and adding Cloud Functions deployment to the CI pipeline. The Firestore sub-collection schema and security rules defined for Option 1 are compatible with a future Cloud Function reading the same documents, so the data migration cost is low. The primary cost is the new infrastructure concern and the TypeScript test surface.

## Consequences

**Easier:** The full Impact feature can be built and shipped with no backend changes beyond Firestore rules and indexes. The aggregation logic lives in pure Dart use cases that are straightforward to unit test. The leaderboard can be written by the client in the same transaction path as the summary update.

**Harder:** Any future reconciliation audit (e.g., verifying that the summary matches the raw check-in count) requires either a Cloud Function or a one-time migration script. The client must implement idempotent badge-award writes to avoid duplicate achievement documents on retry.

**Follow-up decisions required:** The Grove/Care feature spec must confirm the `saplingAdoptions/{saplingId}` document field names (`streakDays`, `lastCheckIn`, `adoptedAt`, `wateringIntervalDays`) before Impact coding begins, since both features share the same sub-collection.
