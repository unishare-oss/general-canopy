---
title: "0004: Avatar Upload & Notification Permissions"
description: "Profile avatar upload stored inline in Firestore, and real browser notifications behind the existing preference toggles."
---

# PROP-0004: Avatar Upload & Notification Permissions

**Status:** PROPOSED
**Author:** bambi
**Date:** 2026-06-05
**Spec:** [SPEC-0004](../tech-specs/0004-avatar-and-notifications.md)
**Approved by:** (fill in when accepted)

---

## Problem

F1.7 ("Upload profile avatar", MVP) is unimplemented — avatars only come from
Google OAuth. And the notification preference toggles added in SPEC-0003 only
persist a boolean; nothing observable happens, so users (and the PM) can't tell
they "work".

## Proposed Solution

**Avatar:** pick an image with `image_picker`, downscale/crop to a 256px
square JPEG (~20-40 KB) with `package:image`, and store it base64-encoded in
the `users/{uid}` Firestore doc (`avatarBase64`), guarded by a 128 KiB
security-rule cap. Uploaded avatar takes precedence over the OAuth `photoUrl`.

**Notifications:** a `NotificationService` facade in `core/notifications`
(conditional import: browser Notification API on web via `package:web`;
unsupported stub elsewhere). Turning a toggle ON requests permission first —
granted → save + confirmation notification; denied → toggle reverts with a
snackbar. Turning OFF saves directly.

## Alternatives Considered

### A — Firebase Storage for avatars

The production-grade path. **Rejected (for now):** creating a Storage bucket
requires upgrading the team Firebase project to the paid Blaze plan; verified
unavailable on `canopy-30d09` today. Revisit when billing is enabled.

### B — `flutter_local_notifications` everywhere

**Rejected (for now):** the package has no web support, and the team currently
tests on Chrome only. The `NotificationService` facade leaves a clean slot for
an Android/iOS implementation later.

## Open Questions

1. Saplings denormalize `adoptedByPhotoUrl` at adoption time — a changed
   avatar is stale on map pins until re-adoption. Propagate on change?
   (Deferred: needs a batched write across all adopted saplings.)

## Acceptance Criteria

- Tapping the avatar (camera badge) opens the system picker; the chosen photo
  appears immediately and persists across reloads, beating `photoUrl`.
- Cancelling the picker changes nothing; unreadable images show an error.
- Toggling a notification preference ON prompts for permission, saves only
  when granted, and shows a visible confirmation notification.
- Denied permission leaves the toggle OFF and explains why in a snackbar.
- Firestore rules reject avatar payloads ≥ 128 KiB.
