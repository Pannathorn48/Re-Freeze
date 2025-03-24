import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime? date;
  final String label;
  final VoidCallback onPressed;
  final Color color;
  const DatePickerWidget(
      {super.key,
      this.date,
      required this.label,
      required this.onPressed,
      required this.color});

  @override
  Widget build(BuildContext context) {
    String day = date?.day.toString() ?? '--';
    String month = date?.month.toString() ?? '--';
    String year = date?.year.toString() ?? '----';
    return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.notoSansThai(fontSize: 17)),
              const SizedBox(width: 20),
              ElevatedButton(
                  onPressed: onPressed,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: color,
                      ),
                      const SizedBox(width: 10),
                      Text("$day/$month/$year",
                          style: GoogleFonts.notoSansThai(color: color)),
                    ],
                  )),
            ],
          ),
        ));
  }
}
