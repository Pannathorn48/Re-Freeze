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
import 'package:mobile_project/models/refrigerators_model.dart';
import 'package:mobile_project/services/image_service.dart';

class EditRefrigeratorDialog extends StatefulWidget {
  final Refrigerator refrigerator;
  final String? filterGroupId; // New parameter for the current filter group

  const EditRefrigeratorDialog({
    super.key,
    required this.refrigerator,
    this.filterGroupId,
  });

  @override
  State<EditRefrigeratorDialog> createState() => _EditRefrigeratorDialogState();
}

class _EditRefrigeratorDialogState extends State<EditRefrigeratorDialog> {
  late bool _isPublic;
  late TextEditingController _nameTextController;
  final GroupApi _groupApi = GroupApi();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _refrigeratorApi = RefrigeratorApi();
  final ImagePicker _imagePicker = ImagePicker();
  File? image;
  String? currentImageUrl;
  Group? _selectedGroup;

  List<Group>? _groupList;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize with existing values - convert from isPrivate to isPublic
    _isPublic = !widget.refrigerator.isPrivate;
    _nameTextController = TextEditingController(text: widget.refrigerator.name);
    currentImageUrl = widget.refrigerator.imageUrl;

    // If the refrigerator is public, load groups and set the selected group
    if (_isPublic) {
      _loadGroups();
    }
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    super.dispose();
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

        // Try to find and set the current group if it exists
        if (widget.refrigerator.groupId.isNotEmpty) {
          _selectedGroup = groups.firstWhere(
            (group) => group.uid == widget.refrigerator.groupId,
            orElse: () => null as Group,
          );
        }
        // If we're filtering by a specific group and no group is selected,
        // try to set it to the filter group
        else if (widget.filterGroupId != null && _selectedGroup == null) {
          _selectedGroup = groups.firstWhere(
            (group) => group.uid == widget.filterGroupId,
            orElse: () => null as Group,
          );
        }

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
    return Dialog(
        child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: MediaQuery.of(context).size.width * 0.95,
      height: _isPublic
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
                  "แก้ไขตู้เย็น",
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
              child: image != null
                  ? Image.file(
                      image!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : currentImageUrl != null && currentImageUrl!.isNotEmpty
                      ? Image.network(
                          ImageService.getSignURL(currentImageUrl!),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/images/no-image.png",
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          "assets/images/no-image.png",
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
                foregroundColor: Colors.white,
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
                      value: _isPublic,
                      inactiveThumbColor: Theme.of(context).colorScheme.primary,
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      activeColor: Colors.white,
                      onChanged: (value) {
                        setState(() {
                          _isPublic = value;
                          if (value && _groupList == null) {
                            _loadGroups();
                          }
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
              child: _isPublic
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
                      if (_isPublic && _selectedGroup == null) {
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

                      try {
                        String? imageUrl = currentImageUrl;
                        // Upload new image if selected
                        if (image != null) {
                          imageUrl = await ImageService.uploadImage(
                              image!.path, "refrigerators");
                        }

                        await _refrigeratorApi.updateRefrigerator(
                          refrigeratorId: widget.refrigerator.uid,
                          name: _nameTextController.text,
                          isPublic: _isPublic,
                          imageUrl: imageUrl,
                          groupId: _isPublic ? _selectedGroup?.uid : null,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "แก้ไขตู้เย็นสำเร็จ",
                              style: GoogleFonts.notoSansThai(),
                            ),
                          ),
                        );
                        Navigator.of(context).pop(
                            true); // Return true to indicate refresh needed
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
                    },
                    text: "บันทึก",
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
      initial: _selectedGroup,
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
