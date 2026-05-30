# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Project Overview

**Canopy** is a cross-platform Flutter app (iOS, Android, Web), Firebase-native.
It was bootstrapped from the Unishare Flutter boilerplate: Clean Architecture,
Riverpod, GoRouter, and a Firebase backend. Auth (email + Google + guest) and
the theming system are in place; everything else is yours to build.

## Repo Structure

```
.
├── CLAUDE.md
├── SETUP.md             ← one-time setup steps (Firebase, codegen) — read this first
├── .claude/
│   ├── settings.json
│   ├── agents/          ← architect, flutter-engineer, qa-engineer, security-reviewer
│   ├── hooks/           ← automated logging and git guardrails
│   └── skills/
├── apps/
│   └── mobile/          ← Flutter app (run all flutter commands from here)
│       ├── lib/
│       ├── test/
│       ├── integration_test/
│       ├── android/
│       └── ios/
├── packages/            ← shared Dart packages (reserved; empty)
├── tools/               ← repo scripts + git hooks
├── tech-proposals/      ← Tech Proposals
├── tech-specs/          ← Tech Specs
├── docs/
│   ├── decisions/       ← Architecture Decision Records
│   ├── sessions/        ← per-session agent scratchpads
│   ├── agent-runs/      ← structured reviewer audit reports
│   └── stencils/        ← templates for proposals, specs, ADRs
├── firestore.rules      ← Firestore security rules
├── firestore.indexes.json
├── firebase.json        ← Firestore config + emulator ports
└── .github/workflows/   ← CI (analyze/test/build) + release
```

## Commands

All Flutter commands run from `apps/mobile/`:

```bash
cd apps/mobile

flutter pub get                    # Install dependencies
flutter run                        # Run on connected device/emulator
flutter run -d chrome              # Run on web
flutter build apk                  # Build Android APK
flutter build web                  # Build for web
flutter test                       # Run unit + widget tests
flutter test --coverage            # Run tests with coverage report
flutter test integration_test/     # Run integration tests
flutter analyze                    # Static analysis
dart format .                      # Format all Dart files
dart run build_runner build        # Generate Riverpod/Freezed code
dart run build_runner watch        # Watch mode for code gen
flutterfire configure              # Link to your Firebase project
```

Firebase commands run from the **repo root** (where `firebase.json` lives):

```bash
firebase deploy --only firestore:rules     # Deploy Firestore security rules
firebase deploy --only firestore:indexes   # Deploy Firestore indexes
firebase deploy --only firestore           # Deploy both
firebase emulators:start                   # Local auth + firestore emulators
```

> First-time setup (Firebase project, `flutterfire configure`, codegen) is in
> **`SETUP.md`** — the app will not build until those steps are done.

## Architecture

Strict Clean Architecture — the Domain layer must have **zero Flutter or Firebase imports**.

```
apps/mobile/lib/
  features/<name>/
    data/
      datasources/     ← Firebase/Firestore calls, DTOs
      models/          ← Freezed models with JSON serialization
      repositories/    ← implements domain interfaces
    domain/
      entities/        ← pure Dart classes, no framework imports
      repositories/    ← abstract interfaces
      usecases/        ← single-responsibility use case classes
    presentation/
      providers/       ← Riverpod providers (@riverpod code gen)
      screens/         ← GoRouter screen widgets
      widgets/         ← feature-scoped reusable widgets
  shared/
    widgets/           ← app-wide reusable components
    theme/             ← ThemeData, typography, color tokens
  core/
    firebase/          ← Firebase initialization
    storage/           ← Hive setup and helpers
    logging/           ← AppLogger (Crashlytics wrapper)
    router/            ← GoRouter config + auth-gated redirect

apps/mobile/test/
  unit/
  widget/

apps/mobile/integration_test/
```

The boilerplate ships two features: `auth` (full Clean Architecture stack) and
`home` (a placeholder landing screen). Use `auth` as the reference example when
building new features.

## Stack

| Concern    | Package                                     |
| ---------- | ------------------------------------------- |
| State      | `flutter_riverpod` + `riverpod_generator`   |
| Navigation | `go_router`                                 |
| Auth       | `firebase_auth`, `google_sign_in`           |
| Database   | `cloud_firestore`                           |
| Offline    | `hive_flutter`                              |
| Logging    | `firebase_crashlytics`                      |
| Models     | `freezed` + `json_serializable`             |
| Typography | `google_fonts` (Space Grotesk + Fira Code)  |
| SVG        | `flutter_svg`                               |

> The boilerplate was trimmed to a lean dependency set. Add packages
> (`firebase_storage`, `firebase_messaging`, `cached_network_image`,
> `flutter_secure_storage`, etc.) back as features need them.

## Planning Workflow

Non-trivial features follow: Tech Proposal (`tech-proposals/NNNN-slug.md`) →
Tech Spec (`tech-specs/NNNN-slug.md`) → Implementation → Review. Use the
stencils in `docs/stencils/`. Skip the proposal for changes touching ≤ 2 files
with no architectural impact. For any task spanning more than 2 files or
touching architecture, use Plan Mode first.

## Agents

Role-scoped agents live in `.claude/agents/`. The agent that writes code must
NOT be the agent that approves it.

- **architect** — system design, Firestore schema, and PR review only.
- **flutter-engineer** — implements features in Data and Presentation layers.
- **qa-engineer** — owns test matrix, CI/CD, and accessibility sweeps.
- **security-reviewer** — audits auth flows, Firestore rules, and secrets.

## Do Not Edit

Never edit these files — they are generated by build tools:

- `**/*.g.dart` — Riverpod/JSON codegen output (`build_runner`)
- `**/*.freezed.dart` — Freezed model codegen output
- `**/generated_plugin_registrant.*` — Flutter plugin registry
- `apps/mobile/lib/firebase_options.dart` — generated by `flutterfire configure`

To regenerate: `dart run build_runner build`

## Conventions

- Always use package imports (`package:canopy/...`) — never relative imports.
  Enforced by `always_use_package_imports`; run `dart fix --apply` to fix.
- Domain layer: zero Flutter or Firebase imports — pure Dart only
- No unbounded `ListView` — always `ListView.builder` or `SliverList`
- No plaintext secrets in Dart source — use `--dart-define` or Remote Config
- `google-services.json` and `GoogleService-Info.plist` are gitignored
- Run `flutter analyze` and `dart format .` before every commit
- Every screen must have a widget test

### Design / Theming

- Access `AppColors` via `final ac = Theme.of(context).extension<AppColors>()!`
- Access `ColorScheme` via `final cs = Theme.of(context).colorScheme`
- No hardcoded colors — always use `cs.*` or `ac.*`
- No hardcoded text styles or font sizes — always use `Theme.of(context).textTheme`
- Never import `google_fonts` directly in widget code — use `theme.textTheme.*`
  for Space Grotesk and `AppTypography.mono(base: style)` for Fira Code
- No hardcoded spacing magic numbers — use the spacing scale in `shared/theme/`

The default theme is `canopy` (defined in `lib/shared/theme/themes.dart`);
several alternate themes (Nord, Dracula, Catppuccin, etc.) ship alongside it.
Rebrand the `canopy` theme's colors to taste.

## Docs Folder Conventions

| Folder             | Written by      | Format                        | Purpose                                            |
| ------------------ | --------------- | ----------------------------- | -------------------------------------------------- |
| `tech-proposals/`  | Architect       | `NNNN-slug.md`                | Problem + solution + alternatives                  |
| `tech-specs/`      | Architect       | `NNNN-slug.md`                | Full layer design, schema, acceptance criteria     |
| `docs/sessions/`   | Any agent       | `YYYY-MM-DD-task-slug.md`     | Session scratchpad for context passing             |
| `docs/agent-runs/` | Reviewer agents | `YYYY-MM-DD-<role>-<task>.md` | Structured audit reports                           |
| `docs/decisions/`  | Architect       | `NNNN-slug.md`                | Architecture Decision Records (ADRs)               |

## Agent Logging

At the start of every session, append to `docs/agent-log-<member>.md` (member
name lowercased, spaces → hyphens) with Date / Member / Agent / Task / Prompt,
and close with an Outcome / Decisions / Handoff / Review block at the end. Log
every session, even planning- or review-only ones.
