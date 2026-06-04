import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';
import 'package:canopy/features/auth/domain/repositories/auth_repository.dart';
import 'package:canopy/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:canopy/features/you/presentation/screens/you_screen.dart';
import 'package:canopy/features/you/presentation/widgets/guest_profile_prompt.dart';
import 'package:canopy/features/you/presentation/widgets/profile_field_row.dart';
import 'package:canopy/shared/theme/app_theme.dart';
import 'package:canopy/shared/theme/themes.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.user});

  /// Emitted on the auth stream and returned by getCurrentUser.
  final AppUser? user;
  bool signOutCalled = false;

  @override
  Stream<AppUser?> get authStateChanges => Stream.value(user);

  @override
  Future<AppUser> signInAnonymously() => throw UnimplementedError();

  @override
  Future<AppUser> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AppUser> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  Future<AppUser?> getCurrentUser() async => user;

  @override
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? neighborhood,
    CheckInFrequency? checkInFrequency,
    PlantExperience? plantExperience,
    NotificationPreferences? notificationPreferences,
    bool? onboardingComplete,
  }) async {}

  @override
  Future<AppUser> linkAnonymousAccount({
    required String uid,
    required Object credential,
  }) => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Fixtures and helpers
// ---------------------------------------------------------------------------

const _fullUser = AppUser(
  id: 'uid-1',
  name: 'Test User',
  email: 'test@example.com',
  neighborhood: 'Ari',
  checkInFrequency: CheckInFrequency.onceAWeek,
  plantExperience: PlantExperience.backyardGardener,
  notificationPreferences: NotificationPreferences(
    wateringReminders: true,
    cityAlerts: false,
  ),
  onboardingComplete: true,
);

const _sparseUser = AppUser(
  id: 'uid-2',
  name: 'Sparse',
  email: 'sparse@example.com',
  onboardingComplete: true,
);

const _guestUser = AppUser(
  id: 'anon-uid',
  name: '',
  email: '',
  isAnonymous: true,
);

Widget _buildSubject(_FakeAuthRepository repo) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp(
      theme: AppTheme.build(AppThemes.canopy),
      home: const YouScreen(),
    ),
  );
}

void main() {
  group('YouScreen — authenticated', () {
    testWidgets('renders header with name, email and initials avatar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(_FakeAuthRepository(user: _fullUser)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test User'), findsWidgets);
      expect(find.text('test@example.com'), findsOneWidget);
      // Initials fallback (no photoUrl)
      expect(find.text('TU'), findsOneWidget);
    });

    testWidgets('renders profile field rows with stored values', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(_FakeAuthRepository(user: _fullUser)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Neighborhood'), findsOneWidget);
      expect(find.text('Ari'), findsOneWidget);
      expect(find.text('Check-in frequency'), findsOneWidget);
      expect(find.text(CheckInFrequency.onceAWeek.label), findsOneWidget);
      expect(find.text('Plant experience'), findsOneWidget);
      expect(find.text(PlantExperience.backyardGardener.label), findsOneWidget);
      expect(find.text('Not set'), findsNothing);
    });

    testWidgets('renders "Not set" for unset optional fields', (tester) async {
      await tester.pumpWidget(
        _buildSubject(_FakeAuthRepository(user: _sparseUser)),
      );
      await tester.pumpAndSettle();

      // Neighborhood, frequency, and experience are all unset
      expect(find.text('Not set'), findsNWidgets(3));
    });

    testWidgets('renders notification toggles reflecting preferences', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(_FakeAuthRepository(user: _fullUser)),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('City alerts'), 100);
      expect(find.text('Watering reminders'), findsOneWidget);
      expect(find.text('City alerts'), findsOneWidget);
      final switches = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      expect(switches[0].value, isTrue); // wateringReminders
      expect(switches[1].value, isFalse); // cityAlerts
    });

    testWidgets('tapping a field row opens the selection sheet', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(_FakeAuthRepository(user: _fullUser)),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Neighborhood'));
      await tester.tap(find.text('Neighborhood'));
      await tester.pumpAndSettle();

      expect(find.text('Your neighborhood'), findsOneWidget);
      expect(find.text('Chatuchak'), findsOneWidget);
    });

    testWidgets('sign out shows confirm dialog and calls signOut on confirm', (
      tester,
    ) async {
      final repo = _FakeAuthRepository(user: _fullUser);
      await tester.pumpWidget(_buildSubject(repo));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Sign out'), 100);
      await tester.ensureVisible(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.text('Sign out?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Sign out'));
      await tester.pumpAndSettle();

      expect(repo.signOutCalled, isTrue);
    });

    testWidgets('cancelling the confirm dialog does not sign out', (
      tester,
    ) async {
      final repo = _FakeAuthRepository(user: _fullUser);
      await tester.pumpWidget(_buildSubject(repo));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Sign out'), 100);
      await tester.ensureVisible(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(repo.signOutCalled, isFalse);
    });
  });

  group('YouScreen — guest', () {
    testWidgets('renders create-account prompt instead of profile editor', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(_FakeAuthRepository(user: _guestUser)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GuestProfilePrompt), findsOneWidget);
      expect(find.text('Create an account'), findsWidgets);
      expect(find.byType(ProfileFieldRow), findsNothing);
      expect(find.text('Sign out'), findsNothing);
    });
  });

  group('YouScreen — loading', () {
    testWidgets('shows a spinner before auth state resolves', (tester) async {
      await tester.pumpWidget(
        _buildSubject(_FakeAuthRepository(user: _fullUser)),
      );
      // No pumpAndSettle — first frame only
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
