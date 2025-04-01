import 'package:flutter/material.dart';
import 'package:mobile_project/models/item_model.dart';
import 'package:mobile_project/pages/item-list/dialog/item_add_dialog.dart';
import 'package:mobile_project/pages/item-list/dialog/item_tab_dialog.dart';

/// Factory class to show the appropriate item dialog based on the use case
class ItemDialogFactory {
  /// Show the appropriate dialog for adding or editing an item
  static Future<void> showItemDialog(
    BuildContext context, {
    required String refrigeratorId,
    Item? itemToEdit,
    bool useTabbedDialog = true, // Control whether to use the new tabbed dialog
  }) async {
    if (itemToEdit != null || !useTabbedDialog) {
      // When editing or when specifically requesting the simple dialog
      await showDialog(
        context: context,
        builder: (context) => AddItemDialog(
          refrigeratorId: refrigeratorId,
          itemToEdit: itemToEdit,
        ),
      );
    } else {
      // For adding a new item with the tabbed interface
      await showDialog(
        context: context,
        builder: (context) => ItemTabbedDialog(
          refrigeratorId: refrigeratorId,
        ),
      );
    }
  }
}
