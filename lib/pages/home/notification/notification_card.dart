import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final void Function() onTap;
  final Color? backgroundColor;
  final Color? primaryColor;
  final String title;
  const NotificationCard(
      {super.key,
      required this.onTap,
      this.backgroundColor,
      this.primaryColor,
      required this.icon,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Icon(
                      icon,
                      color: primaryColor,
                      size: 50,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: GoogleFonts.notoSansThai(
                        fontSize: 16, color: Colors.black),
                  ),
                  Container(
                    width: 40,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "10",
                      style: GoogleFonts.notoSansThai(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                    ),
                  ),
                  Text(
                    " รายการ",
                    style: GoogleFonts.notoSansThai(
                        fontSize: 18, color: Colors.black),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
