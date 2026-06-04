import 'package:flutter/material.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';

class AdoptConfirmSheet extends StatelessWidget {
  const AdoptConfirmSheet({super.key, required this.sapling});

  final Sapling sapling;

  /// Returns `true` if the user confirmed adoption, `false` otherwise.
  static Future<bool> show(BuildContext context, Sapling sapling) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AdoptConfirmSheet(sapling: sapling),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco_outlined, size: 56, color: cs.primary),
            const SizedBox(height: 16),
            Text(
              'Adopt ${sapling.nickname}?',
              style: tt.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll be responsible for caring for this tree.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.favorite_outline),
                    label: const Text('Adopt'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
