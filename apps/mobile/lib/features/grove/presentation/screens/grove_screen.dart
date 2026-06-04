import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:canopy/features/auth/presentation/providers/current_user_provider.dart';
import 'package:canopy/features/grove/domain/entities/adopted_sapling.dart';
import 'package:canopy/features/grove/presentation/providers/grove_providers.dart';
import 'package:canopy/features/grove/presentation/widgets/sapling_card.dart';

class GroveScreen extends ConsumerWidget {
  const GroveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final groveAsync = ref.watch(myGroveProvider);
    final user = ref.watch(currentUserProvider).asData?.value;

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

class _GroveContent extends StatelessWidget {
  const _GroveContent({
    required this.saplings,
    required this.greeting,
    required this.displayName,
  });

  final List<AdoptedSapling> saplings;
  final String greeting;
  final String displayName;

  AdoptedSapling? get _urgentSapling {
    try {
      return saplings.firstWhere((s) => s.isOverdue || s.isDueToday);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final urgent = _urgentSapling;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(greeting, style: tt.titleMedium),
                Text(
                  displayName,
                  style: tt.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                if (saplings.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Guardian of ${saplings.length} tree${saplings.length == 1 ? '' : 's'}',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 20),

                // Today's urgent action banner
                if (urgent != null) _UrgentBanner(sapling: urgent),

                // Stats row
                if (saplings.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _StatsRow(saplings: saplings),
                ],
                const SizedBox(height: 24),

                // Section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Grove',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/discover'),
                      child: const Text('Adopt more'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // Empty state or sapling list
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
                    Text('No saplings yet', style: tt.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Head to Discover to adopt your first tree.',
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.separated(
              itemCount: saplings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => SaplingCard(
                sapling: saplings[i],
                onTap: () => context.go('/grove/sapling/${saplings[i].id}'),
              ),
            ),
          ),
      ],
    );
  }
}

class _UrgentBanner extends StatelessWidget {
  const _UrgentBanner({required this.sapling});
  final AdoptedSapling sapling;

  static String _actionVerb(AdoptedSapling s) => switch (s.nextActionType) {
    _ when s.isOverdue => 'log a ${s.nextActionType.name}',
    _ => s.nextActionType.name,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sapling.isOverdue
                ? '${sapling.nickname} needs attention'
                : '1 tree needs you',
            style: tt.titleSmall?.copyWith(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sapling.isOverdue
                ? '${sapling.nickname} is overdue for care.'
                : 'Tap to ${_actionVerb(sapling)} — scheduled for today.',
            style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () {},
            child: Text(
              '${sapling.nextActionType.name[0].toUpperCase()}'
              '${sapling.nextActionType.name.substring(1)} '
              '${sapling.nickname}',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.saplings});
  final List<AdoptedSapling> saplings;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final healthy = saplings
        .where(
          (s) =>
              s.healthStatus == HealthStatus.excellent ||
              s.healthStatus == HealthStatus.good,
        )
        .length;

    return Row(
      children: [
        _StatChip(value: '${saplings.length}', label: 'Trees', cs: cs, tt: tt),
        const SizedBox(width: 8),
        _StatChip(value: '$healthy', label: 'Healthy', cs: cs, tt: tt),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.label,
    required this.cs,
    required this.tt,
  });

  final String value;
  final String label;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
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
