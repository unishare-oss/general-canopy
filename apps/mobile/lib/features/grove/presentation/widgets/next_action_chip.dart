import 'package:flutter/material.dart';
import 'package:canopy/features/grove/domain/entities/adopted_sapling.dart';

class NextActionChip extends StatelessWidget {
  const NextActionChip({super.key, required this.sapling});

  final AdoptedSapling sapling;

  static IconData _iconFor(NextActionType type) => switch (type) {
    NextActionType.water => Icons.water_drop_outlined,
    NextActionType.fertilize => Icons.eco_outlined,
    NextActionType.prune => Icons.content_cut_outlined,
    NextActionType.inspect => Icons.search_outlined,
  };

  static String _labelFor(NextActionType type) => switch (type) {
    NextActionType.water => 'Water',
    NextActionType.fertilize => 'Fertilize',
    NextActionType.prune => 'Prune',
    NextActionType.inspect => 'Inspect',
  };

  String _dueLabel() {
    if (sapling.isOverdue) return 'Overdue';
    final diff = sapling.nextActionAt.difference(DateTime.now());
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    return 'in ${diff.inDays} d';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUrgent = sapling.isOverdue || sapling.isDueToday;

    final bgColor = isUrgent ? cs.errorContainer : cs.secondaryContainer;
    final fgColor = isUrgent ? cs.onErrorContainer : cs.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(sapling.nextActionType), size: 12, color: fgColor),
          const SizedBox(width: 4),
          Text(
            '${_labelFor(sapling.nextActionType)} · ${_dueLabel()}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
