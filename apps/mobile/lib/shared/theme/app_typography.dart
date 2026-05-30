import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  /// Editorial pairing: Fraunces (serif) for display/headline, Space Grotesk
  /// (sans) for everything else. Both colored to [color].
  static TextTheme textTheme(Color color) {
    final base = GoogleFonts.spaceGroteskTextTheme().apply(
      bodyColor: color,
      displayColor: color,
    );
    return base.copyWith(
      displayLarge: GoogleFonts.fraunces(textStyle: base.displayLarge),
      displayMedium: GoogleFonts.fraunces(textStyle: base.displayMedium),
      displaySmall: GoogleFonts.fraunces(textStyle: base.displaySmall),
      headlineLarge: GoogleFonts.fraunces(textStyle: base.headlineLarge),
      headlineMedium: GoogleFonts.fraunces(textStyle: base.headlineMedium),
      headlineSmall: GoogleFonts.fraunces(textStyle: base.headlineSmall),
    );
  }

  static TextStyle mono({TextStyle? base}) =>
      GoogleFonts.firaCode(textStyle: base);
}
