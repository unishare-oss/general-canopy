# Copilot Instructions — Canopy

Canopy is a cross-platform Flutter app (iOS, Android, Web), Firebase-native,
bootstrapped from the Unishare Flutter boilerplate.

**The authoritative project guide is [`../CLAUDE.md`](../CLAUDE.md).** Read it
for architecture, stack, conventions, theming tokens, and the planning
workflow. First-time setup steps are in [`../SETUP.md`](../SETUP.md).

## Quick reference

- **Architecture:** strict Clean Architecture — Domain layer has zero Flutter
  or Firebase imports. Features live in `apps/mobile/lib/features/<name>/`
  split into `data/`, `domain/`, `presentation/`.
- **State:** `flutter_riverpod` with `@riverpod` codegen.
- **Navigation:** `go_router` (config in `lib/core/router/router.dart`).
- **Imports:** always `package:canopy/...`, never relative.
- **Theming:** use `cs.*` (ColorScheme) / `ac.*` (AppColors) and
  `theme.textTheme.*` — no hardcoded colors, sizes, or fonts.
- **Codegen:** never edit `*.g.dart` / `*.freezed.dart`; run
  `dart run build_runner build`.
- Run `flutter analyze` and `dart format .` before every commit.
