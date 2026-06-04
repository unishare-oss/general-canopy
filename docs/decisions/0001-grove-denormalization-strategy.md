---
title: "0001: Grove Adoption Document Denormalization Strategy"
status: "Accepted"
date: "2026-06-03"
---

# ADR-0001: Grove Adoption Document Denormalization Strategy

**Status:** Accepted
**Date:** 2026-06-03
**Context:** SPEC-0002 My Grove

---

## Problem

The My Grove list screen must render a card for every adopted sapling showing
nickname, species, neighborhood, cover photo, health score, and next action.
The canonical sapling data lives in `saplings/{saplingId}`. Without a join
strategy the list screen either issues N+1 Firestore reads (one per adoption
for the sapling doc) or fetches the entire `saplings` collection.

---

## Options considered

**Option A — Live join (N+1 reads).**
Query `users/{uid}/adoptions`, then for each result fetch `saplings/{saplingId}`.
- Upside: single source of truth for sapling fields; no sync burden.
- Downside: N+1 Firestore reads on every list load; latency spikes as grove
  size grows; each read counts against billing and quotas.

**Option B — Client-side fan-out with `whereIn` query.**
Query `users/{uid}/adoptions` to get all `saplingId` values, then batch-fetch
`saplings` using a `whereIn` query (limit 30 per query).
- Upside: two reads regardless of grove size up to 30 saplings.
- Downside: adds complexity; `whereIn` limit of 30 requires pagination logic;
  still fetches more fields than needed; sapling data is read-only so freshness
  is not a concern.

**Option C — Denormalize display fields into the adoption document.**
Copy `nickname`, `species`, `neighborhood`, `colorHex`, and `photoUrl` from
the sapling into each `users/{uid}/adoptions/{adoptionId}` document at adoption
time. The adoption document also owns `healthScore`, `nextActionAt`,
`nextActionType`, and `coverPhotoUrl` (user-uploaded).
- Upside: the grove list requires exactly one Firestore collection query with
  zero joins. Scales to any grove size at O(1) reads.
- Downside: display fields are stale if the sapling catalog is edited. A
  background sync (or adoption-time copy) must keep them fresh.

**Option D — Subcollection-free flat document with embedded arrays.**
Store photos and history as arrays inside the adoption document.
- Upside: single document read for the detail screen.
- Downside: arrays cannot be queried or ordered server-side; document size cap
  (1 MB) is easily exceeded; Firestore does not support partial array updates.

---

## Decision

**Option C — denormalize display fields into the adoption document.**

The grove list is the highest-frequency read in the app and must render
instantly. A single collection query is the only approach that gives O(1) reads
regardless of grove size. The sapling catalog is managed by the platform
(not the user) and changes infrequently, so stale display fields are acceptable
in the MVP and can be refreshed by a Cloud Function trigger on the sapling
document if needed in a future iteration.

Photos and history are stored as sub-collections (not embedded arrays) to allow
server-side ordering, pagination, and future write access without document-size
risk.

---

## Consequences

- The adoption write path (out of scope for this MVP, belongs to Discover) must
  copy the five display fields at creation time.
- If a sapling's `nickname`, `species`, `neighborhood`, `colorHex`, or
  `photoUrl` changes after adoption, the adoption document will show stale data
  until a sync mechanism is implemented.
- Reversal cost: **medium.** Switching to a live-join strategy requires removing
  the denormalized fields, updating `AdoptionModel.fromFirestore`, and rewriting
  the `GroveFirestoreDatasource` and any tests that depend on the flat document
  shape. No schema migration is needed for existing documents — unused fields
  are ignored by Firestore.
