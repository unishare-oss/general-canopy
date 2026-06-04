import 'package:canopy/features/admin/domain/repositories/admin_repository.dart';

class GrantAdmin {
  const GrantAdmin(this._repository);

  final AdminRepository _repository;

  Future<void> call(String targetUid) => _repository.grantAdmin(targetUid);
}
