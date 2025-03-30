import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/item_api.dart';
import 'package:mobile_project/components/custom_bottom_sheet.dart';
import 'package:mobile_project/components/custom_bottom_sheet_input.dart';
import 'package:mobile_project/models/item_model.dart';
import 'package:mobile_project/pages/item-list/dialog/item_add_dialog.dart';

class EditBottomSheet extends StatelessWidget {
  final String title;
  final Item? item; // Pass the item for edit/delete operations

  const EditBottomSheet({
    Key? key,
    required this.title,
    this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ItemApi itemApi = ItemApi();

    return CustomBottomSheet(
      title: title,
      titleColor: Theme.of(context).colorScheme.primary,
      children: [
        CustomBottomSheetInput(
          icon: Icon(
            Icons.edit,
            size: 25,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            Navigator.pop(context);
            if (item != null) {
              // Show edit dialog with pre-filled data
              showDialog(
                context: context,
                builder: (context) {
                  return AddItemDialog(
                    refrigeratorId: item!.refrigeratorId, // Pass refrigeratorId
                    itemToEdit: item, // Pass the item to edit
                  );
                },
              );
            }
          },
          text: "แก้ไข",
          textColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(
          height: 20,
        ),
        CustomBottomSheetInput(
            onPressed: () async {
              Navigator.pop(context);
              if (item != null) {
                // Show confirmation dialog
                bool confirmDelete = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'ยืนยันการลบ',
                      style: GoogleFonts.notoSansThai(),
                    ),
                    content: Text(
                      'คุณต้องการลบ ${item!.name} ใช่หรือไม่?',
                      style: GoogleFonts.notoSansThai(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'ยกเลิก',
                          style: GoogleFonts.notoSansThai(),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'ลบ',
                          style: GoogleFonts.notoSansThai(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                // Delete the item if confirmed
                if (confirmDelete == true) {
                  try {
                    await itemApi.deleteItem(item!.uid);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ลบรายการเรียบร้อยแล้ว')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('เกิดข้อผิดพลาดในการลบ: $e')),
                    );
                  }
                }
              }
            },
            text: "ลบ",
            icon: const Icon(Icons.delete, size: 25, color: Colors.red),
            textColor: Colors.red),
      ],
    );
  }
}
