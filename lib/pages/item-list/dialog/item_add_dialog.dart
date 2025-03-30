import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_project/api/item_api.dart';
import 'package:mobile_project/api/tag_api.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/input_field_rounded.dart';
import 'package:mobile_project/models/dropdownable_model.dart';
import 'package:mobile_project/models/item_model.dart';
import 'package:mobile_project/pages/item-list/date_picker.dart';
import 'package:mobile_project/pages/item-list/tag_selector.dart';
import 'package:mobile_project/services/image_service.dart';

class AddItemDialog extends StatefulWidget {
  final String? refrigeratorId;
  final Item? itemToEdit;
  final bool
      isEmbedded; // New property to determine if this is embedded in a tab

  const AddItemDialog({
    super.key,
    this.refrigeratorId,
    this.itemToEdit,
    this.isEmbedded = false, // Default to false for backward compatibility
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameTextController = TextEditingController();
  final quantityTextController = TextEditingController();
  final unitTextController = TextEditingController();
  final selectorController = TextEditingController();
  final List<Tag> tags = [];
  DateTime? _expireDate;
  DateTime? _warnDate;
  final ScrollController _scrollController = ScrollController();
  Tag? dropDownValue;
  final ImagePicker _imagePicker = ImagePicker();
  File? image;

  // APIs
  final ItemApi _itemApi = ItemApi();
  final TagApi _tagApi = TagApi();
  late Future<List<Tag>> _tagsFuture;

  @override
  void initState() {
    super.initState();
    _tagsFuture = _fetchTags();

    // Initialize with default dates if not editing
    if (widget.itemToEdit == null) {
      _expireDate = DateTime.now().add(const Duration(days: 7));
      _warnDate = DateTime.now().add(const Duration(days: 3));
    } else {
      // Populate form with item data if editing
      _expireDate = widget.itemToEdit!.expiryDate;
      _warnDate = widget.itemToEdit!.warningDate;
      nameTextController.text = widget.itemToEdit!.name;
      quantityTextController.text = widget.itemToEdit!.quantity.toString();
      unitTextController.text = widget.itemToEdit!.unit;
      tags.addAll(widget.itemToEdit!.tags);
    }
  }

  Future<List<Tag>> _fetchTags() async {
    try {
      return await _tagApi.getTags();
    } catch (e) {
      // Return empty list if tags can't be fetched
      return [];
    }
  }

  @override
  void dispose() {
    nameTextController.dispose();
    quantityTextController.dispose();
    unitTextController.dispose();
    selectorController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectExpireDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _expireDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (pickedDate != null) {
      setState(() {
        _expireDate = pickedDate;
      });
    }
  }

  Future<void> _selectWarnDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _warnDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (pickedDate != null) {
      setState(() {
        _warnDate = pickedDate;
      });
    }
  }

  Widget _quantityManage(
      {required BuildContext context,
      required TextEditingController controller,
      required String label,
      required double width}) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.notoSansThai(fontSize: 17)),
          const SizedBox(height: 10),
          InputFieldRounded(
            controller: controller,
            centerText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณากรอก$label";
              }
              if (label == "จำนวน") {
                try {
                  int.parse(value);
                } catch (e) {
                  return "กรุณากรอกตัวเลข";
                }
              }
              return null;
            },
          )
        ],
      ),
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate() ||
        _expireDate == null ||
        _warnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Upload image if exists
      String imageUrl = '';
      if (image != null) {
        imageUrl = await ImageService.uploadImage(image!.path, 'item');
      }

      if (widget.itemToEdit == null) {
        // Create new item
        if (widget.refrigeratorId == null) {
          throw Exception('Refrigerator ID is required to create an item');
        }

        await _itemApi.createItem(
          refrigeratorId: widget.refrigeratorId!,
          name: nameTextController.text,
          quantity: int.tryParse(quantityTextController.text) ?? 0,
          expiryDate: _expireDate!,
          warningDate: _warnDate!,
          imageUrl: imageUrl,
          unit: unitTextController.text,
          tags: tags,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('รายการถูกเพิ่มเรียบร้อยแล้ว')),
        );
      } else {
        // Update existing item
        await _itemApi.updateItem(
          itemId: widget.itemToEdit!.uid,
          name: nameTextController.text,
          quantity: int.tryParse(quantityTextController.text) ?? 0,
          expiryDate: _expireDate,
          warningDate: _warnDate,
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
          unit: unitTextController.text,
          tags: tags,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('รายการถูกแก้ไขเรียบร้อยแล้ว')),
        );
      }

      // Close loading dialog and the form dialog
      Navigator.of(context).pop();

      // Only pop the main dialog if this is not embedded in a tab
      if (!widget.isEmbedded) {
        Navigator.of(context).pop();
      } else {
        // If embedded, pop the parent dialog
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If embedded, return just the form content
    if (widget.isEmbedded) {
      return _buildFormContent();
    }

    // Otherwise return the full dialog
    return Dialog(
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
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
                      widget.itemToEdit == null ? "เพิ่มสินค้า" : "แก้ไขสินค้า",
                      style: GoogleFonts.notoSansThai(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary),
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
              child: _buildFormContent(),
            ),
          ],
        ),
      ),
    );
  }

  // Extract the form content to be reused in both embedded and standalone modes
  Widget _buildFormContent() {
    return FutureBuilder<List<Tag>>(
      future: _tagsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Use the available tags or an empty list if there's an error
        final availableTags = snapshot.hasData ? snapshot.data! : <Tag>[];

        return SingleChildScrollView(
          controller: _scrollController,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: ClipOval(
                            child: image == null
                                ? Image.asset(
                                    "assets/images/no-image.png",
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    image!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text("Scan QR"),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        SizedBox(
                          width: 130,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              XFile? capturedImage = await _imagePicker
                                  .pickImage(source: ImageSource.camera);
                              if (capturedImage != null) {
                                setState(() {
                                  image = File(capturedImage.path);
                                });
                              }
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("camera"),
                          ),
                        ),
                        const SizedBox(height: 7),
                        SizedBox(
                          width: 130,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              XFile? pickedImage = await _imagePicker.pickImage(
                                  source: ImageSource.gallery);
                              if (pickedImage != null) {
                                setState(() {
                                  image = File(pickedImage.path);
                                });
                              }
                            },
                            icon: const Icon(Icons.photo),
                            label: const Text("gallery"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: InputFieldRounded(
                    hintText: "ชื่อสินค้า",
                    controller: nameTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "กรุณากรอกชื่อสินค้า";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: DatePickerWidget(
                      date: _expireDate,
                      label: "วันหมดอายุ :",
                      color: Colors.red,
                      onPressed: () {
                        _selectExpireDate();
                      }),
                ),
                const SizedBox(height: 10),
                Center(
                  child: DatePickerWidget(
                      date: _warnDate,
                      label: "วันแจ้งเตือน :",
                      color: Colors.orange,
                      onPressed: () {
                        _selectWarnDate();
                      }),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TagSelector(
                    tagList: availableTags,
                    controller: selectorController,
                    onSelected: (Dropdownable? newValue) {
                      Tag? newTag = newValue as Tag?;
                      if (newTag != null && !tags.contains(newTag)) {
                        setState(() {
                          tags.add(newTag);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Chip(
                          side: BorderSide(color: tags[index].color, width: 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          backgroundColor: tags[index].color,
                          label: Text(
                            tags[index].name,
                            style: GoogleFonts.notoSansThai(
                                color: Colors.white, fontSize: 14),
                          ),
                          deleteIcon: const Icon(Icons.close,
                              color: Colors.white, size: 16),
                          onDeleted: () {
                            setState(() {
                              tags.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _quantityManage(
                        label: "จำนวน",
                        context: context,
                        width: 175,
                        controller: quantityTextController),
                    const SizedBox(width: 20),
                    _quantityManage(
                        label: "หน่วย",
                        context: context,
                        width: 100,
                        controller: unitTextController)
                  ],
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
                        backgroundColor: Colors.red),
                    Button(
                        onPressed: _saveItem,
                        text: "ตกลง",
                        width: 150,
                        height: 30,
                        fontColor: Colors.white,
                        overlayColor: Colors.white,
                        backgroundColor: Theme.of(context).colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
