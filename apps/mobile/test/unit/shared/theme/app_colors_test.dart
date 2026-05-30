import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:canopy/shared/theme/app_colors.dart';

const _sample = AppColors(
  muted: Color(0xFFEFEDE6),
  mutedForeground: Color(0xFF4F5751),
  textSecondary: Color(0xFF4F5751),
  textMuted: Color(0xFF8A8F88),
  amber: Color(0xFF2F7D4F),
  amberHover: Color(0xFF1F5A38),
  amberSubtle: Color(0xFFE8F3EC),
  success: Color(0xFF2F9E44),
  info: Color(0xFF2A6EBB),
  surfaceDark: Color(0xFF1A1F1B),
  cardDark: Color(0xFF1E2C24),
);

void main() {
  group('AppColors', () {
    test('copyWith overrides only specified fields', () {
      final copy = _sample.copyWith(amber: const Color(0xFF000000));
      expect(copy.amber, const Color(0xFF000000));
      expect(copy.success, _sample.success);
    });

    test('copyWith with no args returns equal instance', () {
      final copy = _sample.copyWith();
      expect(copy.amber, _sample.amber);
    });

    test('lerp at t=0 returns this', () {
      final other = _sample.copyWith(amber: const Color(0xFF000000));
      final result = _sample.lerp(other, 0.0);
      expect(result.amber, _sample.amber);
    });

    test('lerp at t=1 returns other', () {
      final other = _sample.copyWith(amber: const Color(0xFF000000));
      final result = _sample.lerp(other, 1.0);
      expect(result.amber, const Color(0xFF000000));
    });

    test('lerp with null other returns this', () {
      final result = _sample.lerp(null, 0.5);
      expect(result.amber, _sample.amber);
    });
  });
}
