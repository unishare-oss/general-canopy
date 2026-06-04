import 'package:flutter/material.dart';
import 'package:canopy/features/impact/domain/entities/impact_summary.dart';

class ImpactHeroCard extends StatelessWidget {
  const ImpactHeroCard({
    super.key,
    required this.summary,
    required this.maxStreakDays,
    required this.carMilesOffset,
  });

  final ImpactSummary summary;
  final int maxStreakDays;
  final double carMilesOffset;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.onPrimary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.onPrimary.withValues(alpha: 0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOU\'VE KEPT ALIVE',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onPrimary.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: tt.displaySmall?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(text: '${summary.adoptedCount}'),
                      TextSpan(
                        text: ' tree${summary.adoptedCount == 1 ? '' : 's'}, ',
                      ),
                      TextSpan(text: '$maxStreakDays'),
                      const TextSpan(text: ' days'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onPrimary.withValues(alpha: 0.85),
                    ),
                    children: [
                      const TextSpan(text: 'That\'s like taking '),
                      TextSpan(
                        text: '${carMilesOffset.toStringAsFixed(0)} mi',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(
                        text:
                            ' of city driving off the road this year. Keep going.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
