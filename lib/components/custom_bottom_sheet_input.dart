import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomSheetInput extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Widget icon;
  final Color? textColor;

  const CustomBottomSheetInput({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                icon,
                const SizedBox(width: 10),
                Text(
                  text,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 20,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(
              color: textColor ?? Colors.grey,
              thickness: 0.5,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }
}
