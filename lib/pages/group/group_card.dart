import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/group_api.dart';
import 'package:mobile_project/components/custom_bottom_sheet.dart';
import 'package:mobile_project/components/custom_bottom_sheet_input.dart';
import 'package:mobile_project/models/group_model.dart';
import 'package:mobile_project/pages/group/group_confirm_delete.dart';
import 'package:mobile_project/pages/group/group_edit.dart';

class GroupCard extends StatefulWidget {
  final Group group;
  final Function? onGroupChanged;

  const GroupCard({super.key, required this.group, this.onGroupChanged});

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  final GroupApi _groupApi = GroupApi();
  bool _isDeleting = false;

  void _handleEdit() async {
    Navigator.pop(context); // Close the bottom sheet

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditGroupDialog(group: widget.group),
    );

    // If edit was successful, refresh the parent
    if (result == true && widget.onGroupChanged != null) {
      widget.onGroupChanged!();
    }
  }

  void _handleDelete() async {
    Navigator.pop(context); // Close the bottom sheet

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteConfirmationDialog(
        group: widget.group,
        isLoading: _isDeleting,
        onDelete: () async {
          setState(() {
            _isDeleting = true;
          });

          try {
            await _groupApi.deleteGroup(widget.group.uid);

            if (mounted) {
              Navigator.pop(context); // Close the confirmation dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "กลุ่ม ${widget.group.name} ถูกลบเรียบร้อยแล้ว",
                    style: GoogleFonts.notoSansThai(),
                  ),
                ),
              );

              // Refresh the group list
              if (widget.onGroupChanged != null) {
                widget.onGroupChanged!();
              }
            }
          } catch (e) {
            if (mounted) {
              Navigator.pop(context); // Close the confirmation dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "เกิดข้อผิดพลาดในการลบกลุ่ม: $e",
                    style: GoogleFonts.notoSansThai(),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } finally {
            if (mounted) {
              setState(() {
                _isDeleting = false;
              });
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 5, 7, 0),
      child: Card(
        color: widget.group.color,
        child: InkWell(
          onTap: () {
            // Pass the group as an argument when navigating to the refrigerators page
            Navigator.pushNamed(context, "/refrigerators", arguments: {
              'groupId': widget.group.uid,
              'groupName': widget.group.name,
              'filterByGroup': true
            });
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
                            widget.group.name,
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
                                        title: widget.group.name,
                                        height: 300,
                                        titleColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        children: [
                                          CustomBottomSheetInput(
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: widget.group.uid));
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                  "คัดลอกรหัสกลุ่ม ${widget.group.uid} เรียบร้อย",
                                                  style: GoogleFonts
                                                      .notoSansThai(),
                                                ),
                                              ));
                                            },
                                            text: "คัดลอกรหัสกลุ่ม",
                                            icon: Icon(
                                              Icons.group,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            textColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          CustomBottomSheetInput(
                                            onPressed: _handleEdit,
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
                                            onPressed: _handleDelete,
                                            text: "ลบกลุ่ม",
                                            textColor: Colors.redAccent,
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ),
                                          )
                                        ]);
                                  });
                            },
                          )
                        ],
                      ),
                      Text(
                        widget.group.description,
                        style: GoogleFonts.notoSansThai(
                            color: Colors.white, fontSize: 17),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "create by ${widget.group.creatorName}",
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
