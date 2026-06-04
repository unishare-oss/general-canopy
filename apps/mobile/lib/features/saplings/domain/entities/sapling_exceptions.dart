class SaplingNotFoundException implements Exception {
  const SaplingNotFoundException(this.id);
  final String id;
}

class SaplingAlreadyAdoptedException implements Exception {
  const SaplingAlreadyAdoptedException();
}

class SaplingNotAdoptedByUserException implements Exception {
  const SaplingNotAdoptedByUserException();
}
