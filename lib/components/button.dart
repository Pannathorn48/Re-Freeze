import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Button extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? icon;
  final double? borderRadius;
  final String text;
  final double width;
  final double height;
  final Color fontColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? overlayColor;
  const Button({
    super.key,
    required this.onPressed,
    this.icon,
    required this.text,
    required this.width,
    required this.height,
    required this.fontColor,
    this.backgroundColor,
    this.borderColor,
    this.overlayColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return icon == null
        ? SizedBox(
            width: width,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  overlayColor: overlayColor,
                  backgroundColor: backgroundColor,
                  side: BorderSide(
                      color: borderColor ?? Colors.black, width: 0.05),
                  elevation: 2,
                  padding: EdgeInsets.fromLTRB(0, height / 2, 0, height / 2),
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius ?? 10),
                  ),
                ),
                onPressed: onPressed,
                child: Text(text,
                    style: GoogleFonts.notoSansThai(
                        fontSize: 17, color: fontColor))),
          )
        : SizedBox(
            width: width,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                overlayColor: overlayColor,
                backgroundColor: backgroundColor,
                side:
                    BorderSide(color: borderColor ?? Colors.black, width: 0.05),
                elevation: 1.5,
                padding: EdgeInsets.fromLTRB(0, height / 2, 0, height / 2),
                shadowColor: null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 10),
                ),
              ),
              onPressed: onPressed,
              icon: icon!,
              label: Text(text,
                  style:
                      GoogleFonts.notoSansThai(fontSize: 17, color: fontColor)),
            ),
          );
  }
}
