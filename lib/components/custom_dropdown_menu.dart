import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/models/dropdownable_model.dart';

class CustomDropdownMenu extends StatelessWidget {
  final void Function(Dropdownable?) onSelected;
  final List<Dropdownable> items;
  final double? fontSize;
  final double? width;
  final String? hintText;
  const CustomDropdownMenu(
      {super.key,
      required this.onSelected,
      required this.items,
      this.fontSize,
      this.width,
      this.hintText});

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<Dropdownable>(
      width: width,
      onSelected: onSelected,
      hintText: hintText,
      textStyle: GoogleFonts.notoSansThai(
          fontSize: fontSize, color: Theme.of(context).colorScheme.primary),
      dropdownMenuEntries: items.map((Dropdownable item) {
        return DropdownMenuEntry<Dropdownable>(
            value: item,
            label: item.name,
            style: MenuItemButton.styleFrom(
                textStyle: GoogleFonts.notoSansThai(fontSize: 17),
                foregroundColor: item.color));
      }).toList(),
    );
  }
}
