// Create Group Dialog implementation
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mobile_project/api/group_api.dart'; // You'll need to create this
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/input_field_rounded.dart';

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final creatorNameController = TextEditingController();
  Color currentColor = Colors.green;
  final ScrollController _scrollController = ScrollController();
  final groupApi = GroupApi();

  @override
  void dispose() {
    _scrollController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    creatorNameController.dispose();
    super.dispose();
  }

  void changeColor(Color color) {
    setState(() => currentColor = color);
  }

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
    return Dialog(
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const IconButton(
                  onPressed: null,
                  icon: Icon(Icons.close, color: Colors.transparent),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "สร้างกลุ่ม",
                      style: GoogleFonts.notoSansThai(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                radius: const Radius.circular(10),
                thickness: 3,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.group,
                            size: 70,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: InputFieldRounded(
                            hintText: "ชื่อกลุ่ม",
                            controller: nameController,
                            onChanged: (value) {
                              setState(() {});
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "กรุณากรอกชื่อกลุ่ม";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: InputFieldRounded(
                            hintText: "รายละเอียดกลุ่ม",
                            controller: descriptionController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "กรุณากรอกรายละเอียดกลุ่ม";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "เลือกสีของกลุ่ม",
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
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "กลุ่มตัวอย่าง",
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                  color: currentColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      nameController.text.isEmpty
                                          ? "ชื่อกลุ่ม"
                                          : nameController.text,
                                      style: GoogleFonts.notoSansThai(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (creatorNameController.text.isNotEmpty)
                                      Text(
                                        "สร้างโดย: ${creatorNameController.text}",
                                        style: GoogleFonts.notoSansThai(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    if (descriptionController.text.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          descriptionController.text,
                                          style: GoogleFonts.notoSansThai(
                                              color: Colors.white,
                                              fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
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
                                  try {
                                    groupApi.createGroup(
                                      name: nameController.text,
                                      color: currentColor.toHexString(),
                                      description: descriptionController.text,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "กลุ่ม ${nameController.text} ถูกสร้างเรียบร้อยแล้ว",
                                          style: GoogleFonts.notoSansThai(),
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "เกิดข้อผิดพลาดในการสร้างกลุ่ม",
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
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
