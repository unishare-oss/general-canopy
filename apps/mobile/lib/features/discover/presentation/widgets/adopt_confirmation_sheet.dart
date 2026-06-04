import 'package:flutter/material.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';

class AdoptConfirmationSheet extends StatelessWidget {
  const AdoptConfirmationSheet({super.key, required this.sapling});

  final Sapling sapling;

  static Future<void> show(BuildContext context, Sapling sapling) =>
      showModalBottomSheet<void>(
        context: context,
        builder: (_) => AdoptConfirmationSheet(sapling: sapling),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      );

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
            Icon(Icons.check_circle_outline, size: 64, color: cs.primary),
            const SizedBox(height: 16),
            Text(
              "You've adopted ${sapling.nickname}!",
              style: tt.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${sapling.species} · ${sapling.neighborhood}',
              style: tt.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
