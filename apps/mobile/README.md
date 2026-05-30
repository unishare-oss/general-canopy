# Canopy Mobile

Cross-platform Flutter app (iOS, Android, Web) — Firebase-native.

> **First time here?** Read [`../../SETUP.md`](../../SETUP.md) — it walks through
> creating your Firebase project, `flutterfire configure`, and codegen. The app
> will not build until those steps are done.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- [Firebase CLI](https://firebase.google.com/docs/cli): `npm install -g firebase-tools`
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli): `dart pub global activate flutterfire_cli`

## Getting Started

```bash
cd apps/mobile
flutter pub get
flutterfire configure        # links to YOUR Firebase project (see SETUP.md)
dart run build_runner build --delete-conflicting-outputs
flutter run                  # connected device or emulator
flutter run -d chrome        # web
```

Firebase config files (`firebase_options.dart`, `google-services.json`,
`GoogleService-Info.plist`) and generated `*.g.dart` / `*.freezed.dart` files
are gitignored — `flutterfire configure` and `build_runner` create them.

## Common Commands

```bash
flutter analyze                              # static analysis
dart format .                                # format code
flutter test                                 # unit + widget tests
dart run build_runner watch                  # watch mode for code gen
```
