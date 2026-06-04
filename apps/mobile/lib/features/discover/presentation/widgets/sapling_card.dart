import 'package:flutter/material.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';

class SaplingCard extends StatelessWidget {
  const SaplingCard({super.key, required this.sapling, this.onTap});

  final Sapling sapling;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentColor = Color(
      int.parse('0xFF${sapling.colorHex.replaceFirst('#', '')}'),
    );

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Color accent / photo header
            SizedBox(
              height: 280,
              child: ColoredBox(
                color: accentColor,
                child: sapling.photoUrl != null
                    ? Image.network(
                        sapling.photoUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : Center(
                                child: CircularProgressIndicator(
                                  color: cs.onPrimary,
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                        errorBuilder: (_, _, _) => Center(
                          child: Icon(
                            Icons.park,
                            size: 80,
                            color: cs.onPrimary,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.park, size: 80, color: cs.onPrimary),
                      ),
              ),
            ),
            // Info section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sapling.nickname, style: tt.headlineSmall),
                    const SizedBox(height: 4),
                    Text(sapling.species, style: tt.bodyMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: cs.onSurface,
                        ),
                        const SizedBox(width: 4),
                        Text(sapling.neighborhood, style: tt.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      sapling.personality,
                      style: tt.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _InfoChip(
                          label: sapling.waterNeedLabel,
                          icon: Icons.water_drop_outlined,
                        ),
                        _InfoChip(
                          label: sapling.lightLabel,
                          icon: Icons.wb_sunny_outlined,
                        ),
                        _InfoChip(
                          label: sapling.ageLabel,
                          icon: Icons.calendar_today_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: cs.onSurface),
        const SizedBox(width: 2),
        Text(label, style: tt.labelSmall),
      ],
    );
  }
}
