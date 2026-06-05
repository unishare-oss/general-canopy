import 'package:canopy/features/grove/domain/entities/adopted_sapling.dart';
import 'package:canopy/features/grove/domain/repositories/grove_repository.dart';

class GetAdoptionDetail {
  const GetAdoptionDetail(this._repository);
  final GroveRepository _repository;

  Future<AdoptedSapling> call({
    required String uid,
    required String adoptionId,
  }) => _repository.getAdoptionDetail(uid: uid, adoptionId: adoptionId);
}
