import 'package:flutter/material.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/shared/theme/app_colors.dart';

/// Read-only profile header: avatar (photo or initials fallback),
/// display name, and email.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final AppUser user;

  String get _initials {
    final parts = user.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2);
    if (parts.isEmpty) return '?';
    return parts.map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppColors>()!;
    final photoUrl = user.photoUrl;

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: cs.primaryContainer,
          foregroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: Text(
            _initials,
            style: tt.headlineSmall?.copyWith(color: cs.onPrimaryContainer),
          ),
        ),
        const SizedBox(height: 12),
        Text(user.name, style: tt.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(
          user.email,
          style: tt.bodyMedium?.copyWith(color: ac.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
