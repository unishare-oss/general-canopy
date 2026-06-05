import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:canopy/shared/theme/app_colors.dart';

/// Empty state shown on the You tab for anonymous/guest users.
class GuestProfilePrompt extends StatelessWidget {
  const GuestProfilePrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline_rounded, size: 56, color: cs.primary),
            const SizedBox(height: 16),
            Text(
              'Create an account',
              style: tt.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign up to save your profile, adopt saplings, '
              'and track your impact.',
              style: tt.bodyMedium?.copyWith(color: ac.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.push('/welcome?redirect=/you'),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
