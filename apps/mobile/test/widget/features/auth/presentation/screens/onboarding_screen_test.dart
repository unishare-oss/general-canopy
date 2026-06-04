import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';
import 'package:canopy/features/auth/domain/repositories/auth_repository.dart';
import 'package:canopy/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:canopy/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:canopy/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:canopy/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:canopy/shared/constants/neighborhoods.dart';
import 'package:canopy/shared/theme/app_theme.dart';
import 'package:canopy/shared/theme/themes.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeAuthRepository implements AuthRepository {
  bool shouldThrowOnUpdate = false;

  @override
  Stream<AppUser?> get authStateChanges => Stream.value(
    const AppUser(id: 'uid-onb', name: 'Test User', email: 'test@example.com'),
  );

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
  Future<void> signOut() async {}

  @override
  Future<AppUser?> getCurrentUser() async => null;

  @override
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? neighborhood,
    CheckInFrequency? checkInFrequency,
    PlantExperience? plantExperience,
    NotificationPreferences? notificationPreferences,
    bool? onboardingComplete,
  }) async {
    if (shouldThrowOnUpdate) throw Exception('Firestore write failed');
  }

  @override
  Future<AppUser> linkAnonymousAccount({
    required String uid,
    required Object credential,
  }) => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildSubject({_FakeAuthRepository? repo}) {
  final fakeRepo = repo ?? _FakeAuthRepository();
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(fakeRepo),
      authStateProvider.overrideWith(
        (ref) => Stream.value(
          const AppUser(
            id: 'uid-onb',
            name: 'Test User',
            email: 'test@example.com',
          ),
        ),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.build(AppThemes.canopy),
      home: const OnboardingScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('OnboardingScreen', () {
    testWidgets('step 0 renders welcome copy and Get started button', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      expect(find.text('Welcome to Canopy.'), findsOneWidget);
      expect(
        find.text(
          'Adopt a tree on your block,\nkeep it alive, cool your city.',
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Get started'), findsOneWidget);
    });

    testWidgets('tapping Get started advances to step 1', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Get started'));
      await tester.pump();

      // Step 1 — neighbourhood heading
      expect(find.text('Where is your tree?'), findsOneWidget);
    });

    testWidgets('step 1 renders all neighbourhood chips', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      // Advance to step 1
      await tester.tap(find.widgetWithText(FilledButton, 'Get started'));
      await tester.pump();

      for (final name in kNeighborhoods) {
        expect(find.text(name), findsOneWidget);
      }
    });

    testWidgets('selecting a chip and tapping Next advances to step 2', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Get started'));
      await tester.pump();

      // Select a neighbourhood
      await tester.tap(find.text(kNeighborhoods.first));
      await tester.pump();

      // Tap Next
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pump();

      // Step 2 — frequency heading
      expect(find.text('How often can you visit?'), findsOneWidget);
    });

    testWidgets('Skip on step 1 advances to step 2 without selecting', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Get started'));
      await tester.pump();

      // Tap Skip
      await tester.tap(find.text('Skip'));
      await tester.pump();

      expect(find.text('How often can you visit?'), findsOneWidget);
    });

    testWidgets('step 3 renders "Find me a tree" CTA', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      // Navigate to step 3
      await tester.tap(find.widgetWithText(FilledButton, 'Get started'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pump();

      expect(
        find.widgetWithText(FilledButton, 'Find me a tree'),
        findsOneWidget,
      );
    });

    testWidgets('"Find me a tree" button is disabled when isSubmitting is true', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      // Navigate to step 3
      await tester.tap(find.widgetWithText(FilledButton, 'Get started'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pump();

      // Inject submitting state directly
      final container = ProviderScope.containerOf(
        tester.element(find.byType(OnboardingScreen)),
      );
      container.read(onboardingProvider.notifier).state = const OnboardingState(
        currentStep: 3,
        isSubmitting: true,
      );
      await tester.pump();

      // When isSubmitting is true, the button shows a CircularProgressIndicator
      // instead of text. We verify the button is disabled by checking it
      // contains the loading indicator and its onPressed is null.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final buttons = tester.widgetList<FilledButton>(
        find.byType(FilledButton),
      );
      // The submit button (last FilledButton in the tree) should have
      // onPressed null when submitting.
      final submitButton = buttons.last;
      expect(submitButton.onPressed, isNull);
    });

    testWidgets('submitError non-null renders error text', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      // Navigate to step 3
      await tester.tap(find.widgetWithText(FilledButton, 'Get started'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pump();

      // Inject error state
      final container = ProviderScope.containerOf(
        tester.element(find.byType(OnboardingScreen)),
      );
      container.read(onboardingProvider.notifier).state = const OnboardingState(
        currentStep: 3,
        submitError: 'Something went wrong. Please try again.',
      );
      await tester.pump();

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('back button on step 1 returns to step 0', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Get started'));
      await tester.pump();

      // The back button is an IconButton with arrow_back icon
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pump();

      expect(find.text('Welcome to Canopy.'), findsOneWidget);
    });
  });
}
