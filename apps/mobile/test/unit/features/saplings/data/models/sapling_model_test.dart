import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/saplings/data/models/sapling_model.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';

void main() {
  // Base JSON fixture — matches production Firestore document shape.
  final baseJson = <String, dynamic>{
    'nickname': 'Olive',
    'species': 'Eastern Redbud',
    'latin': 'Cercis canadensis',
    'personality': 'A shy understudy with heart-shaped leaves.',
    'photoUrl': null,
    'color': '#D87FA8', // JSON key is 'color'; Dart field is 'colorHex'
    'street': '142 Linden Ave',
    'neighborhood': 'Maple Heights',
    'lat': 0.42,
    'lng': 0.31,
    'ageLabel': 'Sapling · 6mo',
    'heightLabel': '1.2m',
    'waterNeedLabel': 'Every 3 days in summer',
    'lightLabel': 'Partial sun',
    'wateringIntervalDays': 7,
    'status': 'available',
    'adoptedBy': null,
  };

  group('SaplingModel.fromJson', () {
    test('maps all fields from JSON', () {
      final model = SaplingModel.fromJson(baseJson);

      expect(model.nickname, 'Olive');
      expect(model.species, 'Eastern Redbud');
      expect(model.latin, 'Cercis canadensis');
      expect(model.personality, 'A shy understudy with heart-shaped leaves.');
      expect(model.photoUrl, isNull);
      expect(model.street, '142 Linden Ave');
      expect(model.neighborhood, 'Maple Heights');
      expect(model.lat, 0.42);
      expect(model.lng, 0.31);
      expect(model.ageLabel, 'Sapling · 6mo');
      expect(model.heightLabel, '1.2m');
      expect(model.waterNeedLabel, 'Every 3 days in summer');
      expect(model.lightLabel, 'Partial sun');
      expect(model.wateringIntervalDays, 7);
      expect(model.status, 'available');
      expect(model.adoptedBy, isNull);
    });

    test('colorHex is read from JSON key "color"', () {
      final model = SaplingModel.fromJson(baseJson);
      expect(model.colorHex, '#D87FA8');
    });

    test('missing wateringIntervalDays defaults to 3', () {
      final json = Map<String, dynamic>.from(baseJson)
        ..remove('wateringIntervalDays');
      final model = SaplingModel.fromJson(json);
      expect(model.wateringIntervalDays, 3);
    });

    test('missing status defaults to "available"', () {
      final json = Map<String, dynamic>.from(baseJson)..remove('status');
      final model = SaplingModel.fromJson(json);
      expect(model.status, 'available');
    });
  });

  group('SaplingModel.toEntity', () {
    test('maps available status to SaplingStatus.available', () {
      final model = SaplingModel.fromJson(baseJson);
      final entity = model.toEntity('doc-1');

      expect(entity.id, 'doc-1');
      expect(entity.status, SaplingStatus.available);
      expect(entity.isAvailable, isTrue);
    });

    test('maps adopted status to SaplingStatus.adopted', () {
      final json = Map<String, dynamic>.from(baseJson)
        ..['status'] = 'adopted'
        ..['adoptedBy'] = 'user-abc';
      final entity = SaplingModel.fromJson(json).toEntity('doc-2');

      expect(entity.status, SaplingStatus.adopted);
      expect(entity.adoptedBy, 'user-abc');
      expect(entity.isAvailable, isFalse);
    });

    test('unknown status strings fall back to SaplingStatus.available', () {
      final json = Map<String, dynamic>.from(baseJson)
        ..['status'] = 'pending_review';
      final entity = SaplingModel.fromJson(json).toEntity('doc-3');

      expect(entity.status, SaplingStatus.available);
      expect(entity.isAvailable, isTrue);
    });

    test('toEntity preserves colorHex from JSON color key', () {
      final model = SaplingModel.fromJson(baseJson);
      final entity = model.toEntity('doc-4');
      expect(entity.colorHex, '#D87FA8');
    });
  });
}
