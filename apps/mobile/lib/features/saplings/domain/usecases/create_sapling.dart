import 'package:canopy/features/saplings/domain/repositories/sapling_repository.dart';

class CreateSapling {
  const CreateSapling(this._repository);
  final SaplingRepository _repository;

  Future<String> call({
    required String nickname,
    required String species,
    required String latin,
    required String personality,
    required String street,
    required String neighborhood,
    required double lat,
    required double lng,
    required String colorHex,
    String? photoUrl,
  }) => _repository.createSapling(
    nickname: nickname,
    species: species,
    latin: latin,
    personality: personality,
    street: street,
    neighborhood: neighborhood,
    lat: lat,
    lng: lng,
    colorHex: colorHex,
    photoUrl: photoUrl,
  );
}
