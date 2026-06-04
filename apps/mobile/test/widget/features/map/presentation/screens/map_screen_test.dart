import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/presentation/providers/available_saplings_provider.dart';
import 'package:canopy/features/map/presentation/screens/map_screen.dart';
import 'package:canopy/shared/theme/app_theme.dart';
import 'package:canopy/shared/theme/themes.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Sapling _sapling(String id, {SaplingStatus status = SaplingStatus.available}) =>
    Sapling(
      id: id,
      nickname: 'Tree $id',
      species: 'Oak',
      latin: 'Quercus',
      personality: 'Sturdy',
      street: '1 Main St',
      neighborhood: 'Downtown',
      lat: 13.75 + double.parse(id) * 0.01,
      lng: 100.50 + double.parse(id) * 0.01,
      ageLabel: '2yr',
      heightLabel: '2m',
      waterNeedLabel: 'Low',
      lightLabel: 'Full sun',
      wateringIntervalDays: 3,
      colorHex: '#3BA75E',
      status: status,
    );

Widget _buildSubject(List<Sapling> saplings) {
  return ProviderScope(
    overrides: [
      allSaplingsProvider.overrideWith((ref) => Stream.value(saplings)),
    ],
    child: MaterialApp(
      theme: AppTheme.build(AppThemes.canopy),
      home: const Scaffold(body: MapScreen()),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MapScreen', () {
    testWidgets('renders FlutterMap when saplings data loads', (tester) async {
      final saplings = [_sapling('1'), _sapling('2')];

      await tester.pumpWidget(_buildSubject(saplings));
      // Settle so the StreamProvider resolves and the map widget builds.
      await tester.pump();

      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('renders correct number of Marker widgets for saplings', (
      tester,
    ) async {
      final saplings = [_sapling('1'), _sapling('2'), _sapling('3')];

      await tester.pumpWidget(_buildSubject(saplings));
      await tester.pump();

      // FlutterMap renders markers via MarkerLayer. We verify MarkerLayer is
      // present; the exact Marker count is checked via the widget state.
      expect(find.byType(MarkerLayer), findsOneWidget);

      final markerLayer = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
      expect(markerLayer.markers.length, saplings.length);
    });

    testWidgets('renders FlutterMap with zero markers when list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject([]));
      await tester.pump();

      expect(find.byType(FlutterMap), findsOneWidget);
      final markerLayer = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
      expect(markerLayer.markers, isEmpty);
    });

    testWidgets('shows loading indicator before data arrives', (tester) async {
      // Use a stream that never emits to stay in loading state.
      final neverStream = ProviderScope(
        overrides: [
          allSaplingsProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: MaterialApp(
          theme: AppTheme.build(AppThemes.canopy),
          home: const Scaffold(body: MapScreen()),
        ),
      );

      await tester.pumpWidget(neverStream);
      // Do NOT call pumpAndSettle — the stream never resolves.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error text when allSaplingsProvider errors', (
      tester,
    ) async {
      // overrideWithValue(AsyncError) sets the state synchronously on first
      // build — no async pumping needed to reach the error branch.
      final errorScope = ProviderScope(
        overrides: [
          allSaplingsProvider.overrideWithValue(
            AsyncError(Exception('Firestore error'), StackTrace.empty),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.build(AppThemes.canopy),
          home: const Scaffold(body: MapScreen()),
        ),
      );

      await tester.pumpWidget(errorScope);
      await tester.pump();

      expect(find.text('Could not load map.'), findsOneWidget);
    });
  });
}
