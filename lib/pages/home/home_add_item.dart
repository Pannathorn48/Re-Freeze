// First tab - Add Item (from existing code)
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_project/api/item_preset_api.dart';
import 'package:mobile_project/api/tag_api.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/input_field_rounded.dart';
import 'package:mobile_project/models/dropdownable_model.dart';
import 'package:mobile_project/models/item_model.dart';
import 'package:mobile_project/pages/item-list/date_picker.dart';
import 'package:mobile_project/pages/item-list/tag_selector.dart';
import 'package:mobile_project/services/image_service.dart';

class AddItemTab extends StatefulWidget {
  const AddItemTab({super.key});

  @override
  State<AddItemTab> createState() => _AddItemTabState();
}

class _AddItemTabState extends State<AddItemTab> {
  final _itemPresetApi = ItemPresetApi();
  final _tagApi = TagApi();
  final _formKey = GlobalKey<FormState>();
  final nameTextController = TextEditingController();
  final quantityTextController = TextEditingController();
  final unitTextController = TextEditingController();
  final selectorController = TextEditingController();
  final List<Tag> tags = [];
  DateTime? _expireDate = DateTime.now();
  DateTime? _warnDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  ImagePicker imagePicker = ImagePicker();
  late Future<List<Tag>> _tagsFuture;

  File? image;

  @override
  void initState() {
    _tagsFuture = _fetchTags();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    nameTextController.dispose();
    quantityTextController.dispose();
    unitTextController.dispose();
    selectorController.dispose();
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
          )
        ],
      ),
    );
  }

  Future<List<Tag>> _fetchTags() async {
    try {
      return await _tagApi.getTags();
    } catch (e) {
      rethrow;
    }
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
        child: FutureBuilder(
            future: _tagsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Error loading tags: ${snapshot.error}"),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _tagsFuture = _fetchTags(); // Retry loading
                          });
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }
              return Form(
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
                                onPressed: () {},
                                icon: const Icon(Icons.camera_alt),
                                label: const Text("camera"),
                              ),
                            ),
                            const SizedBox(height: 7),
                            SizedBox(
                              width: 130,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  XFile? image = await imagePicker.pickImage(
                                      source: ImageSource.gallery);
                                  if (image != null) {
                                    setState(() {
                                      this.image = File(image.path);
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
                      tagList: snapshot.data!,
                      controller: selectorController,
                      onSelected: (Dropdownable? newValue) {
                        Tag? newTag = newValue as Tag?;
                        if (newTag != null && !tags.contains(newTag)) {
                          setState(() {
                            tags.add(newTag);
                          });
                        }
                      },
                    )),
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
                                side: BorderSide(
                                    color: tags[index].color, width: 1),
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
                          }),
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
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Show loading indicator
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                      child: CircularProgressIndicator()),
                                );

                                try {
                                  // Upload image if exists
                                  String imageUrl = '';
                                  if (image != null) {
                                    imageUrl = await ImageService.uploadImage(
                                        image!.path, 'item');
                                  } else {
                                    throw Exception(
                                        'Image is required to create an item preset');
                                  }

                                  List<DocumentReference> tagRefs = tags
                                      .map((tag) => FirebaseFirestore.instance
                                          .collection('tags')
                                          .doc(tag.uid))
                                      .toList();

                                  // Create the item preset
                                  await _itemPresetApi.createItemPreset(
                                    name: nameTextController.text,
                                    imageUrl: imageUrl,
                                    unit: unitTextController.text,
                                    quantity: int.tryParse(
                                            quantityTextController.text) ??
                                        0,
                                    expiryDate: _expireDate ?? DateTime.now(),
                                    warningDate: _warnDate ?? DateTime.now(),
                                    tags: tagRefs,
                                  );

                                  Navigator.of(context).pop();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Item preset created successfully')),
                                  );

                                  Navigator.of(context).pop();
                                } catch (e) {
                                  Navigator.of(context).pop();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Error creating item preset: $e')),
                                  );
                                }
                              }
                            },
                            text: "ตกลง",
                            width: 150,
                            height: 30,
                            fontColor: Colors.white,
                            overlayColor: Colors.white,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
