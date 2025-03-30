import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/item_api.dart';
import 'package:mobile_project/api/item_preset_api.dart';
import 'package:mobile_project/models/item_model.dart';
import 'package:mobile_project/models/item_preset_model.dart';
import 'package:mobile_project/services/custom_theme.dart';
import './item_add_dialog.dart';
import './item_preset_tab.dart';

class ItemTabbedDialog extends StatefulWidget {
  final String refrigeratorId;
  final Item? itemToEdit;

  const ItemTabbedDialog({
    super.key,
    required this.refrigeratorId,
    this.itemToEdit,
  });

  @override
  State<ItemTabbedDialog> createState() => _ItemTabbedDialogState();
}

class _ItemTabbedDialogState extends State<ItemTabbedDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ItemApi _itemApi = ItemApi();
  final ItemPresetApi _presetApi = ItemPresetApi();

  // Selected preset if any
  ItemPreset? _selectedPreset;

  @override
  void initState() {
    super.initState();

    // Initialize with 2 tabs, and don't allow editing mode to access presets tab
    final tabCount = widget.itemToEdit == null ? 2 : 1;

    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Handle adding an item from a preset
  Future<void> _addFromPreset(ItemPreset preset) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _itemApi.createItemFromPreset(
        refrigeratorId: widget.refrigeratorId,
        presetId: preset.uid,
      );

      // Close loading dialog and the form dialog
      Navigator.of(context).pop(); // Close loading dialog
      Navigator.of(context).pop(); // Close the main dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รายการถูกเพิ่มเรียบร้อยแล้ว')),
      );
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
    // Determine if we should show tabs
    final showTabs = widget.itemToEdit == null;

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
            // Dialog header
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
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

            const SizedBox(height: 10),

            // Only show tabs if we're not in edit mode
            if (showTabs)
              TabBar(
                dividerColor: CustomColors.grey,
                controller: _tabController,
                tabs: const [
                  Tab(
                    text: 'สร้างใหม่',
                    icon: Icon(Icons.add_circle_outline),
                  ),
                  Tab(
                    text: 'เลือกจากรายการ',
                    icon: Icon(Icons.list),
                  ),
                ],
                labelStyle: GoogleFonts.notoSansThai(),
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
              ),

            const SizedBox(height: 8),

            // Tab content area
            Expanded(
              child: showTabs
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Add new item form
                        AddItemDialog(
                          refrigeratorId: widget.refrigeratorId,
                          itemToEdit: widget.itemToEdit,
                          isEmbedded: true,
                        ),

                        // Tab 2: Select from presets
                        ItemPresetTab(
                          onPresetSelected: (preset) {
                            setState(() {
                              _selectedPreset = preset;
                            });
                          },
                          selectedPreset: _selectedPreset,
                          onAddItem: _addFromPreset,
                        ),
                      ],
                    )
                  : AddItemDialog(
                      refrigeratorId: widget.refrigeratorId,
                      itemToEdit: widget.itemToEdit,
                      isEmbedded: true,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
