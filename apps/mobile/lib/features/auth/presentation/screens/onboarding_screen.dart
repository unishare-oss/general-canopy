import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:canopy/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:canopy/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:canopy/features/auth/presentation/widgets/onboarding_step_experience.dart';
import 'package:canopy/features/auth/presentation/widgets/onboarding_step_frequency.dart';
import 'package:canopy/features/auth/presentation/widgets/onboarding_step_neighborhood.dart';
import 'package:canopy/shared/theme/app_colors.dart';

/// 4-step onboarding quiz. Single `/onboarding` route — no nested routes.
/// Steps:
///   0 — Welcome (intro copy, no input)
///   1 — Neighbourhood selection
///   2 — Check-in frequency selection
///   3 — Plant experience selection + final CTA
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  static const int _totalSteps = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final authAsync = ref.watch(authStateProvider);
    final uid = authAsync.asData?.value?.id;

    // authStateChanges only re-emits on Firebase Auth events, so writing
    // onboardingComplete to Firestore never triggers the router redirect.
    // Navigate directly once submit succeeds.
    ref.listen<OnboardingState>(onboardingProvider, (previous, next) {
      if (previous?.isSubmitting == true &&
          !next.isSubmitting &&
          next.submitError == null &&
          context.mounted) {
        context.go('/grove');
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: back button + progress indicator
            _OnboardingTopBar(
              currentStep: state.currentStep,
              totalSteps: _totalSteps,
              onBack: state.currentStep > 0 ? notifier.previousStep : null,
              onSkip: state.currentStep > 0 && state.currentStep < 3
                  ? notifier.nextStep
                  : null,
            ),

            // Step content — IndexedStack keeps widget state across steps
            Expanded(
              child: IndexedStack(
                index: state.currentStep,
                children: [
                  // Step 0: Welcome
                  _StepWelcome(onGetStarted: notifier.nextStep),

                  // Step 1: Neighbourhood
                  _StepScrollWrapper(child: const OnboardingStepNeighborhood()),

                  // Step 2: Frequency
                  _StepScrollWrapper(child: const OnboardingStepFrequency()),

                  // Step 3: Experience
                  _StepScrollWrapper(child: const OnboardingStepExperience()),
                ],
              ),
            ),

            // Bottom CTA area
            _OnboardingBottomBar(
              currentStep: state.currentStep,
              isSubmitting: state.isSubmitting,
              submitError: state.submitError,
              onNext: notifier.nextStep,
              onSubmit: uid != null ? () => notifier.submit(uid) : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onSkip,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppColors>()!;
    final progress = currentStep / (totalSteps - 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                child: onBack != null
                    ? IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                        onPressed: onBack,
                        color: cs.onSurface,
                        padding: EdgeInsets.zero,
                      )
                    : null,
              ),
              const Spacer(),
              if (onSkip != null)
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: ac.mutedForeground,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Skip',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: ac.mutedForeground),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Segmented progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: cs.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom CTA bar
// ---------------------------------------------------------------------------

class _OnboardingBottomBar extends StatelessWidget {
  const _OnboardingBottomBar({
    required this.currentStep,
    required this.isSubmitting,
    required this.submitError,
    required this.onNext,
    required this.onSubmit,
  });

  final int currentStep;
  final bool isSubmitting;
  final String? submitError;
  final VoidCallback onNext;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Step 0 has its own CTA inline; steps 1-2 use Next; step 3 uses submit
    if (currentStep == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Inline error on submit failure
          if (submitError != null) ...[
            const SizedBox(height: 8),
            Text(
              submitError!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.error),
            ),
            const SizedBox(height: 8),
          ],

          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: isSubmitting
                  ? null
                  : (currentStep == 3 ? onSubmit : onNext),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                disabledBackgroundColor: cs.primary.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : Text(
                      currentStep == 3 ? 'Find me a tree' : 'Next',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scroll wrapper for step content
// ---------------------------------------------------------------------------

class _StepScrollWrapper extends StatelessWidget {
  const _StepScrollWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Step 0: Welcome
// ---------------------------------------------------------------------------

class _StepWelcome extends StatelessWidget {
  const _StepWelcome({required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Illustrated tree block
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 16,
                  child: Icon(
                    Icons.park_rounded,
                    size: 120,
                    color: cs.primary.withValues(alpha: 0.15),
                  ),
                ),
                Icon(Icons.park_rounded, size: 88, color: cs.primary),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'Welcome to Canopy.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Adopt a tree on your block,\nkeep it alive, cool your city.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: ac.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),

          FilledButton(
            onPressed: onGetStarted,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get started',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: cs.onPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
