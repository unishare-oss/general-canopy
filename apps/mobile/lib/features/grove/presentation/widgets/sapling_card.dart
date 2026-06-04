import 'package:flutter/material.dart';
import 'package:canopy/features/grove/domain/entities/adopted_sapling.dart';
import 'package:canopy/features/grove/presentation/widgets/health_score_ring.dart';
import 'package:canopy/features/grove/presentation/widgets/next_action_chip.dart';

class SaplingCard extends StatelessWidget {
  const SaplingCard({super.key, required this.sapling, this.onTap});

  final AdoptedSapling sapling;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentColor = Color(
      int.parse('0xFF${sapling.colorHex.replaceFirst('#', '')}'),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: accentColor.withValues(alpha: 0.2),
              backgroundImage: sapling.coverPhotoUrl != null
                  ? NetworkImage(sapling.coverPhotoUrl!)
                  : sapling.photoUrl != null
                  ? NetworkImage(sapling.photoUrl!)
                  : null,
              child: (sapling.coverPhotoUrl == null && sapling.photoUrl == null)
                  ? Icon(Icons.park_rounded, color: accentColor, size: 28)
                  : null,
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sapling.nickname,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${sapling.species} · ${sapling.street.isNotEmpty ? sapling.street : sapling.neighborhood}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  NextActionChip(sapling: sapling),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Health ring
            HealthScoreRing(score: sapling.healthScore, size: 52),
          ],
        ),
      ),
    );
  }
}
