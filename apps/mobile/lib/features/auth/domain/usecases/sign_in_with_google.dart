import 'package:canopy/features/auth/domain/entities/app_user.dart';
import 'package:canopy/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call() => _repository.signInWithGoogle();
}
