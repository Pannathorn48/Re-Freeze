import 'package:mobile_project/exceptions/app_exception.dart';

class TagException extends AppException{
  static const String getTagException = "get-tag-error";
  static const String createTagException = "create-tag-error";
  static const String updateTagException = "update-tag-error";
  static const String deleteTagException = "delete-tag-error";

  TagException(super.message, super.code);
}

