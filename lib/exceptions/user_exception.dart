import 'package:mobile_project/exceptions/app_exception.dart';

class UserException extends AppException {
  static const String getUserException = "get-user-error";
  static const String updateDisplayNameException = "update-display-name-error";
  static const String imageFetchException = "image-fetch-error";
  static const String updateProfilePictureException =
      "update-profile-picture-error";

  UserException(super.message, super.code);
}
