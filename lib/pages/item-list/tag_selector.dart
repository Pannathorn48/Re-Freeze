import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/custom_dropdown_menu.dart';
import 'package:mobile_project/models/dropdownable_model.dart';
import 'package:mobile_project/models/item_model.dart';

class TagSelector extends StatelessWidget {
  final TextEditingController controller;
  final void Function(Dropdownable? newValue) onSelected;
  final List<Tag> tagList;
  const TagSelector(
      {super.key,
      required this.controller,
      required this.onSelected,
      required this.tagList});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("เลือก tags :", style: GoogleFonts.notoSansThai(fontSize: 17)),
            CustomDropdownMenu(
                width: 140,
                fontSize: 15,
                onSelected: onSelected,
                items: tagList)
          ],
        ),
      ),
    );
  }
}
