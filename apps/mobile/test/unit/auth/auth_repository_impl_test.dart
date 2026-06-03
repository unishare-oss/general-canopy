import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/auth/data/models/app_user_model.dart';
import 'package:canopy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:canopy/features/auth/domain/entities/auth_exception.dart';

import 'fakes/fake_firebase_auth_datasource.dart';
import 'fakes/fake_firestore_user_datasource.dart';

void main() {
  group('AuthRepositoryImpl', () {
    late FakeFirebaseAuthDatasource fakeAuth;
    late FakeFirestoreUserDatasource fakeFirestore;
    late AuthRepositoryImpl repo;

    setUp(() {
      fakeAuth = FakeFirebaseAuthDatasource();
      fakeFirestore = FakeFirestoreUserDatasource();
      repo = AuthRepositoryImpl(
        authDatasource: fakeAuth,
        firestoreDatasource: fakeFirestore,
      );
    });

    tearDown(() => fakeAuth.closeAuthState());

    group('authStateChanges', () {
      test('emits AppUser from Firestore when doc exists', () async {
        fakeFirestore.storedUsers['uid-123'] = const AppUserModel(
          id: 'uid-123',
          name: 'Alice',
          email: 'alice@example.com',
        );
        final future = repo.authStateChanges.first;
        fakeAuth.emitAuthState(FakeFirebaseUser(uid: 'uid-123'));

        final user = await future;
        expect(user?.id, 'uid-123');
        expect(user?.name, 'Alice');
      });

      test(
        'falls back to Firebase Auth data when Firestore doc is missing',
        () async {
          final future = repo.authStateChanges.first;
          fakeAuth.emitAuthState(FakeFirebaseUser(uid: 'uid-no-doc'));

          final user = await future;
          expect(user?.id, 'uid-no-doc');
          // onboardingComplete defaults to false, not old departmentId field
          expect(user?.onboardingComplete, isFalse);
        },
      );

      test('emits null when signed out', () async {
        final future = repo.authStateChanges.first;
        fakeAuth.emitAuthState(null);

        final user = await future;
        expect(user, isNull);
      });
    });

    group('signInWithEmail', () {
      test(
        'returns AppUser mapped from Firebase user + Firestore doc',
        () async {
          fakeAuth.nextUid = 'uid-123';
          fakeFirestore.storedUsers['uid-123'] = const AppUserModel(
            id: 'uid-123',
            name: 'Alice',
            email: 'alice@example.com',
          );

          final user = await repo.signInWithEmail(
            email: 'alice@example.com',
            password: 'secret',
          );

          expect(user.id, 'uid-123');
          expect(user.name, 'Alice');
          expect(user.email, 'alice@example.com');
        },
      );

      test('propagates AuthException from datasource', () async {
        fakeAuth.throwOnSignIn = const AuthException(
          AuthFailureType.invalidCredentials,
        );

        expect(
          () =>
              repo.signInWithEmail(email: 'bad@example.com', password: 'wrong'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.type,
              'type',
              AuthFailureType.invalidCredentials,
            ),
          ),
        );
      });
    });

    group('signInWithGoogle', () {
      test('creates Firestore doc on first sign-in', () async {
        fakeAuth.nextUid = 'uid-google-new';
        fakeAuth.isNewUser = true;

        final user = await repo.signInWithGoogle();

        expect(fakeFirestore.storedUsers.containsKey('uid-google-new'), isTrue);
        expect(user.id, 'uid-google-new');
      });

      test('does NOT create Firestore doc for returning user', () async {
        fakeAuth.nextUid = 'uid-google-existing';
        fakeAuth.isNewUser = false;
        fakeFirestore.storedUsers['uid-google-existing'] = const AppUserModel(
          id: 'uid-google-existing',
          name: 'Bob',
          email: 'bob@example.com',
        );

        final user = await repo.signInWithGoogle();

        expect(user.name, 'Bob');
        // createUser was not called a second time — count stays at 0 for this uid
        expect(fakeFirestore.createUserCallCount, 0);
      });
    });

    group('signUpWithEmail', () {
      test('creates both Firebase user and Firestore doc', () async {
        fakeAuth.nextUid = 'uid-new-email';

        final user = await repo.signUpWithEmail(
          name: 'Carol',
          email: 'carol@example.com',
          password: 'secret123',
        );

        expect(fakeAuth.createUserCallCount, 1);
        expect(fakeFirestore.createUserCallCount, 1);
        expect(user.id, 'uid-new-email');
        expect(user.name, 'Carol');
      });

      test('does NOT pass universityId — Canopy has no such field', () async {
        fakeAuth.nextUid = 'uid-no-uni';

        await repo.signUpWithEmail(
          name: 'Dave',
          email: 'dave@example.com',
          password: 'secret123',
        );

        // The stored model must not have any university-related data
        final stored = fakeFirestore.storedUsers['uid-no-uni'];
        expect(stored, isNotNull);
        expect(stored?.neighborhood, isNull);
      });
    });

    group('updateUserProfile', () {
      test(
        'delegates to Firestore datasource with correct arguments',
        () async {
          fakeFirestore.storedUsers['uid-upd'] = const AppUserModel(
            id: 'uid-upd',
            name: 'Eve',
            email: 'eve@example.com',
          );

          await repo.updateUserProfile(
            uid: 'uid-upd',
            neighborhood: 'East Park',
            onboardingComplete: true,
          );

          expect(fakeFirestore.updateUserProfileCallCount, 1);
          expect(fakeFirestore.lastUpdateUid, 'uid-upd');
          expect(fakeFirestore.lastUpdateNeighborhood, 'East Park');
          expect(fakeFirestore.lastUpdateOnboardingComplete, isTrue);
        },
      );
    });
  });
}
