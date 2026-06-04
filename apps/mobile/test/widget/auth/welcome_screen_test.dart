import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';
import 'package:canopy/features/auth/domain/repositories/auth_repository.dart';
import 'package:canopy/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:canopy/features/auth/presentation/screens/welcome_screen.dart';
import 'package:canopy/shared/theme/app_theme.dart';
import 'package:canopy/shared/theme/themes.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeAuthRepository implements AuthRepository {
  bool signInAnonymouslyCalled = false;

  @override
  Stream<AppUser?> get authStateChanges => const Stream.empty();

  @override
  Future<AppUser> signInAnonymously() async {
    signInAnonymouslyCalled = true;
    return const AppUser(
      id: 'anon-uid',
      name: '',
      email: '',
      isAnonymous: true,
    );
  }

  @override
  Future<AppUser> signInWithGoogle() async => throw UnimplementedError();

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<AppUser> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async => throw UnimplementedError();

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
  }) => throw UnimplementedError();

  @override
  Future<AppUser> linkAnonymousAccount({
    required String uid,
    required Object credential,
  }) => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildSubject() {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
    ],
    child: MaterialApp(
      theme: AppTheme.build(AppThemes.canopy),
      home: const AuthScreen(),
    ),
  );
}

/// Finds the "Create account" tab used to switch to sign-up mode.
Finder get _signUpLink => find.text('Create account');

/// Finds the "Sign in" tab used to switch back to sign-in mode.
Finder get _signInLink => find.text('Sign in');

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AuthScreen — sign-in mode', () {
    testWidgets(
      'renders Google button, email/password fields, mode-switch link and guest link',
      (tester) async {
        await tester.pumpWidget(_buildSubject());
        await tester.pump();

        expect(find.text('Continue with Google'), findsOneWidget);
        // Microsoft button must NOT be present
        expect(find.text('Continue with Microsoft'), findsNothing);
        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(_signUpLink, findsOneWidget);
        expect(find.text('Browse as guest'), findsOneWidget);
      },
    );

    testWidgets('university dropdown is absent from sign-in mode', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      // No DropdownButtonFormField in sign-in mode
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    });

    testWidgets('email hint text does not mention university', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      // The old hint was 'you@university.edu' — it must be gone
      expect(find.text('you@university.edu'), findsNothing);
      // New hint text
      expect(find.text('you@example.com'), findsOneWidget);
    });

    testWidgets('subheading is Canopy-specific copy', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      expect(
        find.text('Adopt a tree. Keep it alive.\nCool your city.'),
        findsOneWidget,
      );
      // Old Unishare copy must be gone
      expect(
        find.text('Use your university account to continue'),
        findsNothing,
      );
    });

    testWidgets('tapping "Continue as guest" calls signInAnonymously', (
      tester,
    ) async {
      final fakeRepo = _FakeAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
          child: MaterialApp(
            theme: AppTheme.build(AppThemes.canopy),
            home: const AuthScreen(),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.text('Browse as guest'));
      await tester.tap(find.text('Browse as guest'));
      await tester.pump();

      expect(fakeRepo.signInAnonymouslyCalled, isTrue);
    });
  });

  group('AuthScreen — sign-up mode', () {
    /// Switches to sign-up mode by tapping the "Sign up" link.
    Future<void> switchToSignUp(WidgetTester tester) async {
      await tester.tap(_signUpLink);
      await tester.pumpAndSettle();
    }

    testWidgets(
      'switching to sign-up shows name, email, password, confirm, consent — no university dropdown',
      (tester) async {
        await tester.pumpWidget(_buildSubject());
        await tester.pump();

        await switchToSignUp(tester);

        // Heading changed
        expect(find.text('Create account'), findsWidgets);

        // Exactly 4 TextFormFields: name, email, password, confirm password
        expect(find.byType(TextFormField), findsNWidgets(4));

        // No university dropdown
        expect(find.byType(DropdownButtonFormField<String>), findsNothing);

        // Consent checkbox
        expect(find.byType(Checkbox), findsOneWidget);

        // Mode-switch now shows sign-in link
        expect(_signInLink, findsOneWidget);
      },
    );

    testWidgets('submit with mismatched passwords shows inline error', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      await switchToSignUp(tester);

      final fields = find.byType(TextFormField);
      // fields: 0=name, 1=email, 2=password, 3=confirm password
      await tester.enterText(fields.at(0), 'Test User');
      await tester.enterText(fields.at(1), 'test@example.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'different456');

      // Scroll to and check the consent checkbox so the button is enabled
      final checkbox = find.byType(Checkbox);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox, warnIfMissed: false);
      await tester.pump();

      final submitButton = find.widgetWithText(FilledButton, 'Create account');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('submit without consent disables button', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      await switchToSignUp(tester);

      // The submit button should be disabled (consent not checked)
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Create account'),
      );
      expect(button.onPressed, isNull);
    });
  });
}
