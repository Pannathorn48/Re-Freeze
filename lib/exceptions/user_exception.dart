class UserException implements Exception {
  static const String getUserException = "get-user-error";
  static const String updateDisplayNameException = "update-display-name-error";
  static const String imageFetchException = "image-fetch-error";
  static const String updateProfilePictureException =
      "update-profile-picture-error";

  /// A custom exception class for handling user-related errors.
  final String message;
  final String code;

  UserException(this.message, this.code);

  @override
  String toString() {
    return message;
  }
}
