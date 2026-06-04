import 'package:flutter/material.dart';

import 'package:canopy/shared/theme/app_colors.dart';

/// A settings-list row matching the Canopy design mock: label on the left,
/// muted value and chevron on the right. Renders "Not set" when [value] is
/// null.
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
    final ac = Theme.of(context).extension<AppColors>()!;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: tt.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value ?? 'Not set',
            style: tt.bodySmall?.copyWith(
              color: value != null ? ac.textSecondary : ac.muted,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 18, color: ac.muted),
        ],
      ),
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
  }
}
