import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/shared/constants/neighborhoods.dart';

void main() {
  group('kNeighborhoods', () {
    test('contains exactly 15 districts', () {
      expect(kNeighborhoods.length, 15);
    });

    test('contains Bangkok district strings', () {
      expect(kNeighborhoods, contains('Chatuchak'));
      expect(kNeighborhoods, contains('Silom'));
      expect(kNeighborhoods, contains('Lat Phrao'));
      expect(kNeighborhoods, contains('Ari'));
      expect(kNeighborhoods, contains('Thonglor'));
      expect(kNeighborhoods, contains('On Nut'));
    });

    test('has no duplicates', () {
      final unique = kNeighborhoods.toSet();
      expect(unique.length, kNeighborhoods.length);
    });
  });
}
