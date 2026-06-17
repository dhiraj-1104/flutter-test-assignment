class UnableToFetchUser implements Exception {
  final String msg;

  UnableToFetchUser({required this.msg});

  @override
  String toString() {
    return msg;
  }
}
