import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:canopy/features/grove/domain/entities/adopted_sapling.dart';
import 'package:canopy/features/grove/domain/entities/care_event.dart';
import 'package:canopy/features/grove/presentation/providers/grove_providers.dart';
import 'package:canopy/shared/theme/app_colors.dart';

/// Shows the water-confirmation bottom sheet and returns the result of the
/// action (true = logged, false/null = cancelled).
Future<bool?> showWaterConfirmSheet(
  BuildContext context, {
  required AdoptedSapling sapling,
  required String uid,
}) => showModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  useRootNavigator: true,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (_) => WaterConfirmSheet(sapling: sapling, uid: uid),
);

class WaterConfirmSheet extends ConsumerStatefulWidget {
  const WaterConfirmSheet({
    super.key,
    required this.sapling,
    required this.uid,
  });

  final AdoptedSapling sapling;
  final String uid;

  @override
  ConsumerState<WaterConfirmSheet> createState() => _WaterConfirmSheetState();
}

class _WaterConfirmSheetState extends ConsumerState<WaterConfirmSheet> {
  bool _loading = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      await ref
          .read(logCareEventProvider)
          .call(
            uid: widget.uid,
            adoptionId: widget.sapling.id,
            saplingId: widget.sapling.saplingId,
            type: CareEventType.water,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Watering logged for ${widget.sapling.nickname}!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to log watering. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppColors>()!;
    final accent = Color(
      int.parse('0xFF${widget.sapling.colorHex.replaceFirst('#', '')}'),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Tree icon box
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.park_rounded, color: accent, size: 34),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            'Water ${widget.sapling.nickname}?',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          // Subtitle
          Text(
            'Log 2L watering · next due in 3 days',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Health indicator row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_rounded, size: 14, color: ac.success),
              const SizedBox(width: 4),
              Text(
                'Health +5 pts',
                style: tt.labelSmall?.copyWith(color: ac.success),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Log watering button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _confirm,
              icon: _loading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : const Icon(Icons.water_drop_rounded, size: 18),
              label: Text(_loading ? 'Logging...' : 'Log watering'),
            ),
          ),

          const SizedBox(height: 8),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _loading
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}
