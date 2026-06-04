import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:canopy/features/auth/presentation/providers/current_user_provider.dart';
import 'package:canopy/features/grove/domain/entities/adopted_sapling.dart';
import 'package:canopy/features/grove/presentation/providers/grove_providers.dart';
import 'package:canopy/features/grove/presentation/widgets/sapling_card.dart';
import 'package:canopy/features/grove/presentation/widgets/water_confirm_sheet.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/presentation/providers/available_saplings_provider.dart';
import 'package:canopy/shared/theme/app_colors.dart';

class GroveScreen extends ConsumerWidget {
  const GroveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final groveAsync = ref.watch(myGroveProvider);
    final user = ref.watch(currentUserProvider).asData?.value;
    final availableAsync = ref.watch(availableSaplingsProvider);

    final greeting = _greeting();
    final displayName = user?.name.split(' ').first ?? 'there';

    return SafeArea(
      child: groveAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: cs.error),
                const SizedBox(height: 16),
                Text('Could not load your grove.', style: tt.bodyMedium),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => ref.invalidate(myGroveProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (saplings) => _GroveContent(
          saplings: saplings,
          greeting: greeting,
          displayName: displayName,
          uid: user?.id ?? '',
          availableSaplings:
              availableAsync.asData?.value.take(4).toList() ?? [],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 18) return 'Good afternoon,';
    return 'Good evening,';
  }
}

// ── Content ──────────────────────────────────────────────────────────────────

class _GroveContent extends StatelessWidget {
  const _GroveContent({
    required this.saplings,
    required this.greeting,
    required this.displayName,
    required this.uid,
    required this.availableSaplings,
  });

  final List<AdoptedSapling> saplings;
  final String greeting;
  final String displayName;
  final String uid;
  final List<Sapling> availableSaplings;

  List<AdoptedSapling> get _needsAction =>
      saplings.where((s) => s.isOverdue || s.isDueToday).toList();

  int get _streakDays {
    if (saplings.isEmpty) return 0;
    final earliest = saplings.reduce(
      (a, b) => a.adoptedAt.isBefore(b.adoptedAt) ? a : b,
    );
    return DateTime.now().difference(earliest.adoptedAt).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final needsAction = _needsAction;

    return CustomScrollView(
      slivers: [
        // ── Top bar ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: tt.titleMedium),
                      Text(
                        displayName,
                        style: tt.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      if (saplings.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Guardian of ${saplings.length} tree${saplings.length == 1 ? '' : 's'}'
                            '${_streakDays > 0 ? ' · $_streakDays-day streak' : ''}',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_outlined),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // ── Today block ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: _TodayCard(
              saplings: saplings,
              needsAction: needsAction,
              uid: uid,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 10)),

        // ── Quick stats ──────────────────────────────────────────────────
        if (saplings.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _QuickStats(saplings: saplings, streakDays: _streakDays),
            ),
          ),

        // ── My Grove header ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Grove',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  onPressed: () => context.go('/discover'),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Adopt more'),
                ),
              ],
            ),
          ),
        ),

        // ── Sapling list / empty state ────────────────────────────────────
        if (saplings.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.park_outlined,
                      size: 64,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text('Your grove is empty', style: tt.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Head to Discover and adopt your first sapling.',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.go('/discover'),
                      icon: const Icon(Icons.explore_outlined),
                      label: const Text('Discover saplings'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: saplings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => SaplingCard(
                sapling: saplings[i],
                onTap: () => context.go('/grove/sapling/${saplings[i].id}'),
                onWater: () => showWaterConfirmSheet(
                  context,
                  sapling: saplings[i],
                  uid: uid,
                ),
              ),
            ),
          ),

        // ── On your block ─────────────────────────────────────────────────
        if (availableSaplings.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'On your block',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/discover'),
                    child: const Text('See all'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _OnYourBlock(saplings: availableSaplings)),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ── Today Card ────────────────────────────────────────────────────────────────

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.saplings,
    required this.needsAction,
    required this.uid,
  });

  final List<AdoptedSapling> saplings;
  final List<AdoptedSapling> needsAction;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppColors>()!;
    final hasAction = needsAction.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasAction ? 'TODAY' : 'ALL GOOD',
                      style: tt.labelSmall?.copyWith(
                        color: hasAction ? ac.amber : cs.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasAction
                          ? '${needsAction.length} tree${needsAction.length > 1 ? 's' : ''} need${needsAction.length > 1 ? '' : 's'} you'
                          : saplings.isEmpty
                          ? 'Start your grove.'
                          : 'Your grove is thriving.',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasAction
                          ? 'Tap to log a care action for your trees.'
                          : saplings.isEmpty
                          ? 'Head to Discover to adopt your first tree.'
                          : 'Next check-in scheduled soon.',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                hasAction ? Icons.water_drop_outlined : Icons.cloud_outlined,
                size: 36,
                color: hasAction ? ac.info : cs.primary.withValues(alpha: 0.6),
              ),
            ],
          ),
          if (hasAction) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: needsAction.map((s) {
                return _WaterActionButton(sapling: s, uid: uid);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _WaterActionButton extends StatelessWidget {
  const _WaterActionButton({required this.sapling, required this.uid});
  final AdoptedSapling sapling;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FilledButton.icon(
      onPressed: () =>
          showWaterConfirmSheet(context, sapling: sapling, uid: uid),
      style: FilledButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: const StadiumBorder(),
      ),
      icon: const Icon(Icons.water_drop, size: 14),
      label: Text(
        'Water ${sapling.nickname}',
        style: tt.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: cs.onPrimary,
        ),
      ),
    );
  }
}

// ── Quick Stats ───────────────────────────────────────────────────────────────

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.saplings, required this.streakDays});

  final List<AdoptedSapling> saplings;
  final int streakDays;

  int get _healthyCount => saplings
      .where(
        (s) =>
            s.healthStatus == HealthStatus.excellent ||
            s.healthStatus == HealthStatus.good,
      )
      .length;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.park_rounded,
            value: '${saplings.length}',
            label: 'Trees',
            iconColor: cs.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            icon: Icons.local_fire_department_rounded,
            value: '$streakDays',
            label: 'Day streak',
            iconColor: ac.amber,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            icon: Icons.favorite_rounded,
            value: '$_healthyCount',
            label: 'Healthy',
            iconColor: ac.success,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── On Your Block ─────────────────────────────────────────────────────────────

class _OnYourBlock extends StatelessWidget {
  const _OnYourBlock({required this.saplings});
  final List<Sapling> saplings;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: saplings.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final s = saplings[i];
          final accent = Color(
            int.parse('0xFF${s.colorHex.replaceFirst('#', '')}'),
          );
          return GestureDetector(
            onTap: () => context.go('/discover'),
            child: Container(
              width: 132,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: s.photoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              s.photoUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.park_rounded,
                              color: accent,
                              size: 44,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.nickname,
                    style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    s.species,
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
