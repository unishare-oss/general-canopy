import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:canopy/features/admin/presentation/providers/is_admin_provider.dart';
import 'package:canopy/features/discoveries/domain/entities/discovery.dart';
import 'package:canopy/features/discoveries/domain/usecases/delete_discovery.dart';
import 'package:canopy/features/discoveries/presentation/providers/discovery_repository_provider.dart';
import 'package:canopy/features/discoveries/presentation/providers/watch_all_discoveries_provider.dart';

class DiscoveryDetailScreen extends ConsumerWidget {
  const DiscoveryDetailScreen({super.key, required this.discoveryId});

  final String discoveryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoveriesAsync = ref.watch(watchAllDiscoveriesProvider);
    final isAdminAsync = ref.watch(isAdminProvider);

    return discoveriesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Could not load discovery.')),
      ),
      data: (discoveries) {
        final discovery = discoveries.cast<Discovery?>().firstWhere(
          (d) => d?.id == discoveryId,
          orElse: () => null,
        );

        if (discovery == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Discovery not found.')),
          );
        }

        final isAdmin = isAdminAsync.value ?? false;

        return _DiscoveryDetailView(
          discovery: discovery,
          isAdmin: isAdmin,
          onEdit: () =>
              context.push('/discovery/$discoveryId/edit', extra: discovery),
          onDelete: () => _confirmDelete(context, ref, discovery),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Discovery discovery,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete discovery'),
        content: Text(
          'Are you sure you want to delete "${discovery.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await DeleteDiscovery(ref.read(discoveryRepositoryProvider))(
        discovery.id,
      );
      if (context.mounted) {
        context.canPop() ? context.pop() : context.go('/map');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }
}

class _DiscoveryDetailView extends StatelessWidget {
  const _DiscoveryDetailView({
    required this.discovery,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  final Discovery discovery;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/map'),
        ),
        title: Text(discovery.title),
        actions: [
          if (isAdmin)
            PopupMenuButton<_AdminAction>(
              onSelected: (action) {
                switch (action) {
                  case _AdminAction.edit:
                    onEdit();
                  case _AdminAction.delete:
                    onDelete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: _AdminAction.edit,
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: _AdminAction.delete,
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (discovery.photoUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                discovery.photoUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 220,
                  color: cs.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image,
                    size: 48,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : SizedBox(
                        height: 220,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CategoryChip(category: discovery.category),
              _NeighborhoodChip(neighborhood: discovery.neighborhood),
            ],
          ),
          const SizedBox(height: 16),
          Text(discovery.title, style: tt.headlineSmall),
          const SizedBox(height: 8),
          Text(discovery.description, style: tt.bodyMedium),
          const SizedBox(height: 16),
          _ColorSwatch(colorHex: discovery.colorHex),
          const SizedBox(height: 16),
          Text(
            'Added ${_formatDate(discovery.createdAt)}',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

enum _AdminAction { edit, delete }

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Chip(
      label: Text(category),
      backgroundColor: cs.primaryContainer,
      labelStyle: TextStyle(color: cs.onPrimaryContainer),
      side: BorderSide.none,
    );
  }
}

class _NeighborhoodChip extends StatelessWidget {
  const _NeighborhoodChip({required this.neighborhood});

  final String neighborhood;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(Icons.location_on, size: 16, color: cs.onSecondaryContainer),
      label: Text(neighborhood),
      backgroundColor: cs.secondaryContainer,
      labelStyle: TextStyle(color: cs.onSecondaryContainer),
      side: BorderSide.none,
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.colorHex});

  final String colorHex;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = Color(int.parse('0xFF${colorHex.replaceFirst('#', '')}'));
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('#$colorHex', style: tt.bodySmall),
      ],
    );
  }
}
