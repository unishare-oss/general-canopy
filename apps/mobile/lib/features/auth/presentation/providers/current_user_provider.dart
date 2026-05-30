import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/presentation/providers/auth_repository_provider.dart';

part 'current_user_provider.g.dart';

@riverpod
Future<AppUser?> currentUser(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
}
