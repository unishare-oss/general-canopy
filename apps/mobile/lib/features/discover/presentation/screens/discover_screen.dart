import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:canopy/features/saplings/presentation/providers/available_saplings_provider.dart';
import 'package:canopy/features/saplings/presentation/providers/discover_queue_provider.dart';
import 'package:canopy/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:canopy/features/auth/presentation/providers/guest_mode_provider.dart';
import 'package:canopy/features/discover/presentation/widgets/sapling_card_stack.dart';
import 'package:canopy/features/discover/presentation/widgets/adopt_confirmation_sheet.dart';
import 'package:canopy/features/map/presentation/screens/map_screen.dart';

enum DiscoverView { cards, map }

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  DiscoverView _view = DiscoverView.cards;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // Listen for errors and show snackbar.
    ref.listen(discoverQueueProvider.select((s) => s.adoptError), (prev, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: ref.read(discoverQueueProvider.notifier).dismissError,
            ),
          ),
        );
      }
    });

    // Sync Firestore stream into the queue.
    ref.listen(availableSaplingsProvider, (prev, next) {
      next.whenData((saplings) {
        ref.read(discoverQueueProvider.notifier).initialize(saplings);
      });
    });

    final queueState = ref.watch(discoverQueueProvider);
    final authAsync = ref.watch(authStateProvider);
    final isGuest = ref.watch(guestModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Discover', style: tt.titleLarge),
        actions: [
          IconButton(
            icon: Icon(
              _view == DiscoverView.cards
                  ? Icons.map_outlined
                  : Icons.view_carousel_outlined,
            ),
            onPressed: () => setState(() {
              _view = _view == DiscoverView.cards
                  ? DiscoverView.map
                  : DiscoverView.cards;
            }),
          ),
        ],
      ),
      body: _view == DiscoverView.cards
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SaplingCardStack(
                  saplings: queueState.queue,
                  isDisabled: queueState.isAdopting,
                  onTap: (sapling) => context.push('/sapling/${sapling.id}'),
                  onSwipeLeft: (sapling) =>
                      ref.read(discoverQueueProvider.notifier).pass(sapling.id),
                  onSwipeRight: (sapling) async {
                    final user = authAsync.value;
                    if (user == null || isGuest || user.isAnonymous) {
                      context.push('/welcome?redirect=/sapling/${sapling.id}');
                      return;
                    }
                    await ref
                        .read(discoverQueueProvider.notifier)
                        .adopt(saplingId: sapling.id, uid: user.id);
                    if (context.mounted &&
                        ref.read(discoverQueueProvider).adoptError == null) {
                      await AdoptConfirmationSheet.show(context, sapling);
                    }
                  },
                ),
              ),
            )
          : const MapScreen(),
    );
  }
}
