import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IconDialog extends StatelessWidget {
  final Widget icon;
  final String title;
  final Color titleColor;
  final String content;
  final String actionText;
  final Color actionColor;
  const IconDialog(
      {super.key,
      required this.icon,
      required this.content,
      required this.title,
      required this.titleColor,
      required this.actionText,
      required this.actionColor});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
          child: Column(
        children: [
          const Icon(Icons.error, color: Colors.redAccent, size: 65),
          const SizedBox(
            height: 10,
          ),
          Text(title,
              style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  color: titleColor,
                  fontWeight: FontWeight.w500)),
        ],
      )),
      content: Text(content),
      actions: [
        Center(
          child: TextButton(
            style: TextButton.styleFrom(
              overlayColor: actionColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: actionColor)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(actionText,
                style: GoogleFonts.notoSansThai(color: actionColor)),
          ),
        ),
      ],
    );
  }
}
