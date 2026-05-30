import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canopy/shared/theme/app_typography.dart';

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

  group('AppTypography', () {
    testWidgets(
      'display + headline use a serif (Fraunces); body uses Space Grotesk',
      (tester) async {
        final tt = AppTypography.textTheme(const Color(0xFF000000));
        expect(tt.displayLarge!.fontFamily, contains('Fraunces'));
        expect(tt.headlineMedium!.fontFamily, contains('Fraunces'));
        expect(tt.bodyMedium!.fontFamily, contains('SpaceGrotesk'));
        await drainFonts(tester);
      },
    );

    testWidgets('applies the given color to body and display', (tester) async {
      final tt = AppTypography.textTheme(const Color(0xFF112233));
      expect(tt.bodyMedium!.color, const Color(0xFF112233));
      expect(tt.displayLarge!.color, const Color(0xFF112233));
      await drainFonts(tester);
    });
  });
}
