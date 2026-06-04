import 'package:canopy/features/admin/domain/repositories/admin_repository.dart';

class CheckAdminStatus {
  const CheckAdminStatus(this._repository);

  final AdminRepository _repository;

  Future<bool> call(String uid) => _repository.checkAdminStatus(uid);
}
