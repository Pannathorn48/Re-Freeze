import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mobile_project/api/group_api.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/input_field_rounded.dart';
import 'package:mobile_project/services/custom_theme.dart';

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog>
    with SingleTickerProviderStateMixin {
  final _createFormKey = GlobalKey<FormState>();
  final _joinFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final groupIdController = TextEditingController();
  Color currentColor = Colors.green;
  final ScrollController _scrollController = ScrollController();
  final groupApi = GroupApi();
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    groupIdController.dispose();
    _tabController.dispose();
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

  // Method to create a new group
  Future<void> _createGroup() async {
    if (!_createFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await groupApi.createGroup(
        name: nameController.text,
        color: currentColor.toHexString(),
        description: descriptionController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "กลุ่ม ${nameController.text} ถูกสร้างเรียบร้อยแล้ว",
              style: GoogleFonts.notoSansThai(),
            ),
          ),
        );
        Navigator.of(context).pop(true); // Pass true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "เกิดข้อผิดพลาดในการสร้างกลุ่ม: $e",
              style: GoogleFonts.notoSansThai(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Method to join an existing group
  Future<void> _joinGroup() async {
    if (!_joinFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        throw Exception("คุณยังไม่ได้เข้าสู่ระบบ");
      }

      // Add user to the group
      await groupApi.addUserToGroup(groupIdController.text, userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "เข้าร่วมกลุ่มเรียบร้อยแล้ว",
              style: GoogleFonts.notoSansThai(),
            ),
          ),
        );
        Navigator.of(context).pop(true); // Pass true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "เกิดข้อผิดพลาดในการเข้าร่วมกลุ่ม: $e",
              style: GoogleFonts.notoSansThai(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                      "จัดการกลุ่ม",
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
            TabBar(
              dividerColor: CustomColors.grey,
              controller: _tabController,
              tabs: [
                Tab(
                  child: Text(
                    "สร้างกลุ่ม",
                    style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "เข้าร่วมกลุ่ม",
                    style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Create Group Tab
                  _buildCreateGroupTab(),

                  // Join Group Tab
                  _buildJoinGroupTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateGroupTab() {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      radius: const Radius.circular(10),
      thickness: 3,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Form(
          key: _createFormKey,
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
                          const SizedBox(height: 5),
                          if (descriptionController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                descriptionController.text,
                                style: GoogleFonts.notoSansThai(
                                    color: Colors.white, fontSize: 14),
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
                    height: 40,
                    fontColor: Colors.white,
                    overlayColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  Button(
                    onPressed: _isLoading ? () {} : _createGroup,
                    text: _isLoading ? "กำลังบันทึก..." : "บันทึก",
                    width: 150,
                    height: 40,
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

  Widget _buildJoinGroupTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _joinFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_add,
                size: 70,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "เข้าร่วมกลุ่มที่มีอยู่แล้ว",
              style: GoogleFonts.notoSansThai(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "กรอกรหัสกลุ่มที่ต้องการเข้าร่วม",
              style: GoogleFonts.notoSansThai(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InputFieldRounded(
                hintText: "รหัสกลุ่ม",
                controller: groupIdController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณากรอกรหัสกลุ่ม";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  text: "ยกเลิก",
                  width: 150,
                  height: 40,
                  fontColor: Colors.white,
                  overlayColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                Button(
                  onPressed: _isLoading ? () {} : _joinGroup,
                  text: _isLoading ? "กำลังเข้าร่วม..." : "เข้าร่วม",
                  width: 150,
                  height: 40,
                  fontColor: Colors.white,
                  overlayColor: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
