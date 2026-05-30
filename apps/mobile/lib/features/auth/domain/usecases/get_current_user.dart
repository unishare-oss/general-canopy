import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  Future<AppUser?> call() => _repository.getCurrentUser();
}
