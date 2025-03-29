import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/pages/home/home_add_item.dart';
import 'package:mobile_project/pages/home/tag_creator.dart';
import 'package:mobile_project/services/custom_theme.dart';

class TabbedDialog extends StatefulWidget {
  const TabbedDialog({super.key});

  @override
  State<TabbedDialog> createState() => _TabbedDialogState();
}

class _TabbedDialogState extends State<TabbedDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                    child: Text("จัดการสินค้า",
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
            TabBar(
              unselectedLabelColor: CustomColors.grey,
              dividerColor: CustomColors.grey,
              controller: _tabController,
              tabs: [
                Tab(
                  child: Text(
                    "เพิ่มสินค้า",
                    style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "เพิ่มแท็ก",
                    style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  AddItemTab(),
                  CreateTagTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
