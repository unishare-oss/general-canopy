class Discovery {
  const Discovery({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.lat,
    required this.lng,
    required this.neighborhood,
    required this.colorHex,
    required this.createdAt,
    required this.createdBy,
    this.photoUrl,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final double lat;
  final double lng;
  final String neighborhood;
  final String colorHex;
  final DateTime createdAt;
  final String createdBy;
  final String? photoUrl;
}
