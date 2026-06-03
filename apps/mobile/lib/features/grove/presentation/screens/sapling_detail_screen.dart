import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:canopy/features/auth/presentation/providers/current_user_provider.dart';
import 'package:canopy/features/grove/domain/entities/adopted_sapling.dart';
import 'package:canopy/features/grove/presentation/providers/grove_providers.dart';
import 'package:canopy/features/grove/presentation/widgets/care_history_tile.dart';
import 'package:canopy/features/grove/presentation/widgets/growth_comparison.dart';
import 'package:canopy/features/grove/presentation/widgets/health_score_ring.dart';
import 'package:canopy/features/grove/presentation/widgets/next_action_chip.dart';
import 'package:canopy/features/grove/presentation/widgets/photo_timeline.dart';

class SaplingDetailScreen extends ConsumerWidget {
  const SaplingDetailScreen({super.key, required this.adoptionId});

  final String adoptionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider).asData?.value?.id ?? '';
    final detailAsync = ref.watch(adoptionDetailProvider(uid, adoptionId));

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Could not load sapling details.')),
        data: (sapling) =>
            _DetailBody(sapling: sapling, uid: uid, adoptionId: adoptionId),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({
    required this.sapling,
    required this.uid,
    required this.adoptionId,
  });

  final AdoptedSapling sapling;
  final String uid;
  final String adoptionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final photosAsync = ref.watch(adoptionPhotosProvider(uid, adoptionId));
    final historyAsync = ref.watch(careHistoryProvider(uid, adoptionId));

    final accentColor = Color(
      int.parse('0xFF${sapling.colorHex.replaceFirst('#', '')}'),
    );
    final photos = photosAsync.asData?.value ?? [];
    final history = historyAsync.asData?.value ?? [];

    return CustomScrollView(
      slivers: [
        // Hero header
        SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: ColoredBox(
              color: accentColor,
              child: (sapling.coverPhotoUrl ?? sapling.photoUrl) != null
                  ? Image.network(
                      (sapling.coverPhotoUrl ?? sapling.photoUrl)!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.park_rounded,
                          size: 80,
                          color: cs.onPrimary,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.park_rounded,
                        size: 80,
                        color: cs.onPrimary,
                      ),
                    ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList.list(
            children: [
              // Name + species
              Text(
                sapling.nickname,
                style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                sapling.species,
                style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    sapling.street.isNotEmpty
                        ? '${sapling.street}, ${sapling.neighborhood}'
                        : sapling.neighborhood,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Health + next action row
              Row(
                children: [
                  HealthScoreRing(score: sapling.healthScore, size: 64),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Health score', style: tt.labelMedium),
                      const SizedBox(height: 4),
                      NextActionChip(sapling: sapling),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Growth comparison
              Text(
                'Growth',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              GrowthComparison(photos: photos),
              const SizedBox(height: 28),

              // Photo timeline
              Text(
                'Photos',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              PhotoTimeline(photos: photos),
              const SizedBox(height: 28),

              // Care history
              Text(
                'Care history',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              if (history.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No care events recorded yet.',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                )
              else
                ...history.map((e) => CareHistoryTile(event: e)),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}
