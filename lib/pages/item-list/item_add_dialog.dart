import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/input_field_rounded.dart';
import 'package:mobile_project/models/dropdownable_model.dart';
import 'package:mobile_project/models/item_model.dart';
import 'package:mobile_project/pages/item-list/date_picker.dart';
import 'package:mobile_project/pages/item-list/tag_selector.dart';

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

List<Tag> list = [
  Tag(name: "อาหาร", color: Colors.red),
  Tag(name: "เครื่องดื่ม", color: Colors.blue)
];

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameTextController = TextEditingController();
  final quantityTextController = TextEditingController();
  final unitTextController = TextEditingController();
  final selectorController = TextEditingController();
  final List<Tag> tags = [];
  DateTime? _expireDate = DateTime.now();
  DateTime? _warnDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  Tag? dropDownValue = list[0];

  @override
  void dispose() {
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
          )
        ],
      ),
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
                    child: Text("เพิ่มสินค้า",
                        style: GoogleFonts.notoSansThai(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary)),
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
                  controller: _scrollController, // Attach the controller
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
                                  child:
                                      Image.asset("assets/images/no-image.png"),
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
                                    onPressed: () {},
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
                              controller: nameTextController),
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
                          tagList: list,
                          controller: selectorController,
                          onSelected: (Dropdownable? newValue) {
                            newValue = (newValue) as Tag?;
                            if (newValue != null && !tags.contains(newValue)) {
                              tags.add(newValue);
                            }
                            setState(() {
                              dropDownValue = newValue as Tag?;
                            });
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
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: Chip(
                                    side: BorderSide(
                                        color: tags[index].color, width: 1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    backgroundColor: tags[index].color,
                                    label: Text(
                                      tags[index].name,
                                      style: GoogleFonts.notoSansThai(
                                          color: Colors.white, fontSize: 14),
                                    ),
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
                                onPressed: () {},
                                text: "ตกลง",
                                width: 150,
                                height: 30,
                                fontColor: Colors.white,
                                overlayColor: Colors.white,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary),
                          ],
                        ),
                        const SizedBox(
                            height: 20), // Add some padding at the bottom
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
