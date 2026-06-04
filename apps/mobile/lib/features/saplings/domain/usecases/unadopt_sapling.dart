import 'package:canopy/features/saplings/domain/repositories/sapling_repository.dart';

class UnadoptSapling {
  const UnadoptSapling(this._repository);
  final SaplingRepository _repository;
  Future<void> call({required String saplingId, required String uid}) =>
      _repository.unadoptSapling(saplingId: saplingId, uid: uid);
}
