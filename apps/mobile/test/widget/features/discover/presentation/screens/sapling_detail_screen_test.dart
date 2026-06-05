import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:canopy/features/auth/presentation/providers/guest_mode_provider.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/repositories/sapling_repository.dart';
import 'package:canopy/features/saplings/presentation/providers/discover_queue_provider.dart';
import 'package:canopy/features/saplings/presentation/providers/sapling_repository_provider.dart';
import 'package:canopy/features/discover/presentation/screens/sapling_detail_screen.dart';
import 'package:canopy/shared/theme/app_theme.dart';
import 'package:canopy/shared/theme/themes.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

const _testSaplingId = 'tree-detail-1';

const _testSapling = Sapling(
  id: _testSaplingId,
  nickname: 'Sunny',
  species: 'Golden Rain Tree',
  latin: 'Koelreuteria paniculata',
  personality: 'A cheerful tree that loves open skies.',
  street: '88 Sukhumvit Rd',
  neighborhood: 'Watthana',
  lat: 13.73,
  lng: 100.57,
  ageLabel: '3yr',
  heightLabel: '3m',
  waterNeedLabel: 'Every 5 days',
  lightLabel: 'Full sun',
  wateringIntervalDays: 5,
  colorHex: '#E2A130',
  status: SaplingStatus.available,
);

class _FakeSaplingRepository implements SaplingRepository {
  final Sapling? _stub;
  final bool throwNotFound;

  _FakeSaplingRepository({Sapling? stub, this.throwNotFound = false})
    : _stub = stub;

  @override
  Stream<List<Sapling>> getAvailableSaplings() => Stream.value([]);

  @override
  Stream<List<Sapling>> getAllSaplings() => Stream.value([]);

  @override
  Future<Sapling> getSaplingById(String id) async {
    if (throwNotFound) throw Exception('Not found: $id');
    return _stub ?? _testSapling;
  }

  @override
  Stream<Sapling> watchSaplingById(String id) {
    if (throwNotFound) return Stream.error(Exception('Not found: $id'));
    return Stream.value(_stub ?? _testSapling);
  }

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

/// Builds the subject inside a GoRouter so that context.push / context.pop
/// calls inside the screen don't throw. The test navigates straight to the
/// detail screen via the initial location.
Widget _buildSubject({
  SaplingRepository? repo,
  AppUser? user = const AppUser(
    id: 'uid-auth',
    name: 'Alice',
    email: 'alice@canopy.app',
    isAnonymous: false,
  ),
  bool isGuest = false,
}) {
  final fakeRepo = repo ?? _FakeSaplingRepository();

  final router = GoRouter(
    initialLocation: '/sapling/$_testSaplingId',
    routes: [
      GoRoute(
        path: '/sapling/:id',
        builder: (context, state) =>
            SaplingDetailScreen(saplingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Welcome screen'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      saplingRepositoryProvider.overrideWithValue(fakeRepo),
      discoverQueueProvider.overrideWithValue(const DiscoverQueueState()),
      authStateProvider.overrideWith((ref) => Stream.value(user)),
      guestModeProvider.overrideWithValue(isGuest),
    ],
    child: MaterialApp.router(
      theme: AppTheme.build(AppThemes.canopy),
      routerConfig: router,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SaplingDetailScreen', () {
    testWidgets('displays nickname, species, street, and neighborhood', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      // Let the FutureProvider resolve.
      await tester.pumpAndSettle();

      expect(find.text('Sunny'), findsOneWidget);
      expect(find.textContaining('Golden Rain Tree'), findsOneWidget);
      expect(find.textContaining('88 Sukhumvit Rd'), findsOneWidget);
      expect(find.textContaining('Watthana'), findsOneWidget);
    });

    testWidgets(
      'Adopt button is present and enabled for authenticated non-anonymous user',
      (tester) async {
        await tester.pumpWidget(_buildSubject());
        await tester.pumpAndSettle();

        // The adopt button shows "Adopt this tree".
        final adoptFinder = find.widgetWithText(
          FilledButton,
          'Adopt this tree',
        );
        expect(adoptFinder, findsOneWidget);

        final button = tester.widget<FilledButton>(adoptFinder);
        expect(button.onPressed, isNotNull);
      },
    );

    testWidgets(
      'Adopt button is present for anonymous user and navigates to /welcome on tap',
      (tester) async {
        await tester.pumpWidget(
          _buildSubject(
            user: const AppUser(
              id: 'anon-uid',
              name: '',
              email: '',
              isAnonymous: true,
            ),
            isGuest: true,
          ),
        );
        await tester.pumpAndSettle();

        // The button is still rendered (available sapling) but redirects when tapped.
        final adoptFinder = find.widgetWithText(
          FilledButton,
          'Adopt this tree',
        );
        expect(adoptFinder, findsOneWidget);

        // The detail screen is taller than the test viewport — scroll the
        // button into view before tapping.
        await tester.ensureVisible(adoptFinder);
        await tester.pump();
        await tester.tap(adoptFinder);
        await tester.pumpAndSettle();

        // Should have navigated to the welcome screen.
        expect(find.text('Welcome screen'), findsOneWidget);
      },
    );

    testWidgets('shows error text when sapling fails to load', (tester) async {
      await tester.pumpWidget(
        _buildSubject(repo: _FakeSaplingRepository(throwNotFound: true)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load sapling.'), findsOneWidget);
    });
  });
}
