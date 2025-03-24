import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/models/item.dart';

class TagSelector extends StatelessWidget {
  final TextEditingController controller;
  final Function(Tag? newValue) onSelected;
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
            DropdownMenu<Tag>(
              onSelected: onSelected,
              textStyle: GoogleFonts.notoSansThai(
                  color: Theme.of(context).colorScheme.primary),
              dropdownMenuEntries: tagList.map((Tag tag) {
                return DropdownMenuEntry<Tag>(
                    value: tag,
                    label: tag.name,
                    style: MenuItemButton.styleFrom(
                        textStyle: GoogleFonts.notoSansThai(fontSize: 17),
                        foregroundColor: tag.color));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
