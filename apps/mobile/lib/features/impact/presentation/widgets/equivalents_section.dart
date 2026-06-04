import 'package:flutter/material.dart';
import 'package:canopy/features/impact/domain/entities/impact_equivalent.dart';
import 'package:canopy/shared/theme/app_colors.dart';

class EquivalentsSection extends StatelessWidget {
  const EquivalentsSection({super.key, required this.equivalents});

  final List<ImpactEquivalent> equivalents;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    if (equivalents.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'EQUIVALENT TO',
            style: tt.labelSmall?.copyWith(
              color: ac.textMuted,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...equivalents.map((eq) => _EquivalentRow(equivalent: eq)),
      ],
    );
  }
}

class _EquivalentRow extends StatelessWidget {
  const _EquivalentRow({required this.equivalent});

  final ImpactEquivalent equivalent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    final String displayValue;
    if (equivalent.unit == '%') {
      displayValue = '${equivalent.value.toStringAsFixed(0)}%';
    } else if (equivalent.unit == '~') {
      displayValue = '~${equivalent.value.toStringAsFixed(0)}';
    } else {
      displayValue =
          '${equivalent.value.toStringAsFixed(0)} ${equivalent.unit}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: ac.muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equivalent.label,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                ),
                if (equivalent.subtitle != null)
                  Text(
                    equivalent.subtitle!,
                    style: tt.bodySmall?.copyWith(color: ac.textMuted),
                  ),
              ],
            ),
          ),
          Text(
            displayValue,
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
