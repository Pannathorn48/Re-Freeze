import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputFieldRounded extends StatelessWidget {
  final String? hintText;
  final TextEditingController controller;
  const InputFieldRounded({super.key, required this.controller, this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: GoogleFonts.notoSansThai(),
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        hintText: hintText,
      ),
    );
  }
}
