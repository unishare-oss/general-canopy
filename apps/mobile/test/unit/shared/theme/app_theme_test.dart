import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canopy/shared/theme/app_colors.dart';
import 'package:canopy/shared/theme/app_theme.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // Drain async font-loading side effects so they don't bleed into
  // the next test and cause spurious post-completion failures.
  Future<void> drainFonts(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  }

  group('AppTheme.fromId', () {
    testWidgets('canopy is light', (tester) async {
      final theme = AppTheme.fromId('canopy');
      expect(theme.brightness, Brightness.light);
      await drainFonts(tester);
    });

    testWidgets('catppuccin-mocha is dark', (tester) async {
      final theme = AppTheme.fromId('catppuccin-mocha');
      expect(theme.brightness, Brightness.dark);
      await drainFonts(tester);
    });

    testWidgets('all themes include AppColors extension', (tester) async {
      for (final id in [
        'canopy',
        'catppuccin-mocha',
        'catppuccin-latte',
        'nord',
        'arctic',
        'tokyo-night',
        'dracula',
        'gruvbox-dark',
        'midnight-library',
        'parchment',
        'ocean-depth',
        'sakura',
      ]) {
        final theme = AppTheme.fromId(id);
        expect(
          theme.extension<AppColors>(),
          isNotNull,
          reason: '$id is missing AppColors extension',
        );
      }
      await drainFonts(tester);
    });

    testWidgets('unknown id falls back to canopy', (tester) async {
      final theme = AppTheme.fromId('does-not-exist');
      expect(theme.brightness, Brightness.light);
      await drainFonts(tester);
    });

    testWidgets('canopy primary is forest green', (tester) async {
      final theme = AppTheme.fromId('canopy');
      expect(theme.colorScheme.primary, const Color(0xFF2F7D4F));
      await drainFonts(tester);
    });

    testWidgets('canopy background is warm cream', (tester) async {
      final theme = AppTheme.fromId('canopy');
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F4EE));
      await drainFonts(tester);
    });

    testWidgets('canopy accent token is forest green', (tester) async {
      final theme = AppTheme.fromId('canopy');
      final ac = theme.extension<AppColors>()!;
      expect(ac.amber, const Color(0xFF2F7D4F)); // "amber" token repurposed as the green accent
      await drainFonts(tester);
    });
  });
}
