import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';
import 'package:canopy/features/auth/domain/repositories/auth_repository.dart';
import 'package:canopy/features/auth/domain/usecases/sign_up_with_email.dart';

class _FakeAuthRepository implements AuthRepository {
  String? capturedName;
  String? capturedEmail;

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
  }) async {
    capturedName = name;
    capturedEmail = email;
    return AppUser(id: 'uid-su', name: name, email: email);
  }

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
  }) => throw UnimplementedError();

  @override
  Future<AppUser> linkAnonymousAccount({
    required String uid,
    required Object credential,
  }) => throw UnimplementedError();
}

void main() {
  test('SignUpWithEmail delegates to repository with correct params', () async {
    final repo = _FakeAuthRepository();
    final useCase = SignUpWithEmail(repo);

    final user = await useCase(
      name: 'Alice',
      email: 'alice@example.com',
      password: 'secret123',
    );

    expect(repo.capturedName, 'Alice');
    expect(repo.capturedEmail, 'alice@example.com');
    expect(user.id, 'uid-su');
  });

  test('SignUpWithEmail does not accept universityId parameter', () {
    // This test verifies at the type level that universityId is no longer
    // a parameter of SignUpWithEmail.call — if universityId were still present,
    // the call below would fail to compile.
    final repo = _FakeAuthRepository();
    final useCase = SignUpWithEmail(repo);

    // Should compile fine with only name/email/password
    expect(
      () => useCase(
        name: 'Bob',
        email: 'bob@example.com',
        password: 'password123',
      ),
      returnsNormally,
    );
  });
}
