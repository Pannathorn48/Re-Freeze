import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/models/group_model.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final Group group;
  final Function onDelete;
  final bool isLoading;

  const DeleteConfirmationDialog({
    super.key,
    required this.group,
    required this.onDelete,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              "ยืนยันการลบกลุ่ม",
              style: GoogleFonts.notoSansThai(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "คุณแน่ใจหรือไม่ว่าต้องการลบกลุ่ม '${group.name}'",
              style: GoogleFonts.notoSansThai(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "การดำเนินการนี้ไม่สามารถย้อนกลับได้ และจะลบตู้เย็นและรายการทั้งหมดที่เกี่ยวข้อง",
              style: GoogleFonts.notoSansThai(
                fontSize: 14,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  text: "ยกเลิก",
                  width: 120,
                  height: 40,
                  fontColor: Colors.black87,
                  overlayColor: Colors.grey[300]!,
                  backgroundColor: Colors.grey[200]!,
                ),
                Button(
                  onPressed: isLoading ? () {} : () => onDelete(),
                  text: isLoading ? "กำลังลบ..." : "ยืนยันการลบ",
                  width: 120,
                  height: 40,
                  fontColor: Colors.white,
                  overlayColor: Colors.red[300]!,
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
