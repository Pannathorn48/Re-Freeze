import 'package:flutter/material.dart';
import 'package:mobile_project/components/custom_bottom_sheet.dart';
import 'package:mobile_project/components/custom_bottom_sheet_input.dart';

class EditBottomSheet extends StatelessWidget {
  final String title;
  const EditBottomSheet({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
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
          onPressed: () {},
          text: "แก้ไข",
          textColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(
          height: 20,
        ),
        CustomBottomSheetInput(
            onPressed: () {},
            text: "ลบ",
            icon: const Icon(Icons.delete, size: 25, color: Colors.red),
            textColor: Colors.red),
      ],
    );
  }
}
