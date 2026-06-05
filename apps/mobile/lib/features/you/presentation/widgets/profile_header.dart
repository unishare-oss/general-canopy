import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/shared/theme/app_colors.dart';

/// Profile card matching the Canopy design mock: avatar (uploaded photo,
/// OAuth photo, or initials fallback) on the left, serif display name and
/// muted caption beside it. When [onEditAvatar] is set, the avatar shows a
/// camera badge and is tappable.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user, this.onEditAvatar});

  final AppUser user;
  final VoidCallback? onEditAvatar;

  String get _initials {
    final parts = user.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2);
    if (parts.isEmpty) return '?';
    return parts.map((p) => p[0].toUpperCase()).join();
  }

  /// Uploaded avatar wins over the OAuth photo URL.
  ImageProvider? get _avatarImage {
    final encoded = user.avatarBase64;
    if (encoded != null) {
      try {
        return MemoryImage(base64Decode(encoded));
      } on FormatException {
        // Corrupt data — fall through to photoUrl/initials.
      }
    }
    final photoUrl = user.photoUrl;
    if (photoUrl != null) return NetworkImage(photoUrl);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final ac = Theme.of(context).extension<AppColors>()!;
    final caption = user.neighborhood != null
        ? '${user.neighborhood} · ${user.email}'
        : user.email;

    final avatar = Stack(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: cs.primary,
          foregroundImage: _avatarImage,
          child: Text(
            _initials,
            style: tt.titleLarge?.copyWith(color: cs.onPrimary),
          ),
        ),
        if (onEditAvatar != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 2),
              ),
              child: Icon(
                Icons.photo_camera,
                size: 14,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
      ],
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(onTap: onEditAvatar, child: avatar),
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
