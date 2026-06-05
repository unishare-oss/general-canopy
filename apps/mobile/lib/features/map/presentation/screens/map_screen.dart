import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart'
    hide PermissionDeniedException;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:canopy/features/admin/presentation/providers/is_admin_provider.dart';
import 'package:canopy/features/discoveries/domain/entities/discovery.dart';
import 'package:canopy/features/discoveries/presentation/providers/watch_all_discoveries_provider.dart';
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

class _SaplingMap extends ConsumerStatefulWidget {
  const _SaplingMap({required this.saplings});
  final List<Sapling> saplings;

  @override
  ConsumerState<_SaplingMap> createState() => _SaplingMapState();
}

class _SaplingMapState extends ConsumerState<_SaplingMap> {
  final _mapController = MapController();
  bool _showLocation = false;
  AlignOnUpdate _followMode = AlignOnUpdate.never;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _onLocationPressed() async {
    try {
      // On native platforms check permissions explicitly first.
      // On web the browser handles the permission prompt inside getCurrentPosition.
      if (!kIsWeb) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _showSnack('Please enable location services.');
          return;
        }

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _showSnack('Location permission is required.');
          return;
        }
      }

      // medium accuracy resolves faster than high on both device and simulator
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      ).timeout(const Duration(seconds: 20));

      if (!mounted) return;
      final zoom = _mapController.camera.zoom;
      _mapController.move(
        LatLng(pos.latitude, pos.longitude),
        zoom < 14 ? 15 : zoom,
      );
      setState(() {
        _showLocation = true;
        _followMode = AlignOnUpdate.always;
      });
    } on PermissionDeniedException {
      _showSnack('Location permission denied.');
    } on LocationServiceDisabledException {
      _showSnack('Please enable location services.');
    } on TimeoutException {
      _showSnack('Location request timed out. Try again.');
    } catch (e) {
      _showSnack('Could not get location: $e');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const defaultCenter = LatLng(13.7563, 100.5018);

    final discoveriesAsync = ref.watch(watchAllDiscoveriesProvider);
    final isAdmin = ref.watch(isAdminProvider).value ?? false;

    final discoveries = discoveriesAsync.when(
      data: (d) => d,
      loading: () => <Discovery>[],
      error: (_, _) => <Discovery>[],
    );

    final saplingMarkers = widget.saplings.map((s) {
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

    final discoveryMarkers = discoveries.map((d) {
      final color = Color(int.parse('0xFF${d.colorHex.replaceFirst('#', '')}'));
      return Marker(
        point: LatLng(d.lat, d.lng),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => context.push('/discovery/${d.id}'),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.place, size: 20, color: Colors.white),
          ),
        ),
      );
    }).toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: defaultCenter,
            initialZoom: 13,
            onMapEvent: (event) {
              if (_followMode == AlignOnUpdate.always &&
                  event is MapEventMove &&
                  event.source != MapEventSource.mapController) {
                setState(() => _followMode = AlignOnUpdate.never);
              }
            },
            onTap: isAdmin
                ? (_, point) => context.push(
                      '/sapling/create',
                      extra: {'lat': point.latitude, 'lng': point.longitude},
                    )
                : null,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.canopy.app',
            ),
            if (_showLocation)
              CurrentLocationLayer(
                alignPositionOnUpdate: _followMode,
                alignPositionAnimationCurve: Curves.easeInOut,
                alignPositionAnimationDuration:
                    const Duration(milliseconds: 400),
                style: LocationMarkerStyle(
                  markerSize: const Size(22, 22),
                  accuracyCircleColor: Colors.blue.withValues(alpha: 0.1),
                  headingSectorColor: Colors.blue.withValues(alpha: 0.4),
                ),
              ),
            MarkerLayer(markers: saplingMarkers),
            MarkerLayer(markers: discoveryMarkers),
          ],
        ),
        Positioned(top: 12, right: 12, child: _LegendButton()),
        if (isAdmin)
          Positioned(
            top: 12,
            left: 12,
            right: 64,
            child: _AdminHintBanner(),
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: _LocationFAB(
            showLocation: _showLocation,
            isFollowing: _followMode == AlignOnUpdate.always,
            onPressed: _onLocationPressed,
          ),
        ),
      ],
    );
  }
}

class _AdminHintBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app, size: 14, color: cs.onPrimaryContainer),
          const SizedBox(width: 6),
          Text(
            'Tap map to place a sapling',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onPrimaryContainer,
                ),
          ),
        ],
      ),
    );
  }
}

class _LocationFAB extends StatelessWidget {
  const _LocationFAB({
    required this.showLocation,
    required this.isFollowing,
    required this.onPressed,
  });

  final bool showLocation;
  final bool isFollowing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final IconData icon;
    final Color iconColor;
    final Color bgColor;

    if (!showLocation) {
      icon = Icons.my_location;
      iconColor = cs.onSurface;
      bgColor = cs.surface;
    } else if (isFollowing) {
      icon = Icons.my_location;
      iconColor = Colors.white;
      bgColor = cs.primary;
    } else {
      icon = Icons.location_searching;
      iconColor = cs.primary;
      bgColor = cs.surface;
    }

    return FloatingActionButton.small(
      heroTag: 'locationFAB',
      backgroundColor: bgColor,
      elevation: 4,
      onPressed: onPressed,
      child: Icon(icon, color: iconColor, size: 20),
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
                showPin: true,
              ),
              const SizedBox(height: 12),
              _LegendRow(
                icon: Icons.person,
                color: cs.tertiary,
                label: 'Adopted',
                description: 'A community member is caring for this tree.',
                showPin: true,
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
    this.showPin = false,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String description;
  final bool showPin;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              if (showPin)
                CustomPaint(
                  size: const Size(10, 7),
                  painter: _PinTailPainter(color: color),
                ),
            ],
          ),
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
