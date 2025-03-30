import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_project/api/refrigerator_api.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/custom_dropdown_menu.dart';
import 'package:mobile_project/components/input_feild.dart';
import 'package:mobile_project/models/dropdownable_model.dart';
import 'package:mobile_project/models/group_model.dart';
import 'package:mobile_project/api/group_api.dart';
import 'package:mobile_project/services/image_service.dart';

class AddRefrigeratorDialog extends StatefulWidget {
  const AddRefrigeratorDialog({super.key});

  @override
  State<AddRefrigeratorDialog> createState() => _AddRefrigeratorDialogState();
}

class _AddRefrigeratorDialogState extends State<AddRefrigeratorDialog> {
  bool _isSelected = false;
  final TextEditingController _nameTextController = TextEditingController();
  final GroupApi _groupApi = GroupApi();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _refrigeratorApi = RefrigeratorApi();
  final ImagePicker _imagePicker = ImagePicker();
  File? image;
  Group? _selectedGroup;

  List<Group>? _groupList;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadGroups() async {
    if (_groupList != null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final groups = await _groupApi.getUserGroups();
      setState(() {
        _groupList = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSelected && _groupList == null && !_isLoading) {
      _loadGroups();
    }

    return Dialog(
        child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: MediaQuery.of(context).size.width * 0.95,
      height: _isSelected
          ? MediaQuery.of(context).size.height * 0.75
          : MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.close,
                      color: Colors.transparent,
                    )),
                Text(
                  "สร้างตู้เย็น",
                  style: GoogleFonts.notoSansThai(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            ClipOval(
              child: image == null
                  ? Image.asset(
                      "assets/images/no-image.png",
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      image!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                overlayColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () async {
                XFile? selectedImage = await _imagePicker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                );
                if (selectedImage != null) {
                  setState(() {
                    image = File(selectedImage.path);
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "เลือกรูป",
                  style: GoogleFonts.notoSansThai(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Form(
              key: _formKey,
              child: InputFeild(
                  label: "ชื่อตู้เย็น",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "กรุณากรอกชื่อ";
                    }
                    return null;
                  },
                  hintText: "",
                  controller: _nameTextController),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "public:",
                    style: GoogleFonts.notoSansThai(fontSize: 15),
                  ),
                  Switch(
                      value: _isSelected,
                      inactiveThumbColor: Theme.of(context).colorScheme.primary,
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      activeColor: Colors.white,
                      onChanged: (value) {
                        setState(() {
                          _isSelected = value;
                        });
                      })
                ],
              ),
            ),
            // Wrap the conditional content in AnimatedSwitcher for smooth appearing/disappearing
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    child: child,
                  ),
                );
              },
              child: _isSelected
                  ? Padding(
                      key: const ValueKey('selected'),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "เลือกกลุ่มที่ต้องการจะให้เห็นตู้เย็นนี้",
                            style: GoogleFonts.notoSansThai(fontSize: 15),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          // Use conditional rendering based on loading state
                          _buildGroupSelector(),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(
                      key: ValueKey('not-selected'),
                      height: 20,
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    backgroundColor: Colors.redAccent),
                Button(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() != true) {
                      return;
                      }
                      if (_isSelected && _selectedGroup == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                        content: Text(
                          "กรุณาเลือกกลุ่ม",
                          style: GoogleFonts.notoSansThai(),
                        ),
                        ),
                      );
                      return;
                      }
                      if (image == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                        content: Text(
                          "กรุณาเลือกรูป",
                          style: GoogleFonts.notoSansThai(),
                        ),
                        ),
                      );
                      return;
                      }

                      try {
                        final fullPath = await ImageService.uploadImage(
                            image!.path, "refrigerators");
                        await _refrigeratorApi.addRefrigerators(
                          name: _nameTextController.text,
                          isPublic: _isSelected,
                          imageUrl: fullPath,
                          groupId: _isSelected ? _selectedGroup?.uid : null,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "เพิ่มตู้เย็นสำเร็จ",
                              style: GoogleFonts.notoSansThai(),
                            ),
                          ),
                        );
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "เกิดข้อผิดพลาด: $error",
                              style: GoogleFonts.notoSansThai(),
                            ),
                          ),
                        );
                      }

                      Navigator.of(context).pop();
                    },
                    text: "ตกลง",
                    width: 150,
                    height: 30,
                    fontColor: Colors.white,
                    overlayColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary),
              ],
            )
          ],
        ),
      ),
    ));
  }

  // Separated widget for the group selector to make the code cleaner
  Widget _buildGroupSelector() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Text(
        "เกิดข้อผิดพลาดในการโหลดกลุ่ม: $_errorMessage",
        style: GoogleFonts.notoSansThai(color: Colors.red),
      );
    }

    if (_groupList == null || _groupList!.isEmpty) {
      return Text(
        "ไม่พบกลุ่ม",
        style: GoogleFonts.notoSansThai(),
      );
    }

    return CustomDropdownMenu(
      width: 300,
      onSelected: (Dropdownable? item) {
        if (item is Group) {
          setState(() {
            _selectedGroup = item;
          });
        }
      },
      items: _groupList!,
    );
  }
}
