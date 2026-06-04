import 'package:flutter/material.dart';

import 'package:canopy/features/impact/presentation/widgets/feed_tab.dart';
import 'package:canopy/features/impact/presentation/widgets/leaders_tab.dart';
import 'package:canopy/features/impact/presentation/widgets/mine_tab.dart';
import 'package:canopy/shared/theme/app_colors.dart';

class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Impact', style: tt.displaySmall),
                  Text(
                    'What your grove is doing',
                    style: tt.bodyMedium?.copyWith(color: ac.textMuted),
                  ),
                  const SizedBox(height: 16),
                  _SegmentedTabBar(),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: const [MineTab(), FeedTab(), LeadersTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ac = Theme.of(context).extension<AppColors>()!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: ac.muted,
        borderRadius: BorderRadius.circular(100),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: cs.onSurface,
        unselectedLabelColor: ac.mutedForeground,
        labelStyle: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: tt.labelMedium,
        tabs: const [
          Tab(text: 'Mine'),
          Tab(text: 'Feed'),
          Tab(text: 'Leaders'),
        ],
      ),
    );
  }
}
