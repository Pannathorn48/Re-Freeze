class UserException implements Exception {
  final String message;
  final String code;

  UserException(this.message, this.code);

  @override
  String toString() {
    return message;
  }
}
