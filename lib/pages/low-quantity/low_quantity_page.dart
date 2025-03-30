import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_project/api/item_api.dart';
import 'package:mobile_project/models/item_model.dart';
import 'package:mobile_project/services/custom_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/services/image_service.dart';

class LowQuantityScreen extends StatefulWidget {
  final int minQuantity;

  const LowQuantityScreen({
    super.key,
    this.minQuantity = 5, // Default threshold
  });

  @override
  State<LowQuantityScreen> createState() => _LowQuantityScreenState();
}

class _LowQuantityScreenState extends State<LowQuantityScreen> {
  final ItemApi _itemApi = ItemApi();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Item> _lowQuantityItems = [];
  Map<String, String> _refrigeratorNames = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool _isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  // Initialize the Thai locale for date formatting
  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('th', null);
      setState(() {
        _isLocaleInitialized = true;
      });
      _loadItems();
    } catch (e) {
      setState(() {
        _isLocaleInitialized = false;
        _isLoading = false;
        _errorMessage = "เกิดข้อผิดพลาดในการตั้งค่าภาษา: $e";
      });
    }
  }

  Future<void> _loadItems() async {
    if (!_isLocaleInitialized) {
      await _initializeLocale();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "ไม่พบข้อมูลผู้ใช้";
        });
        return;
      }

      // Get all refrigerators this user has access to
      final refrigeratorsSnapshot = await _firestore
          .collection('refrigerators')
          .where('users', arrayContains: user.uid)
          .get();

      // Store refrigerator names
      final Map<String, String> names = {};
      for (final doc in refrigeratorsSnapshot.docs) {
        if (doc.exists && doc.data().containsKey('name')) {
          names[doc.id] = doc.data()['name'];
        } else {
          names[doc.id] = 'ตู้เย็นที่ไม่ทราบชื่อ';
        }
      }

      // Use the ItemApi method to get low quantity items
      final lowQuantityItems = await _itemApi.getLowQuantityItems(
        user.uid,
        minQuantity: widget.minQuantity,
      );

      setState(() {
        _lowQuantityItems = lowQuantityItems;
        _refrigeratorNames = names;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "เกิดข้อผิดพลาดในการโหลดข้อมูล: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.greyBackground,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "รายการของที่เหลือน้อย",
          style: GoogleFonts.notoSansThai(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadItems,
            tooltip: 'รีเฟรช',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('กำลังโหลดข้อมูล...'),
                ],
              ),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : _lowQuantityItems.isEmpty
                  ? _buildEmptyView()
                  : _buildItemsList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: CustomColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: GoogleFonts.notoSansThai(
                color: CustomColors.error,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadItems,
              icon: const Icon(Icons.refresh),
              label: Text(
                'ลองอีกครั้ง',
                style: GoogleFonts.notoSansThai(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            "ไม่มีรายการของที่เหลือน้อย",
            style: GoogleFonts.notoSansThai(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "ทุกอย่างดูดีอยู่!",
            style: GoogleFonts.notoSansThai(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _lowQuantityItems.length,
      itemBuilder: (context, index) {
        final item = _lowQuantityItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(Item item) {
    String formatDate(DateTime date) {
      try {
        if (_isLocaleInitialized) {
          return DateFormat('dd MMM yyyy', 'th').format(date);
        } else {
          return DateFormat('dd/MM/yyyy').format(date);
        }
      } catch (e) {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    }

    final expiryDateString = formatDate(item.expiryDate);
    final refrigeratorName =
        _refrigeratorNames[item.refrigeratorId] ?? 'ตู้เย็นที่ไม่ทราบชื่อ';

    // Calculate percentage remaining
    final percentRemaining = (item.quantity / widget.minQuantity) * 100;
    final isVeryLow = item.quantity <= (widget.minQuantity / 2);

    // Color based on quantity
    final statusColor = isVeryLow
        ? CustomColors.error
        : Colors.orange; // Warning color for low but not critical

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Status indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              isVeryLow ? 'เหลือน้อยมาก' : 'เหลือน้อย',
              style: GoogleFonts.notoSansThai(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          ImageService.getSignURL(item.imageUrl),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.food_bank,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                ),

                const SizedBox(width: 16),

                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item name
                      Text(
                        item.name,
                        style: GoogleFonts.notoSansThai(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Refrigerator name
                      Row(
                        children: [
                          const Icon(
                            Icons.kitchen,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              refrigeratorName,
                              style: GoogleFonts.notoSansThai(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Quantity with progress indicator
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: isVeryLow
                                    ? CustomColors.error
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "จำนวน: ${item.quantity} ${item.unit}",
                                style: GoogleFonts.notoSansThai(
                                  color: isVeryLow
                                      ? CustomColors.error
                                      : Colors.grey[800],
                                  fontWeight: isVeryLow
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Progress bar showing quantity status
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: item.quantity / widget.minQuantity,
                              backgroundColor: Colors.grey[200],
                              color: statusColor,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Expiry date
                      Row(
                        children: [
                          const Icon(
                            Icons.event,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "วันหมดอายุ: $expiryDateString",
                            style: GoogleFonts.notoSansThai(
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Tags
                      if (item.tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (var tag in item.tags)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: tag.color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag.name,
                                  style: GoogleFonts.notoSansThai(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to item detail page
                    Navigator.pushNamed(
                      context,
                      '/item-list',
                      arguments: item.refrigeratorId,
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: Text(
                    'ดูรายละเอียด',
                    style: GoogleFonts.notoSansThai(),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
