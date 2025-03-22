import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/pages/home/_notification_card.dart';
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
        NotificationCard(
          onTap: () {},
          icon: Icons.error_rounded,
          backgroundColor: const Color.fromARGB(255, 249, 242, 243),
          primaryColor: Colors.redAccent,
        ),
        const SizedBox(height: 10),
        NotificationCard(
          onTap: () {},
          icon: Icons.warning_rounded,
          backgroundColor: const Color.fromARGB(255, 252, 246, 236),
          primaryColor: Colors.amber,
        )
      ],
    );
  }
}
