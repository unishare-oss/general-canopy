import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';
import 'package:canopy/features/auth/domain/repositories/auth_repository.dart';
import 'package:canopy/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:canopy/features/auth/presentation/providers/onboarding_provider.dart';

// ---------------------------------------------------------------------------
// Fake repository — simulates updateUserProfile success and failure
// ---------------------------------------------------------------------------

class _FakeAuthRepository implements AuthRepository {
  bool shouldThrow = false;
  int updateCallCount = 0;
  bool? lastOnboardingComplete;

  @override
  Stream<AppUser?> get authStateChanges => const Stream.empty();

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
    String? avatarBase64,
    String? neighborhood,
    CheckInFrequency? checkInFrequency,
    PlantExperience? plantExperience,
    NotificationPreferences? notificationPreferences,
    bool? onboardingComplete,
  }) async {
    updateCallCount++;
    lastOnboardingComplete = onboardingComplete;
    if (shouldThrow) throw Exception('Firestore write failed');
  }

  @override
  Future<AppUser> linkAnonymousAccount({
    required String uid,
    required Object credential,
  }) => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer(_FakeAuthRepository repo) {
  return ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  group('OnboardingNotifier state transitions', () {
    late _FakeAuthRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = _FakeAuthRepository();
      container = _makeContainer(fakeRepo);
    });

    tearDown(() => container.dispose());

    test('initial state has currentStep 0 and no selections', () {
      final state = container.read(onboardingProvider);
      expect(state.currentStep, 0);
      expect(state.selectedNeighborhood, isNull);
      expect(state.selectedFrequency, isNull);
      expect(state.selectedExperience, isNull);
      expect(state.isSubmitting, isFalse);
      expect(state.submitError, isNull);
    });

    test('nextStep increments currentStep', () {
      final notifier = container.read(onboardingProvider.notifier);
      notifier.nextStep();
      expect(container.read(onboardingProvider).currentStep, 1);
    });

    test('previousStep decrements currentStep', () {
      final notifier = container.read(onboardingProvider.notifier);
      notifier.nextStep();
      notifier.nextStep();
      notifier.previousStep();
      expect(container.read(onboardingProvider).currentStep, 1);
    });

    test('selectNeighborhood sets selectedNeighborhood', () {
      final notifier = container.read(onboardingProvider.notifier);
      notifier.selectNeighborhood('East Park');
      expect(
        container.read(onboardingProvider).selectedNeighborhood,
        'East Park',
      );
    });

    test('selectFrequency sets selectedFrequency', () {
      final notifier = container.read(onboardingProvider.notifier);
      notifier.selectFrequency(CheckInFrequency.onceAWeek);
      expect(
        container.read(onboardingProvider).selectedFrequency,
        CheckInFrequency.onceAWeek,
      );
    });

    test('selectExperience sets selectedExperience', () {
      final notifier = container.read(onboardingProvider.notifier);
      notifier.selectExperience(PlantExperience.professional);
      expect(
        container.read(onboardingProvider).selectedExperience,
        PlantExperience.professional,
      );
    });
  });

  group('OnboardingNotifier.submit', () {
    late _FakeAuthRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = _FakeAuthRepository();
      container = _makeContainer(fakeRepo);
    });

    tearDown(() => container.dispose());

    test(
      'on success: calls UpdateUserProfile and clears isSubmitting',
      () async {
        final notifier = container.read(onboardingProvider.notifier);

        await notifier.submit('uid-test');

        expect(fakeRepo.updateCallCount, 1);
        expect(fakeRepo.lastOnboardingComplete, isTrue);
        final state = container.read(onboardingProvider);
        expect(state.isSubmitting, isFalse);
        expect(state.submitError, isNull);
      },
    );

    test('on failure: sets submitError and clears isSubmitting', () async {
      fakeRepo.shouldThrow = true;
      final notifier = container.read(onboardingProvider.notifier);

      await notifier.submit('uid-fail');

      final state = container.read(onboardingProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.submitError, isNotNull);
      expect(state.submitError, isNotEmpty);
    });
  });
}
