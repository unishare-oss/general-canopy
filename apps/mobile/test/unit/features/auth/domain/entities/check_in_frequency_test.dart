import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';

void main() {
  group('CheckInFrequency.label', () {
    test('mostDays returns "Most days"', () {
      expect(CheckInFrequency.mostDays.label, 'Most days');
    });

    test('onceAWeek returns "Once a week"', () {
      expect(CheckInFrequency.onceAWeek.label, 'Once a week');
    });

    test('twiceAMonth returns "Twice a month"', () {
      expect(CheckInFrequency.twiceAMonth.label, 'Twice a month');
    });

    test('every value has a non-empty label', () {
      for (final value in CheckInFrequency.values) {
        expect(value.label, isNotEmpty);
      }
    });
  });
}
