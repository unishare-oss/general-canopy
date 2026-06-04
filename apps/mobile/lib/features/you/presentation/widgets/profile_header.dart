import 'package:flutter/material.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/shared/theme/app_colors.dart';

/// Profile card matching the Canopy design mock: avatar (photo or initials
/// fallback) on the left, serif display name and muted caption beside it.
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
    final caption = user.neighborhood != null
        ? '${user.neighborhood} · ${user.email}'
        : user.email;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: cs.primary,
              foregroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: Text(
                _initials,
                style: tt.titleLarge?.copyWith(color: cs.onPrimary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: tt.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    style: tt.bodySmall?.copyWith(color: ac.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
