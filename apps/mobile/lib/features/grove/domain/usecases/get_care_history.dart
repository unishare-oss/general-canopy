import 'package:canopy/features/grove/domain/entities/care_event.dart';
import 'package:canopy/features/grove/domain/repositories/grove_repository.dart';

class GetCareHistory {
  const GetCareHistory(this._repository);
  final GroveRepository _repository;

  Future<List<CareEvent>> call({
    required String uid,
    required String adoptionId,
  }) => _repository.getCareHistory(uid: uid, adoptionId: adoptionId);
}
