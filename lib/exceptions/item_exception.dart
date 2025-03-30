import 'package:mobile_project/exceptions/app_exception.dart';

/// Exception codes for item operations
class ItemException extends AppException {
  static const String getItemException = 'get-item-error';
  static const String createItemException = 'create-item-error';
  static const String createItemFromPresetException =
      'create-item-from-preset-error';
  static const String updateItemException = 'update-item-error';
  static const String deleteItemException = 'delete-item-error';
  static const String getExpiringItemsException = 'get-expiring-items-error';
  static const String presetNotFoundException = 'preset-not-found';

  ItemException(super.message, super.code);
}
