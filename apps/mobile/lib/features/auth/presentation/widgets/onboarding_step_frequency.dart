import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:canopy/shared/theme/app_colors.dart';

const _subtitles = {
  CheckInFrequency.mostDays: 'I walk past it constantly',
  CheckInFrequency.onceAWeek: 'I can swing by weekends',
  CheckInFrequency.twiceAMonth: 'Light-touch guardian',
};

class OnboardingStepFrequency extends ConsumerWidget {
  const OnboardingStepFrequency({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      onboardingProvider.select((s) => s.selectedFrequency),
    );
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'How often can you visit?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ll tailor reminders to fit your schedule.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: ac.textSecondary),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: CheckInFrequency.values.length,
          itemBuilder: (context, index) {
            final frequency = CheckInFrequency.values[index];
            final isSelected = frequency == selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FrequencyCard(
                frequency: frequency,
                subtitle: _subtitles[frequency] ?? '',
                isSelected: isSelected,
                onTap: () => ref
                    .read(onboardingProvider.notifier)
                    .selectFrequency(frequency),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _FrequencyCard extends StatelessWidget {
  const _FrequencyCard({
    required this.frequency,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final CheckInFrequency frequency;
  final String subtitle;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    frequency.label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? cs.onPrimaryContainer.withValues(alpha: 0.8)
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ],
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
