import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/shared/constants/neighborhoods.dart';

void main() {
  group('kNeighborhoods', () {
    test('contains exactly 4 districts', () {
      expect(kNeighborhoods.length, 4);
    });

    test('contains the four specified district strings', () {
      expect(kNeighborhoods, contains('Maple Heights'));
      expect(kNeighborhoods, contains('East Park'));
      expect(kNeighborhoods, contains('Westgate'));
      expect(kNeighborhoods, contains('Riverside'));
    });

    test('has no duplicates', () {
      final unique = kNeighborhoods.toSet();
      expect(unique.length, kNeighborhoods.length);
    });
  });
}
