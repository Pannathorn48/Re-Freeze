import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputFeild extends StatelessWidget {
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  const InputFeild(
      {super.key,
      required this.label,
      this.validator,
      required this.hintText,
      this.obscureText,
      this.keyboardType,
      this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.notoSansThai(fontSize: 15)),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
              decoration: InputDecoration(
                  suffixIcon: suffixIcon,
                  suffixIconColor: suffixIcon != null ? Colors.black26 : null,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black38),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black38),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: hintText,
                  hintStyle: GoogleFonts.notoSans(
                      fontSize: 15, color: Theme.of(context).hintColor)),
              obscureText: obscureText ?? false,
              keyboardType: keyboardType,
              validator: validator),
        ],
      ),
    );
  }
}
