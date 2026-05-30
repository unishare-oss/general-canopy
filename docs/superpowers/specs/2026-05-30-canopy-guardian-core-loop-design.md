# Canopy — Phase 1: Guardian Core Loop (Design Spec)

- **Date:** 2026-05-30
- **Status:** DRAFT (awaiting review)
- **Sources:** `Canopy_Concepts_and_Functions.md`, `Canopy_User_Journey_Map.md`, prototype in `Canopy/` (screens: Grove, Discover, Impact)
- **Theme decision:** adopt the prototype's warm-cream / forest-green / editorial-serif language.
- **Backend decision:** client + Firestore, plus a minimal Cloud Functions codebase **only** for adoption integrity in this phase.

---

## 1. Goal & Scope

Deliver a working, demoable vertical slice of the Guardian experience:

> Sign in → **Discover** saplings (swipe) → view **Tree Detail** → **Adopt** → **My Grove** dashboard → **log a watering**.

### In scope (maps to requirement IDs)

- F2.1 swipe deck of available saplings · F2.2 swipe right adopt / left pass · F2.3 tree detail
- F2.8 confirm adoption · F2.9 release a sapling
- F3.1 grove list with status · F3.5 next action · F3.6 health score (displayed)
- F4.4 mark/log a watering event
- Theme rebrand + seed data + 5-tab bottom-nav shell.
- **New (per stakeholder):** care-gated adoption cap, enforced by a Cloud Function.

### Out of scope (later phases)

Map view (F2.5–2.7), filters (F2.4), directions (F2.7), adoption certificate (F2.8 share), AR (F2.10),
weather-aware scheduling & push (F4.1–4.3, F4.5–4.6), photo check-ins & computed health (F5.\*),
impact/gamification (F6.\*), community/obituary (F7.\*), admin portal (F8.\*), onboarding quiz (F1.5),
profile/avatar/delete (F1.6–1.8). Health score in Phase 1 is a **stored, seeded** value rendered as
the ring — not computed.

---

## 2. Domain Concepts (Phase 1 subset)

| Concept | Phase 1 meaning |
| :---- | :---- |
| **Sapling** | Seeded, geo-tagged tree doc. Server-owned; clients never write it directly. |
| **Adoption** | A `grove/{saplingId}` doc under the user, created atomically with a `saplings.status` flip. |
| **My Grove** | The user's `grove` subcollection. |
| **Watering Event** | A logged watering under a grove tree; updates `lastWateredAt`, `wateredCount`, `waterStreak`. |
| **Neglected** | `now − lastWateredAt > wateringIntervalDays + 1d` grace. Gates new adoptions. |
| **Health Score** | Seeded 0–100 in Phase 1; rendered as the ring. Real computation = Phase 2. |

---

## 3. Firestore Schema

```
saplings/{saplingId}                    // seeded; client read-only
  nickname: string                      // "Olive"
  species: string                       // "Eastern Redbud"
  latin: string                         // "Cercis canadensis"
  personality: string                   // bio shown on card
  photoUrl: string | null
  color: string                         // hex used for the illustration tint
  street, neighborhood: string
  lat, lng: number
  ageLabel, heightLabel: string         // "Sapling · 6mo", "1.2m"
  waterNeedLabel, lightLabel: string    // "Every 3 days in summer", "Partial sun"
  wateringIntervalDays: number          // drives the "neglected" rule (default 3)
  status: 'available' | 'adopted'
  adoptedBy: string | null              // uid, server-set

users/{uid}/grove/{saplingId}           // one doc per adoption; owner-only
  saplingId: string
  nickname, species: string             // denormalized for list render
  color: string
  adoptedAt: timestamp
  healthScore: number                   // seeded snapshot in Phase 1
  lastWateredAt: timestamp              // = adoptedAt at adoption time
  wateringIntervalDays: number          // copied from sapling at adoption
  waterStreak: number                   // consecutive on-time waterings
  wateredCount: number

users/{uid}/grove/{saplingId}/wateringEvents/{eventId}   // owner-only
  wateredAt: timestamp
  amountLiters: number | null
```

Denormalizing `nickname/species/color/wateringIntervalDays` into the grove doc keeps the Grove list a
single-collection read (no N+1 fan-out to `saplings`).

---

## 4. Adoption Mechanics

All adoption/release goes through callable Cloud Functions — never direct client writes to `saplings`.

### `adoptSapling({ saplingId })` — callable, authenticated, non-anonymous

Runs a Firestore transaction:

1. **Auth gate:** reject if no auth or `auth.token.firebase.sign_in_provider == 'anonymous'` → `failed-precondition` "Sign in to adopt."
2. **Availability:** read sapling; reject if missing or `status != 'available'` → `failed-precondition` "Already adopted."
3. **Cap:** count `users/{uid}/grove`; reject if `>= MAX_ACTIVE_ADOPTIONS` (default **3**) → `resource-exhausted` "You've reached your 3-tree limit."
4. **Care gate:** if any grove tree is **neglected** (`now − lastWateredAt > wateringIntervalDays + 1d`) → `failed-precondition` "Tend your grove before adopting another."
5. **Commit:** set `saplings/{id}.status='adopted'`, `adoptedBy=uid`; create `grove/{id}` with `lastWateredAt=now`, `healthScore` from sapling seed (or default 85), `waterStreak=0`, `wateredCount=0`.

`MAX_ACTIVE_ADOPTIONS` is a function constant (env-configurable) so it's tunable without a client release.

### `releaseSapling({ saplingId })` — callable, authenticated

Transaction: verify the user owns the grove doc → delete `grove/{id}` (and its `wateringEvents`) → set
`saplings/{id}.status='available'`, `adoptedBy=null`. Frees a slot.

### Watering (client-side, no function)

`LogWatering` writes a `wateringEvents` doc and updates the parent grove doc's `lastWateredAt=now`,
`wateredCount++`, and `waterStreak` (++ if the watering was on-time, else reset to 1). Owner-only rule
permits this.

---

## 5. Clean Architecture Feature Breakdown

```
apps/mobile/lib/features/
  saplings/                         // Discovery + adoption
    data/
      datasources/  saplings_firestore_datasource.dart   // available stream, adopt/release via Functions
      models/       sapling_model.dart (freezed + json)
      repositories/ saplings_repository_impl.dart
    domain/
      entities/     sapling.dart
      repositories/ saplings_repository.dart
      usecases/     watch_available_saplings.dart, adopt_sapling.dart, release_sapling.dart
    presentation/
      providers/    available_saplings_provider.dart, adopt_controller.dart
      screens/      discover_screen.dart, tree_detail_screen.dart
      widgets/      sapling_deck.dart, sapling_card.dart, swipe_actions.dart, adoption_success_sheet.dart

  grove/                            // My Grove dashboard + care
    data/
      datasources/  grove_firestore_datasource.dart
      models/       grove_tree_model.dart, watering_event_model.dart
      repositories/ grove_repository_impl.dart
    domain/
      entities/     grove_tree.dart, watering_event.dart
      repositories/ grove_repository.dart
      usecases/     watch_my_grove.dart, log_watering.dart
    presentation/
      providers/    my_grove_provider.dart, water_controller.dart
      screens/      grove_screen.dart
      widgets/      grove_tree_card.dart, health_ring.dart, needs_you_banner.dart, grove_stats_row.dart
```

`cloud_functions` package is added to call `adoptSapling`/`releaseSapling`. Domain layer stays
framework-free (entities + repository interfaces are pure Dart).

---

## 6. Navigation & Screens

Replace the placeholder `HomeScreen` with a `StatefulShellRoute` bottom-nav shell matching the prototype:
**`Discover · Map · Grove · Impact · You`**.

| Tab | Phase 1 |
| :---- | :---- |
| Discover | Full: swipe deck → Tree Detail → adopt success. |
| Grove | Full: greeting, "needs you" banner, 3 stat tiles, adopted-tree cards w/ health ring + Water action. |
| Map / Impact / You | Stub "Coming soon" screens so the shell matches the design; filled in later phases. |

Routes: `/discover`, `/discover/:saplingId` (detail), `/grove`, `/map`, `/impact`, `/you`. Auth-gated
redirect (already present) keeps `/welcome` for signed-out users; default landing → `/grove`.

### Screen specs

- **Discover** — header "Discover / Saplings waiting on your block", (disabled-looking) filter chips for
  visual parity (functional in a later phase), draggable card deck, round pass/undo/adopt actions. Empty
  state ("No saplings nearby yet") per journey Stage 3 pain point.
- **Tree Detail** — illustration, serif name, species/latin, street + distance, personality, care chips,
  Adopt / Release button reflecting status. Surfaces function errors (cap/neglect) as a snackbar/sheet.
- **Grove** — matches `01-grove.png`: greeting w/ guardian + streak, "1 tree needs you" CTA, stat tiles
  (Trees / Day streak / Watered L), tree cards with health ring, water-status pill, Water button on the
  due tree.

---

## 7. Theme Rebrand

Rebuild the `canopy` theme in `lib/shared/theme/themes.dart` + tokens:

- **Background** warm cream (~`#F7F3EE`), **surface** white, **primary** forest green (~`#2F5D3A`/`#3B7A4E`),
  ink near-black, muted warm grays.
- **Typography:** editorial **serif** for display/headline (Google Font — *Fraunces* or *Lora*), clean
  sans for body/labels. Wire through `AppTypography`; no direct `google_fonts` in widgets.
- **New tokens:** `healthGood`, `healthAttention`, `healthRisk` (ring colors), `available` accent.
- Re-add `google_fonts` usage for the serif; keep all access via `theme.textTheme.*` / `ac.*`.

---

## 8. Security Rules

```
match /saplings/{id} {
  allow read: if request.auth != null;
  allow write: if false;                       // server/seed + Functions only (admin SDK bypasses rules)
}
match /users/{uid}/grove/{saplingId} {
  allow read:   if request.auth != null && request.auth.uid == uid;
  allow create, delete: if false;              // adoption/release via Functions (admin SDK)
  // Owner may update ONLY the care fields (the LogWatering path); everything
  // else (healthScore, adoptedAt, denormalized fields) stays server-managed.
  allow update: if request.auth != null && request.auth.uid == uid
                && request.resource.data.diff(resource.data).affectedKeys()
                     .hasOnly(['lastWateredAt', 'wateredCount', 'waterStreak']);
  match /wateringEvents/{eventId} {
    allow read, create: if request.auth != null && request.auth.uid == uid;
  }
}
match /users/{uid} { ...owner-only (existing)... }
```

Adoption/release create+delete the grove doc server-side (Functions, admin SDK bypasses rules).
`LogWatering` is the one client write, allowed via the field-restricted `update` above.

---

## 9. Cloud Functions (re-introduced)

Re-add a minimal `functions/` codebase (TypeScript, Node) at repo root:

- `functions/src/index.ts` exporting `adoptSapling`, `releaseSapling` (https `onCall`, v2).
- `MAX_ACTIVE_ADOPTIONS` constant (env override).
- Restore `functions` block in root `firebase.json`; add a lightweight functions-deploy CI workflow
  (or fold into existing deploy). Emulator config gains the `functions` port back.
- No other server logic this phase.

---

## 10. Seed Data

A Node seed script (`tools/seed_saplings.js`, service-account based) writes ~12 `saplings` docs derived
from the prototype's `canopy-data.js` (Olive, Bramble, Sprout, Pip, Juniper, …) — all `status:'available'`,
varied species/coords/`wateringIntervalDays`. Documented in SETUP.md. Re-uses the seed pattern the repo
already had.

---

## 11. Testing

- **Widget:** `discover_screen`, `tree_detail_screen`, `grove_screen`, nav shell, `health_ring`,
  `sapling_card` (+ empty states). One per screen per repo rule.
- **Unit:** `adopt_sapling` / `release_sapling` / `log_watering` usecases against a fake repository;
  `watch_my_grove` / `watch_available_saplings` stream mapping; "neglected" predicate.
- **Functions:** unit-test the cap + care-gate + availability logic against the Firestore emulator
  (adopt at limit → rejected; adopt with neglected tree → rejected; happy path → grove doc + status flip).

---

## 12. Assumptions

1. "Neglected" = `now − lastWateredAt > wateringIntervalDays + 1d grace` (Phase-1 stand-in for the
   weather-aware schedule).
2. `MAX_ACTIVE_ADOPTIONS = 3` (configurable).
3. Anonymous/guest users may browse Discover but must hold a real account to adopt.
4. Health score is a seeded snapshot, not computed, until Phase 2.
5. Tree illustrations are rendered from the seeded `color` (stylized), not real photos, in Phase 1.
