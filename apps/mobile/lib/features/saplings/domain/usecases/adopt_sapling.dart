import 'package:canopy/features/saplings/domain/repositories/sapling_repository.dart';

class AdoptSapling {
  const AdoptSapling(this._repository);
  final SaplingRepository _repository;
  Future<void> call({
    required String saplingId,
    required String uid,
    required String displayName,
    String? photoUrl,
  }) => _repository.adoptSapling(
    saplingId: saplingId,
    uid: uid,
    displayName: displayName,
    photoUrl: photoUrl,
  );
}
