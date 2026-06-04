import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:canopy/features/admin/domain/usecases/check_admin_status.dart';
import 'package:canopy/features/admin/presentation/providers/admin_repository_provider.dart';
import 'package:canopy/features/auth/presentation/providers/auth_state_provider.dart';

part 'is_admin_provider.g.dart';

@riverpod
Future<bool> isAdmin(Ref ref) async {
  final uid = ref.watch(authStateProvider).value?.id;
  if (uid == null) return false;
  return CheckAdminStatus(ref.watch(adminRepositoryProvider))(uid);
}
