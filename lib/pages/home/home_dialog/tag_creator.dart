// Create Tag Tab implementation
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/tag_api.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/input_field_rounded.dart';
import 'package:mobile_project/models/item_model.dart';

class CreateTagTab extends StatefulWidget {
  const CreateTagTab({super.key});

  @override
  State<CreateTagTab> createState() => _CreateTagTabState();
}

class _CreateTagTabState extends State<CreateTagTab> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  Color currentColor = Colors.blue;
  final ScrollController _scrollController = ScrollController();
  final tagApi = TagApi();

  @override
  void dispose() {
    _scrollController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void changeColor(Color color) {
    setState(() => currentColor = color);
  }

  // Function to show the color picker dialog
  void showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'เลือกสี',
            style: GoogleFonts.notoSansThai(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: changeColor,
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              pickerAreaBorderRadius:
                  const BorderRadius.all(Radius.circular(10)),
              paletteType: PaletteType.hsv,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'ตกลง',
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      radius: const Radius.circular(10),
      thickness: 3,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_offer,
                  size: 70,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InputFieldRounded(
                  hintText: "ชื่อแท็ก",
                  controller: nameController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "กรุณากรอกชื่อแท็ก";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "เลือกสีของแท็ก",
                style: GoogleFonts.notoSansThai(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: showColorPickerDialog,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "แตะเพื่อเลือกสี",
                style: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 15),
              // Preview of the tag
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "แท็กตัวอย่าง",
                      style: GoogleFonts.notoSansThai(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Chip(
                      side: BorderSide(color: currentColor, width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      backgroundColor: currentColor,
                      label: Text(
                        nameController.text.isEmpty
                            ? "ชื่อแท็ก"
                            : nameController.text,
                        style: GoogleFonts.notoSansThai(
                            color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
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
                    width: 150,
                    height: 30,
                    fontColor: Colors.white,
                    overlayColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  Button(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        try{
                          tagApi.createTag(
                            name: nameController.text,
                            color: currentColor,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "แท็ก ${nameController.text} ถูกสร้างเรียบร้อยแล้ว",
                                style: GoogleFonts.notoSansThai(),
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "เกิดข้อผิดพลาดในการสร้างแท็ก",
                                style: GoogleFonts.notoSansThai(),
                              ),
                            ),
                          );
                        }
                        Navigator.of(context).pop();
                      }
                    },
                    text: "บันทึก",
                    width: 150,
                    height: 30,
                    fontColor: Colors.white,
                    overlayColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
