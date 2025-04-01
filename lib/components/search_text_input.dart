import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchTextInput extends StatefulWidget {
  final TextEditingController controller;
  const SearchTextInput({super.key, required this.controller});

  @override
  State<SearchTextInput> createState() => _SearchTextInputState();
}

class _SearchTextInputState extends State<SearchTextInput> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      style: GoogleFonts.notoSansThai(),
      onChanged: (value) {},
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "ค้นหา",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.primaryContainer),
        ),
      ),
    );
  }
}
