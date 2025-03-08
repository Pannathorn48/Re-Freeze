import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Button extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? icon;
  final String text;
  final double width;
  final double height;
  final Color fontColor;
  final Color? backgroundColor;
  final Color borderColor;
  const Button(
      {super.key,
      required this.onPressed,
      this.icon,
      required this.text,
      required this.width,
      required this.height,
      required this.fontColor,
      this.backgroundColor,
      required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return icon == null
        ? SizedBox(
            width: width,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  side: BorderSide(color: borderColor, width: 0.05),
                  elevation: 2,
                  padding: EdgeInsets.fromLTRB(0, height / 2, 0, height / 2),
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onPressed,
                child: Text(text,
                    style:
                        GoogleFonts.notoSans(fontSize: 17, color: fontColor))),
          )
        : SizedBox(
            width: width,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                side: BorderSide(color: borderColor, width: 0.05),
                elevation: 1.5,
                padding: EdgeInsets.fromLTRB(0, height / 2, 0, height / 2),
                shadowColor: null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onPressed,
              icon: icon!,
              label: Text(text,
                  style: GoogleFonts.notoSans(fontSize: 17, color: fontColor)),
            ),
          );
  }
}
