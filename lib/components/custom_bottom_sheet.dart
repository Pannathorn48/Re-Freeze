import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomSheet extends StatefulWidget {
  final String title;
  final Color titleColor;
  final List<Widget> children;
  final double? height;
  const CustomBottomSheet(
      {super.key,
      required this.title,
      required this.titleColor,
      required this.children,
      this.height});

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                    width: 48), // Balance the width of the close button
                Text(
                  widget.title,
                  style: GoogleFonts.notoSansThai(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: widget.titleColor),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
          ...widget.children,
        ],
      ),
    );
  }
}
