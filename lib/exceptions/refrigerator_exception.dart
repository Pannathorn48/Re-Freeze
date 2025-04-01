import 'package:mobile_project/exceptions/app_exception.dart';

import 'package:mobile_project/exceptions/app_exception.dart';

class RefrigeratorException extends AppException {
  static const String getRefrigeratorException = "get-refrigerator-error";
  static const String getFavoriteRefrigeratorsException =
      "get-favorite-refrigerators-error";
  static const String createRefrigeratorException = "create-refrigerator-error";
  static const String deleteRefrigeratorException = "delete-refrigerator-error";
  static const String updateRefrigeratorException = "update-refrigerator-error";
  static const String addToFavoritesException = "add-to-favorites-error";
  static const String removeFromFavoritesException =
      "remove-from-favorites-error";
  static const String unauthorizedAccessException = "unauthorized-access-error";

  RefrigeratorException(super.message, super.code);
}
