import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/grove/domain/entities/care_event.dart';
import 'package:canopy/features/grove/presentation/widgets/care_history_tile.dart';
import 'package:canopy/shared/theme/app_theme.dart';
import 'package:canopy/shared/theme/themes.dart';

Widget _wrap(CareEvent event) => MaterialApp(
  theme: AppTheme.build(AppThemes.canopy),
  home: Scaffold(body: CareHistoryTile(event: event)),
);

CareEvent _event({int? healthScoreDelta, String? note}) => CareEvent(
  id: 'e1',
  type: CareEventType.water,
  performedAt: DateTime(2026, 6, 5),
  note: note,
  healthScoreDelta: healthScoreDelta,
);

void main() {
  group('CareHistoryTile', () {
    testWidgets('shows the event label and date', (tester) async {
      await tester.pumpWidget(_wrap(_event(healthScoreDelta: 5)));
      expect(find.textContaining('Watered'), findsOneWidget);
      expect(find.textContaining('Jun 5'), findsOneWidget);
    });

    testWidgets('renders a positive health delta badge', (tester) async {
      await tester.pumpWidget(_wrap(_event(healthScoreDelta: 5)));
      expect(find.text('+5'), findsOneWidget);
    });

    testWidgets('renders a zero delta as +0 (e.g. health already maxed)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_event(healthScoreDelta: 0)));
      expect(find.text('+0'), findsOneWidget);
    });

    testWidgets('renders a negative delta without a plus sign', (tester) async {
      await tester.pumpWidget(_wrap(_event(healthScoreDelta: -3)));
      expect(find.text('-3'), findsOneWidget);
    });

    testWidgets('shows no delta badge when healthScoreDelta is null', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_event()));
      // No trailing numeric badge should be present.
      expect(find.textContaining(RegExp(r'^[+-]?\d+$')), findsNothing);
    });

    testWidgets('shows the note as a subtitle when present', (tester) async {
      await tester.pumpWidget(
        _wrap(_event(healthScoreDelta: 5, note: 'Looking healthy')),
      );
      expect(find.text('Looking healthy'), findsOneWidget);
    });
  });
}
