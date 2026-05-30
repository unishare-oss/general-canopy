# Canopy — First-Time Setup

This project was bootstrapped from the Unishare Flutter boilerplate. The steps
below wire it to **your own** Firebase project and get it building. Do them in
order — the app will not compile until step 4 completes.

## 0. Prerequisites

```bash
flutter --version            # Flutter 3.41+ (Dart 3.11+)
dart pub global activate flutterfire_cli
npm install -g firebase-tools
firebase login
```

## 1. Create a Firebase project

1. Go to <https://console.firebase.google.com> and create a new project (e.g. `canopy`).
2. Add an **iOS** app with bundle ID `io.github.canopy`.
3. Add an **Android** app with package name `io.github.canopy`.
4. (Optional) Add a **Web** app.
5. In **Build → Authentication → Sign-in method**, enable the providers you want:
   - **Email/Password** and **Google** are wired up in the boilerplate.
   - **Anonymous** powers "continue as guest" — enable it if you want guest mode.

> For Google Sign-In on Android you'll also need to register your SHA-1/SHA-256
> fingerprints under the Android app settings.

## 2. Point the app at your project

```bash
cd apps/mobile
flutterfire configure
```

This generates (do not hand-edit these):
- `apps/mobile/lib/firebase_options.dart`
- `apps/mobile/android/app/google-services.json`
- `apps/mobile/ios/Runner/GoogleService-Info.plist`

Then set your project ID in **`.firebaserc`** (repo root), replacing the
`REPLACE_WITH_YOUR_FIREBASE_PROJECT_ID` placeholder, or run `firebase use --add`.

## 3. Deploy Firestore rules

The starter `firestore.rules` allows each user owner-only access to their own
`users/{uid}` doc and denies everything else. Deploy it from the repo root:

```bash
firebase deploy --only firestore:rules
```

Add new `match` blocks above the default-deny rule as you build features.

## 4. Install deps + generate code

```bash
cd apps/mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

> Generated `*.g.dart` / `*.freezed.dart` files were intentionally **not**
> copied from the boilerplate — this step recreates them.

## 5. Run it

```bash
flutter run                  # device/emulator
flutter run -d chrome        # web
```

You should land on the welcome screen → sign in / continue as guest → the
placeholder Home screen.

## 6. Make it yours

- **Launcher icon:** replace `apps/mobile/assets/launcher_icon.png`, then run
  `dart run flutter_launcher_icons`.
- **Branding:** rebrand the `canopy` theme's colors in
  `lib/shared/theme/themes.dart`, and the logo in
  `lib/features/auth/presentation/widgets/canopy_logo.dart`
  (it currently renders `assets/icon.svg` + the word "Canopy").
- **Auth fields:** the carried-over auth feature still has academic-profile
  pieces from the original app — `app_user.dart` has `universityId` /
  `departmentId` / `enrollmentYear` fields, and the sign-up flow shows an
  "academic profile" dialog reading `universities` / `departments` Firestore
  collections. Trim these (`academic_profile_dialog.dart`,
  `universities_provider.dart`, `departments_provider.dart`,
  `update_academic_profile.dart`) and simplify `welcome_screen.dart` to match
  Canopy's onboarding.

## What was removed from the boilerplate

So you know what's *not* here:

- **Features:** only `auth` + a placeholder `home` remain. The original app's
  feed, posts, profile, requests, saved, notifications, achievements, and
  departments features were stripped.
- **Backend:** Cloud Functions, the Cloudflare Worker, and Firebase Hosting
  were removed (this is a Flutter + Firestore-only setup).
- **Dependencies:** trimmed to a lean core. Re-add as needed —
  `firebase_storage`, `firebase_messaging`, `firebase_remote_config`,
  `local_auth`, `cached_network_image`, `flutter_secure_storage`,
  `file_picker`, `share_plus`, `connectivity_plus`, `intl`, `dio`, `http`,
  `pdfrx`, `video_player`, `chewie`, `path_provider`, `crypto`,
  `lucide_icons_flutter`, `liquid_glass_renderer`.

## CI / release (optional)

`.github/workflows/ci.yml` runs analyze + test + build on every PR. It reads
Firebase config from repository **secrets** — add these in your GitHub repo
(Settings → Secrets and variables → Actions):

- `FIREBASE_OPTIONS` — contents of `lib/firebase_options.dart`
- `GOOGLE_SERVICES_JSON` — contents of `android/app/google-services.json`
- `GOOGLE_SERVICE_INFO_PLIST` — contents of `ios/Runner/GoogleService-Info.plist`
- `CODECOV_TOKEN` — optional, for coverage upload

`release.yml` (signed release builds) additionally needs Android signing
secrets (`KEYSTORE_BASE64`, etc.) — review it before relying on it.
```
