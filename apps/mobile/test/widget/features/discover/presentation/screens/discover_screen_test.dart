import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:canopy/features/auth/presentation/providers/guest_mode_provider.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/repositories/sapling_repository.dart';
import 'package:canopy/features/saplings/presentation/providers/available_saplings_provider.dart';
import 'package:canopy/features/saplings/presentation/providers/discover_queue_provider.dart';
import 'package:canopy/features/saplings/presentation/providers/sapling_repository_provider.dart';
import 'package:canopy/features/discover/presentation/screens/discover_screen.dart';
import 'package:canopy/features/discover/presentation/widgets/sapling_card_stack.dart';
import 'package:canopy/shared/theme/app_theme.dart';
import 'package:canopy/shared/theme/themes.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

const _authenticatedUser = AppUser(
  id: 'uid-test',
  name: 'Test User',
  email: 'test@canopy.app',
  isAnonymous: false,
);

class _NoopSaplingRepository implements SaplingRepository {
  @override
  Stream<List<Sapling>> getAvailableSaplings() => Stream.value([]);

  @override
  Stream<List<Sapling>> getAllSaplings() => Stream.value([]);

  @override
  Future<Sapling> getSaplingById(String id) => throw UnimplementedError();

  @override
  Stream<Sapling> watchSaplingById(String id) => throw UnimplementedError();

  @override
  Future<void> adoptSapling({
    required String saplingId,
    required String uid,
    required String displayName,
    String? photoUrl,
  }) async {}

  @override
  Future<void> unadoptSapling({
    required String saplingId,
    required String uid,
  }) => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Sapling _sapling(String id) => Sapling(
  id: id,
  nickname: 'Tree $id',
  species: 'Oak',
  latin: 'Quercus',
  personality: 'Sturdy',
  street: '1 Main St',
  neighborhood: 'Downtown',
  lat: 13.7,
  lng: 100.5,
  ageLabel: '2yr',
  heightLabel: '2m',
  waterNeedLabel: 'Low',
  lightLabel: 'Full sun',
  wateringIntervalDays: 3,
  colorHex: '#3BA75E',
  status: SaplingStatus.available,
);

Widget _buildSubject({
  List<Sapling> saplings = const [],
  DiscoverQueueState? queueState,
  AppUser? user = _authenticatedUser,
  bool isGuest = false,
}) {
  final queue = queueState ?? DiscoverQueueState(queue: saplings);

  return ProviderScope(
    overrides: [
      availableSaplingsProvider.overrideWith((ref) => Stream.value(saplings)),
      allSaplingsProvider.overrideWith((ref) => Stream.value(saplings)),
      discoverQueueProvider.overrideWithValue(queue),
      authStateProvider.overrideWith((ref) => Stream.value(user)),
      guestModeProvider.overrideWithValue(isGuest),
      saplingRepositoryProvider.overrideWithValue(_NoopSaplingRepository()),
    ],
    child: MaterialApp(
      theme: AppTheme.build(AppThemes.canopy),
      home: const DiscoverScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DiscoverScreen', () {
    testWidgets('shows SaplingCardStack when saplings are in the queue', (
      tester,
    ) async {
      // SaplingCard is taller than the default 800×600 test canvas.
      // Use a taller surface so the card renders without overflow errors.
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final saplings = [_sapling('a'), _sapling('b')];

      await tester.pumpWidget(_buildSubject(saplings: saplings));
      await tester.pump();

      expect(find.byType(SaplingCardStack), findsOneWidget);
    });

    testWidgets(
      'shows "No more saplings nearby" empty state when queue is empty',
      (tester) async {
        await tester.pumpWidget(_buildSubject());
        await tester.pump();

        expect(find.text('No more saplings nearby'), findsOneWidget);
      },
    );

    testWidgets('toggle icon button is present in the AppBar', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      // In card view the AppBar shows the map_outlined icon to switch to map.
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
    });

    testWidgets('tapping the toggle icon switches to map-view icon', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      // Initial card view → icon is map_outlined.
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.map_outlined));
      await tester.pump();

      // After switching to map view → icon becomes view_carousel_outlined.
      expect(find.byIcon(Icons.view_carousel_outlined), findsOneWidget);
    });
  });
}
