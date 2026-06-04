import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:canopy/features/saplings/domain/entities/sapling.dart';
import 'package:canopy/features/saplings/domain/entities/sapling_exceptions.dart';
import 'package:canopy/features/saplings/domain/usecases/watch_sapling_by_id.dart';
import 'package:canopy/features/saplings/domain/usecases/unadopt_sapling.dart';
import 'package:canopy/features/saplings/presentation/providers/sapling_repository_provider.dart';
import 'package:canopy/features/saplings/presentation/providers/discover_queue_provider.dart';
import 'package:canopy/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:canopy/features/auth/presentation/providers/guest_mode_provider.dart';
import 'package:canopy/features/discover/presentation/widgets/adopt_confirm_sheet.dart';
import 'package:canopy/features/discover/presentation/widgets/adopt_confirmation_sheet.dart';

// Live Firestore stream so the detail screen reflects adoption changes instantly.
final _saplingByIdProvider = StreamProvider.family<Sapling, String>(
  (ref, id) => WatchSaplingById(ref.watch(saplingRepositoryProvider))(id),
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

class _SaplingDetailBody extends ConsumerStatefulWidget {
  const _SaplingDetailBody({required this.sapling});

  final Sapling sapling;

  @override
  ConsumerState<_SaplingDetailBody> createState() => _SaplingDetailBodyState();
}

class _SaplingDetailBodyState extends ConsumerState<_SaplingDetailBody> {
  bool _isUnadopting = false;

  Future<void> _handleUnadopt(String uid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Release this tree?'),
        content: Text(
          '${widget.sapling.nickname} will be available for someone else to adopt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Release'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isUnadopting = true);
    try {
      await UnadoptSapling(ref.read(saplingRepositoryProvider))(
        saplingId: widget.sapling.id,
        uid: uid,
      );
      if (mounted) context.pop();
    } on SaplingNotAdoptedByUserException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not release — you may not be the adopter.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Release failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUnadopting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sapling = widget.sapling;
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
    final currentUid = authAsync.value?.id;
    final isOwner = currentUid != null && sapling.adoptedBy == currentUid;

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
                      errorBuilder: (_, _, _) => Center(
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
                              final confirmed = await AdoptConfirmSheet.show(
                                context,
                                sapling,
                              );
                              if (!confirmed || !context.mounted) return;
                              final user = authAsync.value!;
                              await ref
                                  .read(discoverQueueProvider.notifier)
                                  .adopt(
                                    saplingId: sapling.id,
                                    uid: user.id,
                                    displayName: user.name,
                                    photoUrl: user.photoUrl,
                                  );
                              if (context.mounted &&
                                  ref.read(discoverQueueProvider).adoptError ==
                                      null) {
                                await AdoptConfirmationSheet.show(
                                  context,
                                  sapling,
                                );
                                if (context.mounted) context.pop(true);
                              }
                            },
                    ),
                  )
                else ...[
                  Chip(
                    avatar: Icon(
                      isOwner ? Icons.favorite : Icons.check_circle_outline,
                      size: 16,
                    ),
                    label: Text(
                      isOwner
                          ? 'Already adopted by you'
                          : sapling.adoptedByName != null
                          ? 'Adopted by ${sapling.adoptedByName}'
                          : 'Already adopted',
                      style: tt.labelMedium,
                    ),
                  ),
                  if (isOwner) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: _isUnadopting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.undo),
                        label: const Text('Release this tree'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.error,
                          side: BorderSide(color: cs.error),
                        ),
                        onPressed: _isUnadopting
                            ? null
                            : () => _handleUnadopt(currentUid),
                      ),
                    ),
                  ],
                ],
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
