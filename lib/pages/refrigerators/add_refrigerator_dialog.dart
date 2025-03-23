import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/button.dart';

class AddRefrigeratorDialog extends StatefulWidget {
  const AddRefrigeratorDialog({super.key});

  @override
  State<AddRefrigeratorDialog> createState() => _AddRefrigeratorDialogState();
}

class _AddRefrigeratorDialogState extends State<AddRefrigeratorDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close))
            ],
          ),
          Image.asset("assets/images/no-image.png", width: 150, height: 150),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {},
              child: Text(
                "เลือกรูป",
                style: GoogleFonts.notoSansThai(),
              )),
        ],
      ),
    ));
  }
}
