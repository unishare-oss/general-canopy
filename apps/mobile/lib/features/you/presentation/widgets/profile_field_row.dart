import 'package:flutter/material.dart';

import 'package:canopy/shared/theme/app_colors.dart';

/// A tappable label/value row used for editable profile fields.
/// Renders "Not set" in a muted color when [value] is null.
class ProfileFieldRow extends StatelessWidget {
  const ProfileFieldRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: tt.bodyLarge),
      subtitle: Text(
        value ?? 'Not set',
        style: tt.bodyMedium?.copyWith(
          color: value != null ? cs.onSurfaceVariant : ac.textSecondary,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
  }
}
