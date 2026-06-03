import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/notification_preferences.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';
import 'package:canopy/features/auth/domain/repositories/auth_repository.dart';
import 'package:canopy/features/auth/domain/usecases/sign_in_with_email.dart';

class _FakeAuthRepository implements AuthRepository {
  String? capturedEmail;
  String? capturedPassword;

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
  }) async {
    capturedEmail = email;
    capturedPassword = password;
    return AppUser(id: 'uid-e', name: 'Email User', email: email);
  }

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
  }) => throw UnimplementedError();

  @override
  Future<AppUser> linkAnonymousAccount({
    required String uid,
    required Object credential,
  }) => throw UnimplementedError();
}

void main() {
  test('SignInWithEmail delegates to repository with correct params', () async {
    final repo = _FakeAuthRepository();
    final useCase = SignInWithEmail(repo);

    final user = await useCase(email: 'test@example.com', password: 'pass123');

    expect(repo.capturedEmail, 'test@example.com');
    expect(repo.capturedPassword, 'pass123');
    expect(user.id, 'uid-e');
  });
}
