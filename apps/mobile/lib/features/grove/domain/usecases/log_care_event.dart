import 'package:canopy/features/grove/domain/entities/care_event.dart';
import 'package:canopy/features/grove/domain/repositories/grove_repository.dart';

class LogCareEvent {
  const LogCareEvent(this._repository);
  final GroveRepository _repository;

  Future<void> call({
    required String uid,
    required String adoptionId,
    required String saplingId,
    required CareEventType type,
    double waterLiters = 2.0,
  }) => _repository.logCareEvent(
    uid: uid,
    adoptionId: adoptionId,
    saplingId: saplingId,
    type: type,
    waterLiters: waterLiters,
  );
}
