import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/pages/home/notification_card.dart';
import 'package:mobile_project/services/custom_theme.dart';

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
          backgroundColor: CustomColors.errorBackground,
          primaryColor: CustomColors.error,
        ),
        const SizedBox(height: 10),
        NotificationCard(
          onTap: () {},
          icon: Icons.warning_rounded,
          backgroundColor: CustomColors.warningBackground,
          primaryColor: CustomColors.warning,
        )
      ],
    );
  }
}
