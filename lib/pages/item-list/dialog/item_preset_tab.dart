import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/item_preset_api.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/models/item_preset_model.dart';

class ItemPresetTab extends StatefulWidget {
  final Function(ItemPreset) onPresetSelected;
  final Function(ItemPreset) onAddItem;
  final ItemPreset? selectedPreset;

  const ItemPresetTab({
    super.key,
    required this.onPresetSelected,
    required this.onAddItem,
    this.selectedPreset,
  });

  @override
  State<ItemPresetTab> createState() => _ItemPresetTabState();
}

class _ItemPresetTabState extends State<ItemPresetTab> {
  final ItemPresetApi _presetApi = ItemPresetApi();
  late Future<List<ItemPreset>> _presetsFuture;

  bool _showOnlyUserPresets = false;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  void _loadPresets() {
    if (_showOnlyUserPresets) {
      _presetsFuture = _presetApi.getUserPresets();
    } else {
      _presetsFuture = _presetApi.getAllPresets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter toggle
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'แสดงเฉพาะของฉัน',
                  style: GoogleFonts.notoSansThai(),
                ),
                Switch(
                  value: _showOnlyUserPresets,
                  onChanged: (value) {
                    setState(() {
                      _showOnlyUserPresets = value;
                      _loadPresets();
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<ItemPreset>>(
              future: _presetsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'เกิดข้อผิดพลาด: ${snapshot.error}',
                      style: GoogleFonts.notoSansThai(color: Colors.red),
                    ),
                  );
                }

                final presets = snapshot.data ?? [];

                if (presets.isEmpty) {
                  return Center(
                    child: Text(
                      'ไม่พบรายการสินค้าที่บันทึกไว้',
                      style: GoogleFonts.notoSansThai(),
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    final preset = presets[index];
                    final isSelected = widget.selectedPreset?.uid == preset.uid;

                    return GestureDetector(
                      onTap: () => widget.onPresetSelected(preset),
                      child: Card(
                        elevation: isSelected ? 5 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                child: preset.imageUrl.isNotEmpty
                                    ? Image.network(
                                        preset.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, _, __) =>
                                            Image.asset(
                                          "assets/images/no-image.png",
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Image.asset(
                                        "assets/images/no-image.png",
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    preset.name,
                                    style: GoogleFonts.notoSansThai(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${preset.quantity} ${preset.unit}',
                                          style: GoogleFonts.notoSansThai(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.circle,
                                        size: 12,
                                        color: _getWarningColor(preset),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Bottom action buttons
          if (widget.selectedPreset != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Button(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    text: "ยกเลิก",
                    width: 150,
                    height: 40,
                    fontColor: Colors.white,
                    overlayColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  Button(
                    onPressed: () => widget.onAddItem(widget.selectedPreset!),
                    text: "เพิ่มสินค้า",
                    width: 150,
                    height: 40,
                    fontColor: Colors.white,
                    overlayColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to display expiry warning color
  Color _getWarningColor(ItemPreset preset) {
    final now = DateTime.now();
    final daysToExpiry = preset.expiryDate.difference(now).inDays;

    if (daysToExpiry < 0) {
      return Colors.red; // Expired
    } else if (daysToExpiry <= 3) {
      return Colors.orange; // Warning
    } else {
      return Colors.green; // Good
    }
  }
}
