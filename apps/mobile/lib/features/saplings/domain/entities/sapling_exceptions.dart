class SaplingNotFoundException implements Exception {
  const SaplingNotFoundException(this.id);
  final String id;
}

class SaplingAlreadyAdoptedException implements Exception {
  const SaplingAlreadyAdoptedException();
}
