import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:canopy/features/auth/domain/entities/plant_experience.dart';
import 'package:canopy/features/auth/presentation/providers/onboarding_provider.dart';

const _experienceIcons = {
  PlantExperience.beginner: Icons.eco_outlined,
  PlantExperience.houseplant: Icons.local_florist_outlined,
  PlantExperience.backyardGardener: Icons.yard_outlined,
  PlantExperience.professional: Icons.park_outlined,
};

class OnboardingStepExperience extends ConsumerWidget {
  const OnboardingStepExperience({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      onboardingProvider.select((s) => s.selectedExperience),
    );
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'How green is your thumb?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us match you with the right tree.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: PlantExperience.values.map((experience) {
            final isSelected = experience == selected;
            return _ExperienceCard(
              experience: experience,
              isSelected: isSelected,
              onTap: () => ref
                  .read(onboardingProvider.notifier)
                  .selectExperience(experience),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.experience,
    required this.isSelected,
    required this.onTap,
  });

  final PlantExperience experience;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final icon = _experienceIcons[experience] ?? Icons.eco_outlined;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              experience.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
