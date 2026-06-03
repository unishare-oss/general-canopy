import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/presentation/providers/available_saplings_provider.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allSaplingsProvider);

    return allAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text('Could not load map.')),
      data: (saplings) => _SaplingMap(saplings: saplings),
    );
  }
}

class _SaplingMap extends StatelessWidget {
  const _SaplingMap({required this.saplings});

  final List<Sapling> saplings;

  @override
  Widget build(BuildContext context) {
    // Default center — Bangkok coordinates.
    const defaultCenter = LatLng(13.7563, 100.5018);

    final markers = saplings.map((s) {
      final color = Color(int.parse('0xFF${s.colorHex.replaceFirst('#', '')}'));
      final isAdopted = !s.isAvailable;
      return Marker(
        point: LatLng(s.lat, s.lng),
        width: 36,
        height: 36,
        child: GestureDetector(
          onTap: () => context.push('/sapling/${s.id}'),
          child: Opacity(
            opacity: isAdopted ? 0.4 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: Icon(
                isAdopted ? Icons.favorite : Icons.park,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return FlutterMap(
      options: const MapOptions(initialCenter: defaultCenter, initialZoom: 13),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.canopy.app',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
