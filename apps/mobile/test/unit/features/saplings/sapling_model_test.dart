import 'package:flutter_test/flutter_test.dart';
import 'package:canopy/features/saplings/data/models/sapling_model.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';

void main() {
  final json = {
    'nickname': 'Olive',
    'species': 'Eastern Redbud',
    'latin': 'Cercis canadensis',
    'personality': 'A shy understudy with heart-shaped leaves.',
    'photoUrl': null,
    'color': '#D87FA8',
    'street': '142 Linden Ave',
    'neighborhood': 'Maple Heights',
    'lat': 0.42,
    'lng': 0.31,
    'ageLabel': 'Sapling · 6mo',
    'heightLabel': '1.2m',
    'waterNeedLabel': 'Every 3 days in summer',
    'lightLabel': 'Partial sun',
    'wateringIntervalDays': 3,
    'status': 'available',
    'adoptedBy': null,
  };

  test('fromJson parses all fields', () {
    final m = SaplingModel.fromJson(json);
    expect(m.nickname, 'Olive');
    expect(m.wateringIntervalDays, 3);
    expect(m.status, 'available');
    expect(m.colorHex, '#D87FA8'); // @JsonKey(name: 'color')
    expect(m.adoptedBy, isNull);
    expect(m.photoUrl, isNull);
  });

  test('toEntity maps to domain Sapling with parsed status', () {
    final s = SaplingModel.fromJson(json).toEntity('t1');
    expect(s, isA<Sapling>());
    expect(s.id, 't1');
    expect(s.status, SaplingStatus.available);
    expect(s.colorHex, '#D87FA8');
    expect(s.isAvailable, isTrue);
  });

  test('toEntity maps adopted status and adoptedBy', () {
    final adoptedJson = Map<String, dynamic>.from(json)
      ..['status'] = 'adopted'
      ..['adoptedBy'] = 'user_abc';
    final s = SaplingModel.fromJson(adoptedJson).toEntity('t2');
    expect(s.status, SaplingStatus.adopted);
    expect(s.adoptedBy, 'user_abc');
    expect(s.isAvailable, isFalse);
  });

  test('toEntity falls back to available for unknown status', () {
    final unknownJson = Map<String, dynamic>.from(json)
      ..['status'] = 'pending_review';
    final s = SaplingModel.fromJson(unknownJson).toEntity('t3');
    expect(s.status, SaplingStatus.available);
    expect(s.isAvailable, isTrue);
  });
}
