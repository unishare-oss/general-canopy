enum HealthStatus { excellent, good, attention, critical }

enum NextActionType { water, fertilize, prune, inspect }

class AdoptedSapling {
  const AdoptedSapling({
    required this.id,
    required this.saplingId,
    required this.nickname,
    required this.species,
    required this.street,
    required this.neighborhood,
    required this.colorHex,
    required this.adoptedAt,
    required this.healthScore,
    required this.nextActionAt,
    required this.nextActionType,
    this.photoUrl,
    this.coverPhotoUrl,
  });

  final String id;
  final String saplingId;
  final String nickname;
  final String species;
  final String street;
  final String neighborhood;
  final String colorHex;
  final DateTime adoptedAt;
  final int healthScore;
  final DateTime nextActionAt;
  final NextActionType nextActionType;
  final String? photoUrl;
  final String? coverPhotoUrl;

  HealthStatus get healthStatus {
    if (healthScore >= 90) return HealthStatus.excellent;
    if (healthScore >= 70) return HealthStatus.good;
    if (healthScore >= 50) return HealthStatus.attention;
    return HealthStatus.critical;
  }

  bool get isOverdue => nextActionAt.isBefore(DateTime.now());

  bool get isDueToday {
    if (isOverdue) return false;
    return nextActionAt.difference(DateTime.now()).inDays == 0;
  }
}
