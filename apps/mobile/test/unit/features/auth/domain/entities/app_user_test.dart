import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';

void main() {
  group('AppUser default values', () {
    test('onboardingComplete defaults to false', () {
      const user = AppUser(id: 'id', name: 'Name', email: 'e@e.com');
      expect(user.onboardingComplete, isFalse);
    });

    test('notificationPreferences is non-null with both flags false', () {
      const user = AppUser(id: 'id', name: 'Name', email: 'e@e.com');
      expect(user.notificationPreferences, isNotNull);
      expect(user.notificationPreferences.wateringReminders, isFalse);
      expect(user.notificationPreferences.cityAlerts, isFalse);
    });

    test('isAnonymous defaults to false', () {
      const user = AppUser(id: 'id', name: 'Name', email: 'e@e.com');
      expect(user.isAnonymous, isFalse);
    });

    test('providerIds defaults to empty list', () {
      const user = AppUser(id: 'id', name: 'Name', email: 'e@e.com');
      expect(user.providerIds, isEmpty);
    });

    test('optional Canopy fields default to null', () {
      const user = AppUser(id: 'id', name: 'Name', email: 'e@e.com');
      expect(user.neighborhood, isNull);
      expect(user.checkInFrequency, isNull);
      expect(user.plantExperience, isNull);
      expect(user.photoUrl, isNull);
    });
  });
}
