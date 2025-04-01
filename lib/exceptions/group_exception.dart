import 'package:mobile_project/exceptions/app_exception.dart';

class GroupException extends AppException {
  static const String createGroupException = "create-group-error";
  static const String getUserGroupsException = "get-user-groups-error";
  static const String getGroupException = "get-group-error";
  static const String updateGroupException = "update-group-error";
  static const String addUserToGroupException = "add-user-to-group-error";
  static const String removeUserFromGroupException =
      "remove-user-from-group-error";
  static const String deleteGroupException = "delete-group-error";
  static const String removeOwnerException = "remove-owner-error";
  static const String getGroupMembersException = "get-group-members-error";
  static const String unauthorizedDeleteException = "unauthorized-access-error";

  static const String unauthorizedUpdateException = "unauthorized-update-error";
  GroupException(super.message, super.code);
}
