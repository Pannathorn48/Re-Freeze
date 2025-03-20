import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/services/fonts.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("notification",
            style: GoogleFonts.notoSansThai(color: CustomColors.grey)),
        Divider(
          color: CustomColors.grey,
        ),
        const SizedBox(height: 10),
        Card(
            elevation: 5,
            child: Container(
              height: 100,
            )),
        const SizedBox(height: 10),
        Card(
            elevation: 5,
            child: Container(
              height: 100,
            )),
      ],
    );
  }
}
