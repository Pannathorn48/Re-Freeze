import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/custom_bottom_sheet.dart';
import 'package:mobile_project/models/item_model.dart';
import 'package:mobile_project/api/item_api.dart';

class ItemQuantityEditSheet extends StatefulWidget {
  final Item item;
  final Function? onQuantityUpdated;

  const ItemQuantityEditSheet({
    Key? key,
    required this.item,
    this.onQuantityUpdated,
  }) : super(key: key);

  @override
  State<ItemQuantityEditSheet> createState() => _ItemQuantityEditSheetState();
}

class _ItemQuantityEditSheetState extends State<ItemQuantityEditSheet> {
  late TextEditingController _quantityController;
  bool _isLoading = false;
  late ItemApi _itemApi;
  late int _currentQuantity;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.item.quantity;
    _quantityController =
        TextEditingController(text: _currentQuantity.toString());
    _itemApi = ItemApi();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  // Adjust quantity by adding the specified value
  void _adjustQuantity(int adjustment) {
    final newValue = _currentQuantity + adjustment;
    if (newValue >= 0) {
      setState(() {
        _currentQuantity = newValue;
        _quantityController.text = _currentQuantity.toString();
      });
    }
  }

  Future<void> _updateQuantity() async {
    final newQuantity = int.tryParse(_quantityController.text);

    if (newQuantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'กรุณาระบุจำนวนที่ถูกต้อง',
            style: GoogleFonts.notoSansThai(),
          ),
        ),
      );
      return;
    }

    if (newQuantity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'จำนวนต้องเป็นตัวเลขที่มากกว่าหรือเท่ากับ 0',
            style: GoogleFonts.notoSansThai(),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _itemApi.updateItemQuantity(widget.item.uid, newQuantity);

      if (widget.onQuantityUpdated != null) {
        widget.onQuantityUpdated!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'อัปเดตจำนวนเรียบร้อยแล้ว',
              style: GoogleFonts.notoSansThai(),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'เกิดข้อผิดพลาดในการอัปเดตจำนวน: $e',
              style: GoogleFonts.notoSansThai(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      title: widget.item.name,
      titleColor: Theme.of(context).colorScheme.primary,
      height: 320, // Increased height to accommodate new buttons
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quantity input field and unit
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.notoSansThai(fontSize: 18),
                      onChanged: (value) {
                        // Update current quantity when text field changes
                        setState(() {
                          _currentQuantity =
                              int.tryParse(value) ?? _currentQuantity;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'จำนวน',
                        labelStyle: GoogleFonts.notoSansThai(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.item.unit,
                      style: GoogleFonts.notoSansThai(fontSize: 18),
                    ),
                  ),
                ],
              ),

              // Quick adjustment buttons
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickButton('-5', Colors.red.shade100, Colors.red,
                        () => _adjustQuantity(-5)),
                    _buildQuickButton('-1', Colors.red.shade100, Colors.red,
                        () => _adjustQuantity(-1)),
                    _buildQuickButton('+1', Colors.green.shade100, Colors.green,
                        () => _adjustQuantity(1)),
                    _buildQuickButton('+5', Colors.green.shade100, Colors.green,
                        () => _adjustQuantity(5)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      child: Text(
                        'ยกเลิก',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateQuantity,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'บันทึก',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to create quick adjustment buttons
  Widget _buildQuickButton(String label, Color backgroundColor, Color textColor,
      VoidCallback onPressed) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: GoogleFonts.notoSansThai(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
