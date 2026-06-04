import 'package:flutter/material.dart';
import 'package:canopy/features/grove/domain/entities/sapling_photo.dart';

class GrowthComparison extends StatelessWidget {
  const GrowthComparison({super.key, required this.photos});

  final List<SaplingPhoto> photos;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (photos.length < 2) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Not enough photos for comparison yet',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final first = photos.first;
    final latest = photos.last;

    return Row(
      children: [
        Expanded(
          child: _PhotoPane(photo: first, label: 'First'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PhotoPane(photo: latest, label: 'Latest'),
        ),
      ],
    );
  }
}

class _PhotoPane extends StatelessWidget {
  const _PhotoPane({required this.photo, required this.label});

  final SaplingPhoto photo;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            photo.url,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              height: 160,
              color: cs.surfaceContainerHighest,
              child: Icon(
                Icons.broken_image_outlined,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
