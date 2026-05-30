import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:canopy/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:canopy/features/auth/presentation/providers/auth_state_provider.dart';

/// Placeholder landing screen for an authenticated (or guest) session.
///
/// This is the starting point for the app — replace it with your first real
/// feature. New features live under `lib/features/<name>/` following the
/// Clean Architecture layout (data / domain / presentation).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final user = ref.watch(authStateProvider).asData?.value;

    final identity = user == null
        ? 'No session'
        : user.isAnonymous
        ? 'Signed in as guest'
        : 'Signed in as ${user.email}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canopy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco_rounded, size: 48, color: cs.primary),
              const SizedBox(height: 16),
              Text('Welcome to Canopy', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(identity, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              Text(
                'Build your first feature under lib/features/.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
