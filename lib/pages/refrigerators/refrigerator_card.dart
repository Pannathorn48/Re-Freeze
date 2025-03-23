import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/custom_bottom_sheet.dart';
import 'package:mobile_project/components/custom_bottom_sheet_input.dart';

class RefrigeratorCard extends StatelessWidget {
  const RefrigeratorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset("assets/images/no-image.png",
                  width: 100, height: 100),
              const SizedBox(height: 25),
              Text(
                "Refrigerator Name",
                style: GoogleFonts.notoSansThai(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border)),
                  IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return CustomBottomSheet(
                                  title: "Refrigerator Name",
                                  height: 250,
                                  titleColor:
                                      Theme.of(context).colorScheme.primary,
                                  children: [
                                    CustomBottomSheetInput(
                                        onPressed: () {},
                                        text: "แก้ไข",
                                        icon: Icon(
                                          Icons.edit,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        textColor: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    CustomBottomSheetInput(
                                      onPressed: () {},
                                      text: "ลบ",
                                      textColor: Colors.redAccent,
                                      icon: const Icon(Icons.delete,
                                          color: Colors.redAccent),
                                    ),
                                  ]);
                            });
                      },
                      icon: const Icon(Icons.more_vert))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
