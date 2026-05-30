# Canopy Phase 1a — Foundations Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebrand the app to Canopy's warm-cream/forest-green/editorial-serif identity, stand up the 5-tab bottom-nav shell, define the `Sapling` domain model + Firestore shape, and seed sample saplings — producing a running, on-brand app ready for the Discover and Grove features.

**Architecture:** Flutter + Riverpod + GoRouter, strict Clean Architecture (domain layer is pure Dart). Theme flows through the existing `AppThemeData` → `AppTheme.build` → `ThemeData` pipeline and the `AppColors` extension. Navigation uses a `StatefulShellRoute.indexedStack` with five branches. Saplings are seeded into Firestore by a Node script.

**Tech Stack:** Flutter (FVM-pinned 3.41.9), `flutter_riverpod` + `riverpod_generator`, `go_router`, `freezed` + `json_serializable`, `cloud_firestore`, `google_fonts` (Fraunces + Space Grotesk), Firebase Admin SDK (seed script, Node).

**Run all Flutter commands via `fvm`** from `apps/mobile/`. Generated `*.g.dart`/`*.freezed.dart` come from `fvm dart run build_runner build --delete-conflicting-outputs`.

---

## File Structure

- `apps/mobile/lib/shared/theme/themes.dart` — repoint the `canopy` theme entry to the green/cream palette (modify).
- `apps/mobile/lib/shared/theme/app_typography.dart` — serif display/headline + sans body (modify).
- `apps/mobile/lib/core/router/router.dart` — replace `/home` with the 5-tab shell (modify).
- `apps/mobile/lib/core/router/shell_scaffold.dart` — the bottom-nav shell widget (create).
- `apps/mobile/lib/features/{discover,grove,map,impact,you}/presentation/screens/*_screen.dart` — tab screens; Discover/Grove are placeholders this phase, replaced in 1b/1c (create).
- `apps/mobile/lib/features/saplings/domain/entities/sapling.dart` — pure-Dart entity (create).
- `apps/mobile/lib/features/saplings/data/models/sapling_model.dart` — freezed + json model + `toEntity()` (create).
- `apps/mobile/lib/features/home/presentation/screens/home_screen.dart` — delete (replaced by shell).
- `tools/seed_saplings.js` — Node seed script (create).
- Tests under `apps/mobile/test/...` mirroring each unit.

---

## Task 1: Rebrand the `canopy` theme palette

**Files:**
- Modify: `apps/mobile/lib/shared/theme/themes.dart` (the `static const canopy = AppThemeData(...)` block, starts at line 5)
- Test: `apps/mobile/test/unit/shared/theme/app_theme_test.dart`

- [ ] **Step 1: Update the theme color test to the new palette**

Open `app_theme_test.dart`. Replace the body of the test currently named `'canopy amber token is amber color'` (and any hard-coded amber hex assertions) with assertions against the new green palette:

```dart
testWidgets('canopy primary is forest green', (tester) async {
  final theme = AppTheme.fromId('canopy');
  expect(theme.colorScheme.primary, const Color(0xFF2F7D4F));
});

testWidgets('canopy background is warm cream', (tester) async {
  final theme = AppTheme.fromId('canopy');
  expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F4EE));
});

testWidgets('canopy accent token is forest green', (tester) async {
  final theme = AppTheme.fromId('canopy');
  final ac = theme.extension<AppColors>()!;
  expect(ac.amber, const Color(0xFF2F7D4F)); // "amber" token repurposed as the green accent
});
```

Leave the existing `'canopy is light'` and `'unknown id falls back to canopy'` tests unchanged (canopy stays `Brightness.light`).

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd apps/mobile && fvm flutter test test/unit/shared/theme/app_theme_test.dart`
Expected: FAIL — current `primary` is `0xFFD97706` (amber), not `0xFF2F7D4F`.

- [ ] **Step 3: Replace the `canopy` AppThemeData block with the green palette**

In `themes.dart`, replace the entire `static const canopy = AppThemeData( ... );` block (all 23 fields) with:

```dart
  static const canopy = AppThemeData(
    id: 'canopy',
    name: 'Canopy',
    brightness: Brightness.light,
    background: Color(0xFFF6F4EE),
    foreground: Color(0xFF1C2420),
    card: Color(0xFFFFFFFF),
    primary: Color(0xFF2F7D4F),
    primaryForeground: Color(0xFFFFFFFF),
    muted: Color(0xFFEFEDE6),
    mutedForeground: Color(0xFF4F5751),
    accent: Color(0xFFE8F3EC),
    accentForeground: Color(0xFF1F5A38),
    destructive: Color(0xFFC44545),
    destructiveForeground: Color(0xFFFFFFFF),
    border: Color(0xFFE2DFD7),
    textSecondary: Color(0xFF4F5751),
    textMuted: Color(0xFF8A8F88),
    amber: Color(0xFF2F7D4F),       // primary accent token (buttons/active icons), now green
    amberHover: Color(0xFF1F5A38),  // pressed/hover (primary-deep)
    amberSubtle: Color(0xFFE8F3EC), // tinted backgrounds (primary-surface)
    success: Color(0xFF2F9E44),
    info: Color(0xFF2A6EBB),
    surfaceDark: Color(0xFF1A1F1B),
    cardDark: Color(0xFF1E2C24),
  );
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `cd apps/mobile && fvm flutter test test/unit/shared/theme/app_theme_test.dart test/unit/shared/theme/theme_provider_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add apps/mobile/lib/shared/theme/themes.dart apps/mobile/test/unit/shared/theme/app_theme_test.dart
git commit -m "Rebrand canopy theme to forest-green and cream palette"
```

---

## Task 2: Editorial serif typography

**Files:**
- Modify: `apps/mobile/lib/shared/theme/app_typography.dart`
- Test: `apps/mobile/test/unit/shared/theme/app_typography_test.dart` (create)

Headlines/display use **Fraunces** (editorial serif); body/label/title keep **Space Grotesk**.

- [ ] **Step 1: Write the failing test**

Create `apps/mobile/test/unit/shared/theme/app_typography_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:canopy/shared/theme/app_typography.dart';

void main() {
  group('AppTypography', () {
    test('display + headline use a serif (Fraunces); body uses Space Grotesk', () {
      final tt = AppTypography.textTheme(const Color(0xFF000000));
      expect(tt.displayLarge!.fontFamily, contains('Fraunces'));
      expect(tt.headlineMedium!.fontFamily, contains('Fraunces'));
      expect(tt.bodyMedium!.fontFamily, contains('SpaceGrotesk'));
    });

    test('applies the given color to body and display', () {
      final tt = AppTypography.textTheme(const Color(0xFF112233));
      expect(tt.bodyMedium!.color, const Color(0xFF112233));
      expect(tt.displayLarge!.color, const Color(0xFF112233));
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `cd apps/mobile && fvm flutter test test/unit/shared/theme/app_typography_test.dart`
Expected: FAIL — `displayLarge.fontFamily` is currently `SpaceGrotesk`, not `Fraunces`.

- [ ] **Step 3: Implement serif headings over a sans base**

Replace `app_typography.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  /// Editorial pairing: Fraunces (serif) for display/headline, Space Grotesk
  /// (sans) for everything else. Both colored to [color].
  static TextTheme textTheme(Color color) {
    final base = GoogleFonts.spaceGroteskTextTheme()
        .apply(bodyColor: color, displayColor: color);
    return base.copyWith(
      displayLarge: GoogleFonts.fraunces(textStyle: base.displayLarge),
      displayMedium: GoogleFonts.fraunces(textStyle: base.displayMedium),
      displaySmall: GoogleFonts.fraunces(textStyle: base.displaySmall),
      headlineLarge: GoogleFonts.fraunces(textStyle: base.headlineLarge),
      headlineMedium: GoogleFonts.fraunces(textStyle: base.headlineMedium),
      headlineSmall: GoogleFonts.fraunces(textStyle: base.headlineSmall),
    );
  }

  static TextStyle mono({TextStyle? base}) =>
      GoogleFonts.firaCode(textStyle: base);
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `cd apps/mobile && fvm flutter test test/unit/shared/theme/app_typography_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add apps/mobile/lib/shared/theme/app_typography.dart apps/mobile/test/unit/shared/theme/app_typography_test.dart
git commit -m "Add editorial serif (Fraunces) headings to typography"
```

---

## Task 3: Sapling domain entity + data model

**Files:**
- Create: `apps/mobile/lib/features/saplings/domain/entities/sapling.dart`
- Create: `apps/mobile/lib/features/saplings/data/models/sapling_model.dart`
- Test: `apps/mobile/test/unit/features/saplings/sapling_model_test.dart`

- [ ] **Step 1: Write the pure-Dart entity**

Create `apps/mobile/lib/features/saplings/domain/entities/sapling.dart`:

```dart
/// A real, geo-tagged sapling available for or under adoption.
/// Pure Dart — no Flutter or Firebase imports.
class Sapling {
  const Sapling({
    required this.id,
    required this.nickname,
    required this.species,
    required this.latin,
    required this.personality,
    required this.street,
    required this.neighborhood,
    required this.lat,
    required this.lng,
    required this.ageLabel,
    required this.heightLabel,
    required this.waterNeedLabel,
    required this.lightLabel,
    required this.wateringIntervalDays,
    required this.colorHex,
    required this.status,
    this.photoUrl,
    this.adoptedBy,
  });

  final String id;
  final String nickname;
  final String species;
  final String latin;
  final String personality;
  final String street;
  final String neighborhood;
  final double lat;
  final double lng;
  final String ageLabel;
  final String heightLabel;
  final String waterNeedLabel;
  final String lightLabel;
  final int wateringIntervalDays;
  final String colorHex;
  final SaplingStatus status;
  final String? photoUrl;
  final String? adoptedBy;

  bool get isAvailable => status == SaplingStatus.available;
}

enum SaplingStatus { available, adopted }
```

- [ ] **Step 2: Write the failing model test**

Create `apps/mobile/test/unit/features/saplings/sapling_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:canopy/features/saplings/data/models/sapling_model.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';

void main() {
  final json = {
    'nickname': 'Olive',
    'species': 'Eastern Redbud',
    'latin': 'Cercis canadensis',
    'personality': 'A shy understudy with heart-shaped leaves.',
    'photoUrl': null,
    'color': '#D87FA8',
    'street': '142 Linden Ave',
    'neighborhood': 'Maple Heights',
    'lat': 0.42,
    'lng': 0.31,
    'ageLabel': 'Sapling · 6mo',
    'heightLabel': '1.2m',
    'waterNeedLabel': 'Every 3 days in summer',
    'lightLabel': 'Partial sun',
    'wateringIntervalDays': 3,
    'status': 'available',
    'adoptedBy': null,
  };

  test('fromJson parses all fields', () {
    final m = SaplingModel.fromJson(json);
    expect(m.nickname, 'Olive');
    expect(m.wateringIntervalDays, 3);
    expect(m.status, 'available');
  });

  test('toEntity maps to domain Sapling with parsed status', () {
    final s = SaplingModel.fromJson(json).toEntity('t1');
    expect(s, isA<Sapling>());
    expect(s.id, 't1');
    expect(s.status, SaplingStatus.available);
    expect(s.colorHex, '#D87FA8');
    expect(s.isAvailable, isTrue);
  });
}
```

- [ ] **Step 3: Run the test to verify it fails**

Run: `cd apps/mobile && fvm flutter test test/unit/features/saplings/sapling_model_test.dart`
Expected: FAIL — `SaplingModel` does not exist / no generated code.

- [ ] **Step 4: Write the freezed model**

Create `apps/mobile/lib/features/saplings/data/models/sapling_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';

part 'sapling_model.freezed.dart';
part 'sapling_model.g.dart';

@freezed
abstract class SaplingModel with _$SaplingModel {
  const SaplingModel._();

  const factory SaplingModel({
    required String nickname,
    required String species,
    required String latin,
    required String personality,
    String? photoUrl,
    @JsonKey(name: 'color') required String colorHex,
    required String street,
    required String neighborhood,
    required double lat,
    required double lng,
    required String ageLabel,
    required String heightLabel,
    required String waterNeedLabel,
    required String lightLabel,
    @Default(3) int wateringIntervalDays,
    @Default('available') String status,
    String? adoptedBy,
  }) = _SaplingModel;

  factory SaplingModel.fromJson(Map<String, dynamic> json) =>
      _$SaplingModelFromJson(json);

  Sapling toEntity(String id) => Sapling(
        id: id,
        nickname: nickname,
        species: species,
        latin: latin,
        personality: personality,
        street: street,
        neighborhood: neighborhood,
        lat: lat,
        lng: lng,
        ageLabel: ageLabel,
        heightLabel: heightLabel,
        waterNeedLabel: waterNeedLabel,
        lightLabel: lightLabel,
        wateringIntervalDays: wateringIntervalDays,
        colorHex: colorHex,
        status: status == 'adopted'
            ? SaplingStatus.adopted
            : SaplingStatus.available,
        photoUrl: photoUrl,
        adoptedBy: adoptedBy,
      );
}
```

- [ ] **Step 5: Generate code**

Run: `cd apps/mobile && fvm dart run build_runner build --delete-conflicting-outputs`
Expected: creates `sapling_model.freezed.dart` and `sapling_model.g.dart`, no errors.

- [ ] **Step 6: Run the test to verify it passes**

Run: `cd apps/mobile && fvm flutter test test/unit/features/saplings/sapling_model_test.dart`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add apps/mobile/lib/features/saplings apps/mobile/test/unit/features/saplings
git commit -m "Add Sapling entity and Firestore model"
```

---

## Task 4: Five-tab navigation shell + stub screens

**Files:**
- Create: `apps/mobile/lib/core/router/shell_scaffold.dart`
- Create: `apps/mobile/lib/features/discover/presentation/screens/discover_screen.dart`
- Create: `apps/mobile/lib/features/grove/presentation/screens/grove_screen.dart`
- Create: `apps/mobile/lib/features/map/presentation/screens/map_screen.dart`
- Create: `apps/mobile/lib/features/impact/presentation/screens/impact_screen.dart`
- Create: `apps/mobile/lib/features/you/presentation/screens/you_screen.dart`
- Modify: `apps/mobile/lib/core/router/router.dart`
- Delete: `apps/mobile/lib/features/home/presentation/screens/home_screen.dart`
- Test: `apps/mobile/test/widget/core/router/shell_scaffold_test.dart`

Tab order matches the prototype: **Discover · Map · Grove · Impact · You**; default landing `/grove`.

- [ ] **Step 1: Create the shell scaffold with bottom nav (defines the shared `TabPlaceholder`)**

Create `apps/mobile/lib/core/router/shell_scaffold.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom-nav shell wrapping the five top-level branches.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Discover'),
          NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Map'),
          NavigationDestination(
              icon: Icon(Icons.park_outlined),
              selectedIcon: Icon(Icons.park),
              label: 'Grove'),
          NavigationDestination(
              icon: Icon(Icons.eco_outlined),
              selectedIcon: Icon(Icons.eco),
              label: 'Impact'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'You'),
        ],
      ),
    );
  }
}

/// Shared placeholder body for tabs not yet implemented.
class TabPlaceholder extends StatelessWidget {
  const TabPlaceholder({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.displaySmall),
              Text(subtitle, style: theme.textTheme.bodyMedium),
              const Expanded(child: Center(child: Text('Coming soon'))),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create the five stub screens**

Each screen imports the shared `TabPlaceholder`. Create `apps/mobile/lib/features/discover/presentation/screens/discover_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:canopy/core/router/shell_scaffold.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});
  @override
  Widget build(BuildContext context) => const TabPlaceholder(
        title: 'Discover',
        subtitle: 'Saplings waiting on your block',
      );
}
```

Create the other four identically — same imports, swapping the class name, file path, title, and subtitle:

- `features/grove/presentation/screens/grove_screen.dart` → `GroveScreen`, `'Grove'`, `'Your trees today'`
- `features/map/presentation/screens/map_screen.dart` → `MapScreen`, `'Map'`, `'Saplings near you'`
- `features/impact/presentation/screens/impact_screen.dart` → `ImpactScreen`, `'Impact'`, `'What your grove is doing'`
- `features/you/presentation/screens/you_screen.dart` → `YouScreen`, `'You'`, `'Profile & settings'`

- [ ] **Step 3: Rewrite the router to use the shell**

Replace the `routes:` list in `apps/mobile/lib/core/router/router.dart` so `/home` + `HomeScreen` are gone and the shell drives 5 branches. Update imports at the top (remove `home_screen.dart`, add the five screens + shell). Change `initialLocation` to `/grove`, and in the redirect change the two `'/home'` return values to `'/grove'`.

New routes block:

```dart
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/discover', builder: (c, s) => const DiscoverScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/map', builder: (c, s) => const MapScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/grove', builder: (c, s) => const GroveScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/impact', builder: (c, s) => const ImpactScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/you', builder: (c, s) => const YouScreen()),
          ]),
        ],
      ),
    ],
```

Top-of-file imports to add:

```dart
import 'package:canopy/core/router/shell_scaffold.dart';
import 'package:canopy/features/discover/presentation/screens/discover_screen.dart';
import 'package:canopy/features/grove/presentation/screens/grove_screen.dart';
import 'package:canopy/features/map/presentation/screens/map_screen.dart';
import 'package:canopy/features/impact/presentation/screens/impact_screen.dart';
import 'package:canopy/features/you/presentation/screens/you_screen.dart';
```

Remove: `import 'package:canopy/features/home/presentation/screens/home_screen.dart';`. In `redirect`, replace both `return '/home';` with `return '/grove';` and `if (currentPath == '/') return '/home';` with `'/grove'`. Change `initialLocation: '/welcome'` stays; the shell handles post-auth.

- [ ] **Step 4: Delete the old home screen**

```bash
rm apps/mobile/lib/features/home/presentation/screens/home_screen.dart
```

(If the directory is now empty, that's fine.)

- [ ] **Step 5: Regenerate router code**

Run: `cd apps/mobile && fvm dart run build_runner build --delete-conflicting-outputs`
Expected: `router.g.dart` regenerates with the new routes, no errors.

- [ ] **Step 6: Write the shell widget test**

Create `apps/mobile/test/widget/core/router/shell_scaffold_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:canopy/core/router/shell_scaffold.dart';

void main() {
  testWidgets('TabPlaceholder renders its title and subtitle', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: TabPlaceholder(title: 'Discover', subtitle: 'Saplings waiting on your block'),
    ));
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Saplings waiting on your block'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
  });
}
```

- [ ] **Step 7: Run the test + analyzer**

Run: `cd apps/mobile && fvm flutter test test/widget/core/router/shell_scaffold_test.dart && fvm flutter analyze`
Expected: test PASS; analyze reports no errors (warnings about the placeholder screens are acceptable, but there should be no errors).

- [ ] **Step 8: Commit**

```bash
git add apps/mobile/lib/core/router apps/mobile/lib/features apps/mobile/test/widget/core/router
git commit -m "Add 5-tab navigation shell and tab placeholders"
```

---

## Task 5: Seed sample saplings into Firestore

**Files:**
- Create: `tools/seed_saplings.js`
- Create: `tools/package.json`
- Modify: `SETUP.md` (add a "Seed saplings" section)

The script reads a service-account key and writes ~8 `saplings` docs (derived from the prototype's `Canopy/app/canopy-data.js`), all `status: 'available'`.

- [ ] **Step 1: Create the seed package manifest**

Create `tools/package.json`:

```json
{
  "name": "canopy-tools",
  "private": true,
  "type": "commonjs",
  "dependencies": {
    "firebase-admin": "^13.0.0"
  }
}
```

- [ ] **Step 2: Create the seed script**

Create `tools/seed_saplings.js`:

```js
// Seeds the `saplings` collection. Usage:
//   cd tools && npm install
//   node seed_saplings.js service-account.json
const admin = require('firebase-admin');

const keyPath = process.argv[2];
if (!keyPath) {
  console.error('Usage: node seed_saplings.js <service-account.json>');
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(require('./' + keyPath)) });
const db = admin.firestore();

const SAPLINGS = [
  { nickname: 'Olive', species: 'Eastern Redbud', latin: 'Cercis canadensis',
    personality: 'A shy understudy with heart-shaped leaves. Loves morning sun, hates being forgotten.',
    color: '#D87FA8', street: '142 Linden Ave', neighborhood: 'Maple Heights', lat: 0.42, lng: 0.31,
    ageLabel: 'Sapling · 6mo', heightLabel: '1.2m', waterNeedLabel: 'Every 3 days in summer',
    lightLabel: 'Partial sun', wateringIntervalDays: 3, status: 'available', adoptedBy: null, photoUrl: null },
  { nickname: 'Bramble', species: 'Sugar Maple', latin: 'Acer saccharum',
    personality: 'A future towering shade-giver. Currently extremely dramatic about every breeze.',
    color: '#E8843A', street: '88 Cedar St', neighborhood: 'Maple Heights', lat: 0.62, lng: 0.48,
    ageLabel: 'Sapling · 1yr', heightLabel: '1.8m', waterNeedLabel: 'Twice weekly',
    lightLabel: 'Full sun', wateringIntervalDays: 3, status: 'available', adoptedBy: null, photoUrl: null },
  { nickname: 'Sprout', species: 'Flowering Dogwood', latin: 'Cornus florida',
    personality: 'Quietly preparing the most extra spring bloom of your life.',
    color: '#F4F0D8', street: '210 Birchwood Ln', neighborhood: 'East Park', lat: 0.28, lng: 0.71,
    ageLabel: 'Sapling · 8mo', heightLabel: '1.4m', waterNeedLabel: 'Every 4 days',
    lightLabel: 'Dappled shade', wateringIntervalDays: 4, status: 'available', adoptedBy: null, photoUrl: null },
  { nickname: 'Pip', species: 'Red Oak', latin: 'Quercus rubra',
    personality: 'The strong silent type. Plans to outlive everyone you know.',
    color: '#A65A3A', street: '15 Oakridge Way', neighborhood: 'Westgate', lat: 0.78, lng: 0.22,
    ageLabel: 'Sapling · 2yr', heightLabel: '2.4m', waterNeedLabel: 'Weekly',
    lightLabel: 'Full sun', wateringIntervalDays: 7, status: 'available', adoptedBy: null, photoUrl: null },
  { nickname: 'Juniper', species: 'River Birch', latin: 'Betula nigra',
    personality: 'Peeling bark like she means it. Thrives where others get cold feet.',
    color: '#D9C9A8', street: '67 Willow Bend', neighborhood: 'Riverside', lat: 0.18, lng: 0.18,
    ageLabel: 'Sapling · 1yr', heightLabel: '2.0m', waterNeedLabel: 'Twice weekly',
    lightLabel: 'Full sun', wateringIntervalDays: 3, status: 'available', adoptedBy: null, photoUrl: null },
  { nickname: 'Hazel', species: 'Pin Oak', latin: 'Quercus palustris',
    personality: 'Symmetrical to a fault. Will judge your fence.',
    color: '#B5743A', street: '9 Park Row', neighborhood: 'East Park', lat: 0.34, lng: 0.66,
    ageLabel: 'Sapling · 10mo', heightLabel: '1.7m', waterNeedLabel: 'Every 3 days',
    lightLabel: 'Full sun', wateringIntervalDays: 3, status: 'available', adoptedBy: null, photoUrl: null },
  { nickname: 'Smokey', species: 'Black Walnut', latin: 'Juglans nigra',
    personality: 'Generous with shade, stingy with neighbors. Complicated.',
    color: '#6E5638', street: '301 Walnut Ct', neighborhood: 'Westgate', lat: 0.7, lng: 0.3,
    ageLabel: 'Sapling · 18mo', heightLabel: '2.2m', waterNeedLabel: 'Weekly',
    lightLabel: 'Full sun', wateringIntervalDays: 7, status: 'available', adoptedBy: null, photoUrl: null },
  { nickname: 'Quincy', species: 'Tulip Poplar', latin: 'Liriodendron tulipifera',
    personality: 'Reaches for the sky and expects you to keep up.',
    color: '#9CC066', street: '54 Elm St', neighborhood: 'Maple Heights', lat: 0.52, lng: 0.52,
    ageLabel: 'Sapling · 7mo', heightLabel: '1.5m', waterNeedLabel: 'Every 3 days',
    lightLabel: 'Full sun', wateringIntervalDays: 3, status: 'available', adoptedBy: null, photoUrl: null },
];

async function run() {
  const batch = db.batch();
  for (const s of SAPLINGS) {
    batch.set(db.collection('saplings').doc(), s);
  }
  await batch.commit();
  console.log(`Seeded ${SAPLINGS.length} saplings.`);
}

run().then(() => process.exit(0)).catch((e) => { console.error(e); process.exit(1); });
```

- [ ] **Step 3: Document the seed step in SETUP.md**

Add this section to `SETUP.md` after the Firestore-rules section:

```markdown
## Seed sample saplings (one-time per environment)

1. Firebase Console → Project Settings → Service accounts → Generate new private key.
   Save as `tools/service-account.json` (gitignored).
2. Install + run:
   ```bash
   cd tools && npm install
   node seed_saplings.js service-account.json
   ```
   Seeds ~8 available saplings into the `saplings` collection.
```

- [ ] **Step 4: Verify the script parses (no Firebase call)**

Run: `node --check tools/seed_saplings.js`
Expected: no output (syntax OK). Actual seeding requires a service-account key + the new Firebase project; that's a manual environment step, not part of CI.

- [ ] **Step 5: Commit**

```bash
git add tools/seed_saplings.js tools/package.json SETUP.md
git commit -m "Add saplings seed script and setup docs"
```

---

## Task 6: Full suite green + analyzer clean

**Files:** none (verification task)

- [ ] **Step 1: Run the analyzer**

Run: `cd apps/mobile && fvm flutter analyze`
Expected: No errors. (Requires `firebase_options.dart` to exist — created by `flutterfire configure` during setup.)

- [ ] **Step 2: Run the full test suite**

Run: `cd apps/mobile && fvm flutter test`
Expected: All tests PASS (theme, typography, sapling model, shell, plus the pre-existing auth tests).

- [ ] **Step 3: Manual smoke (optional but recommended)**

Run: `cd apps/mobile && fvm flutter run -d chrome`
Expected: welcome screen → sign in / guest → lands on **Grove** tab; bottom nav switches between the five tabs; everything renders in the cream/green theme with serif headings.

- [ ] **Step 4: Commit any fixups**

```bash
git add -A
git commit -m "Phase 1a foundations: analyzer + tests green"
```

---

## Notes for later phases (do NOT build now)

- **Plan 1b (Discover & Adoption):** adds `cloud_functions` dep, the `adoptSapling`/`releaseSapling` Cloud Functions (re-introduces `functions/`), saplings repository + providers, swipe deck, tree detail, adopt/release — replaces the Discover placeholder.
- **Plan 1c (My Grove & Watering):** grove models, repository, dashboard matching `01-grove.png`, health ring (uses pin colors `#3BA75E` healthy / `#E2A130` attention / `#C44545` risk), watering log — replaces the Grove placeholder.
