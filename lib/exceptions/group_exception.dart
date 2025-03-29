import 'package:mobile_project/exceptions/app_exception.dart';

class GroupException extends AppException {
  static const String createGroupException = "createGroupException";
  GroupException(super.message, super.code);
}
