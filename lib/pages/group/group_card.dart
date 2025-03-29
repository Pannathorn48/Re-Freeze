import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/custom_bottom_sheet.dart';
import 'package:mobile_project/components/custom_bottom_sheet_input.dart';
import 'package:mobile_project/models/group_model.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 5, 7, 0),
      child: Card(
        color: group.color,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, "/refrigerators");
          },
          child: Ink(
            height: 150,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            group.name,
                            style: GoogleFonts.notoSansThai(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return CustomBottomSheet(
                                        title: group.name,
                                        height: 250,
                                        titleColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                                                .primary,
                                          ),
                                          const SizedBox(
                                            height: 7,
                                          ),
                                          CustomBottomSheetInput(
                                              onPressed: () {},
                                              text: "ลบกลุ่ม",
                                              textColor: Colors.redAccent,
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.redAccent,
                                              ))
                                        ]);
                                  });
                            },
                          )
                        ],
                      ),
                      Text(
                        group.description,
                        style: GoogleFonts.notoSansThai(
                            color: Colors.white, fontSize: 17),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "create by ${group.creatorName}",
                    style: GoogleFonts.notoSansThai(
                        color: Colors.white, fontSize: 15),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
