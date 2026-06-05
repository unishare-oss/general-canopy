class SaplingPhoto {
  const SaplingPhoto({
    required this.id,
    required this.url,
    required this.takenAt,
    this.note,
  });

  final String id;
  final String url;
  final DateTime takenAt;
  final String? note;
}
