import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/domain/entities/check_in_frequency.dart';
import 'package:canopy/features/auth/domain/entities/plant_experience.dart';
import 'package:canopy/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:canopy/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:canopy/features/auth/presentation/providers/current_user_provider.dart';
import 'package:canopy/features/auth/presentation/providers/guest_mode_provider.dart';
import 'package:canopy/features/you/presentation/providers/you_profile_provider.dart';
import 'package:canopy/features/you/presentation/widgets/edit_name_sheet.dart';
import 'package:canopy/features/you/presentation/widgets/guest_profile_prompt.dart';
import 'package:canopy/features/you/presentation/widgets/profile_field_row.dart';
import 'package:canopy/features/you/presentation/widgets/profile_header.dart';
import 'package:canopy/features/you/presentation/widgets/select_option_sheet.dart';
import 'package:canopy/shared/constants/neighborhoods.dart';
import 'package:canopy/shared/theme/app_colors.dart';
import 'package:canopy/shared/widgets/confirm_sign_out_dialog.dart';

class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final authAsync = ref.watch(authStateProvider);
    final isGuest = ref.watch(guestModeProvider);

    ref.listen(youProfileControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null && error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      // Serif display title per the Canopy design mock.
      appBar: AppBar(title: Text('You', style: tt.headlineMedium)),
      body: SafeArea(
        child: authAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const _ErrorMessage(),
          data: (user) {
            if (user == null || user.isAnonymous || isGuest) {
              return const GuestProfilePrompt();
            }
            return _ProfileBody(authUser: user);
          },
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage();

  @override
  Widget build(BuildContext context) {
    final ac = Theme.of(context).extension<AppColors>()!;
    return Center(
      child: Text(
        'Something went wrong. Please try again.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: ac.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.authUser});

  final AppUser authUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAsync = ref.watch(currentUserProvider);

    return currentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const _ErrorMessage(),
      data: (profile) => _ProfileContent(user: profile ?? authUser),
    );
  }
}

const _frequencySubtitles = {
  CheckInFrequency.mostDays: 'I walk past it constantly',
  CheckInFrequency.onceAWeek: 'I can swing by weekends',
  CheckInFrequency.twiceAMonth: 'Light-touch guardian',
};

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.user});

  final AppUser user;

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final name = await EditNameSheet.show(context, initialName: user.name);
    if (name != null && name != user.name) {
      await ref
          .read(youProfileControllerProvider.notifier)
          .updateName(user.id, name);
    }
  }

  Future<void> _editNeighborhood(BuildContext context, WidgetRef ref) async {
    final neighborhood = await SelectOptionSheet.show<String>(
      context,
      title: 'Home neighborhood',
      selected: user.neighborhood,
      options: [
        for (final n in kNeighborhoods) SelectOption(value: n, label: n),
      ],
    );
    if (neighborhood != null && neighborhood != user.neighborhood) {
      await ref
          .read(youProfileControllerProvider.notifier)
          .updateNeighborhood(user.id, neighborhood);
    }
  }

  Future<void> _editFrequency(BuildContext context, WidgetRef ref) async {
    final frequency = await SelectOptionSheet.show<CheckInFrequency>(
      context,
      title: 'How often can you visit?',
      selected: user.checkInFrequency,
      options: [
        for (final f in CheckInFrequency.values)
          SelectOption(
            value: f,
            label: f.label,
            subtitle: _frequencySubtitles[f],
          ),
      ],
    );
    if (frequency != null && frequency != user.checkInFrequency) {
      await ref
          .read(youProfileControllerProvider.notifier)
          .updateFrequency(user.id, frequency);
    }
  }

  Future<void> _editExperience(BuildContext context, WidgetRef ref) async {
    final experience = await SelectOptionSheet.show<PlantExperience>(
      context,
      title: 'Your plant experience',
      selected: user.plantExperience,
      options: [
        for (final e in PlantExperience.values)
          SelectOption(value: e, label: e.label),
      ],
    );
    if (experience != null && experience != user.plantExperience) {
      await ref
          .read(youProfileControllerProvider.notifier)
          .updateExperience(user.id, experience);
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmSignOut(context);
    if (confirmed) {
      await ref.read(signOutUseCaseProvider).call();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final editState = ref.watch(youProfileControllerProvider);
    final isSaving = editState.isSaving;
    final prefs = user.notificationPreferences;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        ProfileHeader(user: user),
        const _SectionHeader('Preferences'),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ProfileFieldRow(
                label: 'Name',
                value: user.name,
                enabled: !isSaving,
                onTap: () => _editName(context, ref),
              ),
              const Divider(height: 1),
              ProfileFieldRow(
                label: 'Home neighborhood',
                value: user.neighborhood,
                enabled: !isSaving,
                onTap: () => _editNeighborhood(context, ref),
              ),
              const Divider(height: 1),
              ProfileFieldRow(
                label: 'Check-in frequency',
                value: user.checkInFrequency?.label,
                enabled: !isSaving,
                onTap: () => _editFrequency(context, ref),
              ),
              const Divider(height: 1),
              ProfileFieldRow(
                label: 'Plant experience',
                value: user.plantExperience?.label,
                enabled: !isSaving,
                onTap: () => _editExperience(context, ref),
              ),
            ],
          ),
        ),
        const _SectionHeader('Notifications'),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text('Watering reminders', style: tt.bodyLarge),
                value: prefs.wateringReminders,
                onChanged: isSaving
                    ? null
                    : (value) => ref
                          .read(youProfileControllerProvider.notifier)
                          .updateNotifications(
                            user.id,
                            prefs.copyWith(wateringReminders: value),
                          ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text('City alerts', style: tt.bodyLarge),
                value: prefs.cityAlerts,
                onChanged: isSaving
                    ? null
                    : (value) => ref
                          .read(youProfileControllerProvider.notifier)
                          .updateNotifications(
                            user.id,
                            prefs.copyWith(cityAlerts: value),
                          ),
              ),
            ],
          ),
        ),
        const _SectionHeader('Account'),
        Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(Icons.logout, size: 20, color: cs.error),
            title: Text(
              'Sign out',
              style: tt.bodyLarge?.copyWith(color: cs.error),
            ),
            enabled: !isSaving,
            onTap: () => _signOut(context, ref),
          ),
        ),
      ],
    );
  }
}

/// Uppercase micro section header per the Canopy design mock.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ac = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: tt.labelSmall?.copyWith(
          color: ac.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
