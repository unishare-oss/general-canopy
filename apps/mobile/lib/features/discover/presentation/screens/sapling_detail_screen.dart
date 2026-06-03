import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/usecases/get_sapling_by_id.dart';
import 'package:canopy/features/saplings/presentation/providers/sapling_repository_provider.dart';
import 'package:canopy/features/saplings/presentation/providers/discover_queue_provider.dart';
import 'package:canopy/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:canopy/features/auth/presentation/providers/guest_mode_provider.dart';
import 'package:canopy/features/discover/presentation/widgets/adopt_confirmation_sheet.dart';

// Provider for loading a sapling by ID (family provider — no codegen needed).
final _saplingByIdProvider = FutureProvider.family<Sapling, String>(
  (ref, id) => GetSaplingById(ref.watch(saplingRepositoryProvider))(id),
);

class SaplingDetailScreen extends ConsumerWidget {
  const SaplingDetailScreen({super.key, required this.saplingId});

  final String saplingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saplingAsync = ref.watch(_saplingByIdProvider(saplingId));

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
      body: saplingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Could not load sapling.')),
        data: (sapling) => _SaplingDetailBody(sapling: sapling),
      ),
    );
  }
}

class _SaplingDetailBody extends ConsumerWidget {
  const _SaplingDetailBody({required this.sapling});

  final Sapling sapling;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final accentColor = Color(
      int.parse('0xFF${sapling.colorHex.replaceFirst('#', '')}'),
    );
    final authAsync = ref.watch(authStateProvider);
    final isGuest = ref.watch(guestModeProvider);
    final queueState = ref.watch(discoverQueueProvider);

    final isAuthenticated =
        authAsync.value != null && !authAsync.value!.isAnonymous && !isGuest;
    final isAvailable = sapling.isAvailable;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero image / color block.
          SizedBox(
            height: 240,
            child: ColoredBox(
              color: accentColor,
              child: sapling.photoUrl != null
                  ? Image.network(
                      sapling.photoUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Center(
                              child: CircularProgressIndicator(
                                color: cs.onPrimary,
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.park, size: 80, color: cs.onPrimary),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.park, size: 80, color: cs.onPrimary),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sapling.nickname, style: tt.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  '${sapling.species} (${sapling.latin})',
                  style: tt.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(sapling.personality, style: tt.bodyMedium),
                const SizedBox(height: 24),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: '${sapling.street}, ${sapling.neighborhood}',
                ),
                _DetailRow(
                  icon: Icons.height_outlined,
                  label: sapling.heightLabel,
                ),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: sapling.ageLabel,
                ),
                _DetailRow(
                  icon: Icons.water_drop_outlined,
                  label: sapling.waterNeedLabel,
                ),
                _DetailRow(
                  icon: Icons.wb_sunny_outlined,
                  label: sapling.lightLabel,
                ),
                const SizedBox(height: 32),
                if (isAvailable)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: queueState.isAdopting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.favorite_outline),
                      label: const Text('Adopt this tree'),
                      onPressed: queueState.isAdopting
                          ? null
                          : () async {
                              if (!isAuthenticated) {
                                context.push(
                                  '/welcome?redirect=/sapling/${sapling.id}',
                                );
                                return;
                              }
                              final uid = authAsync.value!.id;
                              await ref
                                  .read(discoverQueueProvider.notifier)
                                  .adopt(saplingId: sapling.id, uid: uid);
                              if (context.mounted &&
                                  ref.read(discoverQueueProvider).adoptError ==
                                      null) {
                                await AdoptConfirmationSheet.show(
                                  context,
                                  sapling,
                                );
                                // Pop back to the caller (e.g. DiscoverScreen)
                                // with true so it can switch to the map view.
                                if (context.mounted) context.pop(true);
                              }
                            },
                    ),
                  )
                else
                  Chip(
                    avatar: const Icon(Icons.check_circle_outline, size: 16),
                    label: Text('Already adopted', style: tt.labelMedium),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.onSurface),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: tt.bodyMedium)),
        ],
      ),
    );
  }
}
