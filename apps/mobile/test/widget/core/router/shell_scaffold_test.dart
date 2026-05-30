import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:canopy/core/router/shell_scaffold.dart';

void main() {
  testWidgets('TabPlaceholder renders its title and subtitle', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: TabPlaceholder(title: 'Discover', subtitle: 'Saplings waiting on your block'),
    ));
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Saplings waiting on your block'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
  });
}
