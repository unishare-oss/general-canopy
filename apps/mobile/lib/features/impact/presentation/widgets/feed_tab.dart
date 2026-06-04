import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:canopy/features/impact/domain/entities/activity_item.dart';
import 'package:canopy/features/impact/presentation/providers/impact_providers.dart';
import 'package:canopy/features/impact/presentation/widgets/activity_feed_list.dart';

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(activityFeedProvider);
    final items = feedAsync.maybeWhen(
      data: (i) => i,
      orElse: () => <ActivityItem>[],
    );
    return ActivityFeedList(items: items);
  }
}
