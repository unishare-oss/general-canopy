import 'package:flutter/material.dart';
import 'package:canopy/features/grove/domain/entities/adopted_sapling.dart';
import 'package:canopy/features/grove/presentation/widgets/health_score_ring.dart';
import 'package:canopy/shared/theme/app_colors.dart';

class SaplingCard extends StatelessWidget {
  const SaplingCard({
    super.key,
    required this.sapling,
    this.onTap,
    this.onWater,
  });

  final AdoptedSapling sapling;
  final VoidCallback? onTap;
  final VoidCallback? onWater;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppColors>()!;
    final accent = Color(
      int.parse('0xFF${sapling.colorHex.replaceFirst('#', '')}'),
    );
    final isOverdue = sapling.isOverdue;
    final isDue = sapling.isDueToday;
    final streakDays = DateTime.now().difference(sapling.adoptedAt).inDays;
    final daysUntil = sapling.nextActionAt.difference(DateTime.now()).inDays;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            // Tree illustration box
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: sapling.coverPhotoUrl != null || sapling.photoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        sapling.coverPhotoUrl ?? sapling.photoUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.park_rounded, color: accent, size: 34),
            ),
            const SizedBox(width: 14),

            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sapling.nickname,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _HealthDot(status: sapling.healthStatus, ac: ac, cs: cs),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${sapling.species} · ${sapling.street.isNotEmpty ? sapling.street : sapling.neighborhood}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _WaterChip(
                        isOverdue: isOverdue,
                        isDue: isDue,
                        daysUntil: daysUntil,
                        ac: ac,
                        cs: cs,
                        tt: tt,
                      ),
                      const SizedBox(width: 6),
                      _StreakChip(days: streakDays, cs: cs, tt: tt),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Health ring + water button
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HealthScoreRing(score: sapling.healthScore, size: 44),
                if (isOverdue || isDue) ...[
                  const SizedBox(height: 6),
                  _WaterButton(onWater: onWater),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _HealthDot extends StatelessWidget {
  const _HealthDot({required this.status, required this.ac, required this.cs});

  final HealthStatus status;
  final AppColors ac;
  final ColorScheme cs;

  Color get _color => switch (status) {
    HealthStatus.excellent => ac.success,
    HealthStatus.good => ac.success,
    HealthStatus.attention => ac.amber,
    HealthStatus.critical => cs.error,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
    );
  }
}

class _WaterChip extends StatelessWidget {
  const _WaterChip({
    required this.isOverdue,
    required this.isDue,
    required this.daysUntil,
    required this.ac,
    required this.cs,
    required this.tt,
  });

  final bool isOverdue;
  final bool isDue;
  final int daysUntil;
  final AppColors ac;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final urgent = isOverdue || isDue;
    final label = isOverdue
        ? 'Overdue ${isOverdue ? daysUntil.abs() : 0}d'
        : isDue
        ? 'Due today'
        : 'Water in ${daysUntil}d';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: urgent ? ac.amberSubtle : cs.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 11,
            color: urgent ? ac.amber : cs.onSurfaceVariant,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: urgent ? ac.amber : cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days, required this.cs, required this.tt});

  final int days;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            size: 11,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(width: 3),
          Text(
            '${days}d',
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterButton extends StatelessWidget {
  const _WaterButton({this.onWater});
  final VoidCallback? onWater;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onWater,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Water',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: cs.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
