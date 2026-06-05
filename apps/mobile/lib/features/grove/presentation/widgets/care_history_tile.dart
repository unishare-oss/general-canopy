import 'package:flutter/material.dart';
import 'package:canopy/features/grove/domain/entities/care_event.dart';

class CareHistoryTile extends StatelessWidget {
  const CareHistoryTile({super.key, required this.event});

  final CareEvent event;

  static IconData _iconFor(CareEventType type) => switch (type) {
    CareEventType.water => Icons.water_drop_outlined,
    CareEventType.fertilize => Icons.eco_outlined,
    CareEventType.prune => Icons.content_cut_outlined,
    CareEventType.inspect => Icons.search_outlined,
    CareEventType.adopted => Icons.favorite_outline,
  };

  static String _labelFor(CareEventType type) => switch (type) {
    CareEventType.water => 'Watered',
    CareEventType.fertilize => 'Fertilized',
    CareEventType.prune => 'Pruned',
    CareEventType.inspect => 'Inspected',
    CareEventType.adopted => 'Adopted',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final delta = event.healthScoreDelta;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: cs.secondaryContainer,
        child: Icon(
          _iconFor(event.type),
          size: 18,
          color: cs.onSecondaryContainer,
        ),
      ),
      title: Text(
        '${_labelFor(event.type)} · ${_formatDate(event.performedAt)}',
        style: tt.bodyMedium,
      ),
      subtitle: event.note != null
          ? Text(event.note!, style: tt.bodySmall)
          : null,
      trailing: delta != null
          ? Text(
              delta >= 0 ? '+$delta' : '$delta',
              style: tt.labelMedium?.copyWith(
                color: delta >= 0 ? const Color(0xFF4CAF50) : cs.error,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
