import 'package:canopy/features/grove/domain/entities/sapling_photo.dart';
import 'package:canopy/features/grove/domain/repositories/grove_repository.dart';

class WatchAdoptionPhotos {
  const WatchAdoptionPhotos(this._repository);
  final GroveRepository _repository;

  Stream<List<SaplingPhoto>> call({
    required String uid,
    required String adoptionId,
  }) => _repository.watchAdoptionPhotos(uid: uid, adoptionId: adoptionId);
}
