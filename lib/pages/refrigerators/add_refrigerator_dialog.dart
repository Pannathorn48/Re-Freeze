import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/components/custom_dropdown_menu.dart';
import 'package:mobile_project/components/input_feild.dart';
import 'package:mobile_project/models/dropdownable.dart';
import 'package:mobile_project/models/group.dart';

final groupList = <Group>[
  Group(name: "Tester", color: Colors.purple),
  Group(name: "Meet", color: Colors.redAccent)
];

class AddRefrigeratorDialog extends StatefulWidget {
  const AddRefrigeratorDialog({super.key});

  @override
  State<AddRefrigeratorDialog> createState() => _AddRefrigeratorDialogState();
}

class _AddRefrigeratorDialogState extends State<AddRefrigeratorDialog> {
  bool _isSelected = false;
  final TextEditingController _nameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: AnimatedContainer(
      // Add animation duration
      duration: const Duration(milliseconds: 300),
      // Add curve for smoother animation
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
            Image.asset("assets/images/no-image.png", width: 150, height: 150),
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
              onPressed: () {},
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
            InputFeild(
                label: "ชื่อตู้เย็น",
                hintText: "",
                controller: _nameTextController),
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
                          CustomDropdownMenu(
                              width: 300,
                              onSelected: (Dropdownable? item) {},
                              items: groupList),
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
                    onPressed: () {},
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
}
