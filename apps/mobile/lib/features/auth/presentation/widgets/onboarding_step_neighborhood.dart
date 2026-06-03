import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:canopy/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:canopy/shared/constants/neighborhoods.dart';
import 'package:canopy/shared/theme/app_colors.dart';

class OnboardingStepNeighborhood extends ConsumerWidget {
  const OnboardingStepNeighborhood({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      onboardingProvider.select((s) => s.selectedNeighborhood),
    );
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Where is your tree?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pick the neighbourhood closest to your tree.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: ac.textSecondary),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: kNeighborhoods.length,
          itemBuilder: (context, index) {
            final name = kNeighborhoods[index];
            final isSelected = name == selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _NeighbourhoodChip(
                name: name,
                isSelected: isSelected,
                onTap: () => ref
                    .read(onboardingProvider.notifier)
                    .selectNeighborhood(name),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NeighbourhoodChip extends StatelessWidget {
  const _NeighbourhoodChip({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: cs.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
