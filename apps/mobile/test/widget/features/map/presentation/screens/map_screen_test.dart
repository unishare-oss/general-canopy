import 'dart:typed_data';

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

// Offline tile provider so FlutterMap never issues real OSM tile HTTP
// requests during widget tests (which fail with ClientException in the
// sandbox). Returns a 1x1 transparent PNG for every tile.
class _OfflineTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(_transparentPixelPng);
}

final Uint8List _transparentPixelPng = Uint8List.fromList(const <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

Widget _buildSubject(List<Sapling> saplings) {
  return ProviderScope(
    overrides: [
      allSaplingsProvider.overrideWith((ref) => Stream.value(saplings)),
    ],
    child: MaterialApp(
      theme: AppTheme.build(AppThemes.canopy),
      home: Scaffold(body: MapScreen(tileProvider: _OfflineTileProvider())),
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

      // The map renders separate MarkerLayers for saplings and discoveries.
      // Sum markers across all layers; with no discoveries overridden, the
      // total equals the sapling count.
      final layers = tester.widgetList<MarkerLayer>(find.byType(MarkerLayer));
      final totalMarkers = layers.fold<int>(
        0,
        (sum, l) => sum + l.markers.length,
      );
      expect(totalMarkers, saplings.length);
    });

    testWidgets('renders FlutterMap with zero markers when list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject([]));
      await tester.pump();

      expect(find.byType(FlutterMap), findsOneWidget);
      final layers = tester.widgetList<MarkerLayer>(find.byType(MarkerLayer));
      final totalMarkers = layers.fold<int>(
        0,
        (sum, l) => sum + l.markers.length,
      );
      expect(totalMarkers, 0);
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
