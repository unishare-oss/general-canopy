import 'package:canopy/features/grove/domain/entities/adopted_sapling.dart';
import 'package:canopy/features/grove/domain/entities/care_event.dart';
import 'package:canopy/features/grove/domain/entities/sapling_photo.dart';

abstract interface class GroveRepository {
  Stream<List<AdoptedSapling>> watchMyGrove(String uid);

  Future<AdoptedSapling> getAdoptionDetail({
    required String uid,
    required String adoptionId,
  });

  Stream<List<SaplingPhoto>> watchAdoptionPhotos({
    required String uid,
    required String adoptionId,
  });

  Future<List<CareEvent>> getCareHistory({
    required String uid,
    required String adoptionId,
  });
}
