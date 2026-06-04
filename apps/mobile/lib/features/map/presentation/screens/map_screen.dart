import 'dart:ui' as ui;

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
    const defaultCenter = LatLng(13.7563, 100.5018);

    final markers = saplings.map((s) {
      final color = Color(int.parse('0xFF${s.colorHex.replaceFirst('#', '')}'));
      final isAdopted = !s.isAvailable;
      final markerWidth = isAdopted ? 88.0 : 42.0;
      final markerHeight = isAdopted ? 76.0 : 52.0;
      return Marker(
        point: LatLng(s.lat, s.lng),
        width: markerWidth,
        height: markerHeight,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () => context.push('/sapling/${s.id}'),
          child: _SaplingPin(
            color: color,
            isAdopted: isAdopted,
            adoptedByName: s.adoptedByName,
            adoptedByPhotoUrl: s.adoptedByPhotoUrl,
          ),
        ),
      );
    }).toList();

    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: defaultCenter,
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.canopy.app',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
        Positioned(top: 12, right: 12, child: _LegendButton()),
      ],
    );
  }
}

class _LegendButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _showLegend(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cs.surface,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.info_outline, size: 20, color: cs.onSurface),
      ),
    );
  }

  void _showLegend(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Map legend', style: tt.titleMedium),
              const SizedBox(height: 16),
              _LegendRow(
                icon: Icons.park,
                color: cs.primary,
                label: 'Available',
                description: 'This sapling is waiting to be adopted.',
              ),
              const SizedBox(height: 12),
              _LegendRow(
                icon: Icons.favorite,
                color: cs.tertiary,
                label: 'Adopted',
                description: 'A community member is caring for this tree.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: tt.labelLarge),
              Text(description, style: tt.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _SaplingPin extends StatelessWidget {
  const _SaplingPin({
    required this.color,
    required this.isAdopted,
    this.adoptedByName,
    this.adoptedByPhotoUrl,
  });

  final Color color;
  final bool isAdopted;
  final String? adoptedByName;
  final String? adoptedByPhotoUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isAdopted
              ? _AdopterAvatar(photoUrl: adoptedByPhotoUrl)
              : const Icon(Icons.park, size: 20, color: Colors.white),
        ),
        CustomPaint(
          size: const Size(14, 10),
          painter: _PinTailPainter(color: color),
        ),
        if (isAdopted && adoptedByName != null) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4),
              ],
            ),
            child: Text(
              adoptedByName!,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

class _AdopterAvatar extends StatelessWidget {
  const _AdopterAvatar({this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null) {
      return const Icon(Icons.person, size: 20, color: Colors.white);
    }
    return ClipOval(
      child: Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.person, size: 20, color: Colors.white),
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const Icon(Icons.person, size: 20, color: Colors.white),
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  const _PinTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      ui.Path()
        ..moveTo(size.width / 2, size.height)
        ..lineTo(0, 0)
        ..lineTo(size.width, 0)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_PinTailPainter old) => old.color != color;
}
