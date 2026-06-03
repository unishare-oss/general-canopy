import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/auth/domain/entities/plant_experience.dart';

void main() {
  group('PlantExperience.label', () {
    test('beginner returns "Beginner"', () {
      expect(PlantExperience.beginner.label, 'Beginner');
    });

    test('houseplant returns "Houseplant keeper"', () {
      expect(PlantExperience.houseplant.label, 'Houseplant keeper');
    });

    test('backyardGardener returns "Backyard gardener"', () {
      expect(PlantExperience.backyardGardener.label, 'Backyard gardener');
    });

    test('professional returns "Professional"', () {
      expect(PlantExperience.professional.label, 'Professional');
    });

    test('every value has a non-empty label', () {
      for (final value in PlantExperience.values) {
        expect(value.label, isNotEmpty);
      }
    });
  });
}
