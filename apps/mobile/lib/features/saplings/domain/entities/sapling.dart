/// A real, geo-tagged sapling available for or under adoption.
/// Pure Dart — no Flutter or Firebase imports.
class Sapling {
  const Sapling({
    required this.id,
    required this.nickname,
    required this.species,
    required this.latin,
    required this.personality,
    required this.street,
    required this.neighborhood,
    required this.lat,
    required this.lng,
    required this.ageLabel,
    required this.heightLabel,
    required this.waterNeedLabel,
    required this.lightLabel,
    required this.wateringIntervalDays,
    required this.colorHex,
    required this.status,
    this.photoUrl,
    this.adoptedBy,
    this.adoptedByName,
    this.adoptedByPhotoUrl,
  });

  final String id;
  final String nickname;
  final String species;
  final String latin;
  final String personality;
  final String street;
  final String neighborhood;
  final double lat;
  final double lng;
  final String ageLabel;
  final String heightLabel;
  final String waterNeedLabel;
  final String lightLabel;
  final int wateringIntervalDays;
  final String colorHex;
  final SaplingStatus status;
  final String? photoUrl;
  final String? adoptedBy;
  final String? adoptedByName;
  final String? adoptedByPhotoUrl;

  bool get isAvailable => status == SaplingStatus.available;
}

enum SaplingStatus { available, adopted }
