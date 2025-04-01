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

enum ItemListType { expired, warning, all }

class ItemListScreen extends StatefulWidget {
  final ItemListType type;

  const ItemListScreen({
    super.key,
    required this.type,
  });

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen>
    with SingleTickerProviderStateMixin {
  final ItemApi _itemApi = ItemApi();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Item> _expiredItems = [];
  List<Item> _warningItems = [];
  Map<String, String> _refrigeratorNames = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool _isLocaleInitialized = false;

  TabController? _tabController;
  bool _showTabs = false;

  @override
  void initState() {
    super.initState();

    // If type is 'all', initialize tab controller and set showTabs to true
    if (widget.type == ItemListType.all) {
      _tabController = TabController(length: 2, vsync: this);
      _showTabs = true;
    }

    _initializeLocale();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
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

      // Load items based on type
      List<Item> expiredItems = [];
      List<Item> warningItems = [];

      // For 'all' type or 'expired' type, load expired items
      if (widget.type == ItemListType.all ||
          widget.type == ItemListType.expired) {
        expiredItems = await _itemApi.getExpiredItems(user.uid);
      }

      // For 'all' type or 'warning' type, load warning items
      if (widget.type == ItemListType.all ||
          widget.type == ItemListType.warning) {
        warningItems = await _itemApi.getWarningItems(user.uid);
      }

      // Get unique refrigerator IDs from both lists
      final Set<String> refrigeratorIds = {};
      for (var item in expiredItems) {
        refrigeratorIds.add(item.refrigeratorId);
      }
      for (var item in warningItems) {
        refrigeratorIds.add(item.refrigeratorId);
      }

      // Fetch refrigerator names
      final Map<String, String> names = {};
      for (final id in refrigeratorIds) {
        try {
          final doc =
              await _firestore.collection('refrigerators').doc(id).get();
          if (doc.exists && doc.data()!.containsKey('name')) {
            names[id] = doc.data()!['name'];
          } else {
            names[id] = 'ตู้เย็นที่ไม่ทราบชื่อ';
          }
        } catch (e) {
          names[id] = 'ตู้เย็นที่ไม่ทราบชื่อ';
        }
      }

      setState(() {
        _expiredItems = expiredItems;
        _warningItems = warningItems;
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

  String _getTimeUntilExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);

    if (difference.isNegative) {
      final days = difference.inDays.abs();
      return days == 0 ? 'หมดอายุวันนี้' : 'หมดอายุแล้ว $days วัน';
    } else {
      final days = difference.inDays;
      return days == 0 ? 'หมดอายุวันนี้' : 'เหลืออีก $days วัน';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.greyBackground,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _getAppBarTitle(),
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
        bottom: _showTabs
            ? TabBar(
                labelStyle: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.error_outline),
                    text: 'หมดอายุ (${_expiredItems.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.warning_amber_outlined),
                    text: 'ใกล้หมดอายุ (${_warningItems.length})',
                  ),
                ],
              )
            : null,
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
              : _showTabs
                  ? _buildTabView()
                  : _buildSingleTypeView(),
    );
  }

  String _getAppBarTitle() {
    switch (widget.type) {
      case ItemListType.expired:
        return "รายการของที่หมดอายุ";
      case ItemListType.warning:
        return "รายการของที่ใกล้หมดอายุ";
      case ItemListType.all:
        return "รายการของที่มีการแจ้งเตือน";
    }
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

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        // Expired items tab
        _expiredItems.isEmpty
            ? _buildEmptyView(true)
            : _buildItemsList(_expiredItems, true),

        // Warning items tab
        _warningItems.isEmpty
            ? _buildEmptyView(false)
            : _buildItemsList(_warningItems, false),
      ],
    );
  }

  Widget _buildSingleTypeView() {
    final isExpiredType = widget.type == ItemListType.expired;
    final items = isExpiredType ? _expiredItems : _warningItems;

    return items.isEmpty
        ? _buildEmptyView(isExpiredType)
        : _buildItemsList(items, isExpiredType);
  }

  Widget _buildEmptyView(bool isExpiredType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isExpiredType ? Icons.check_circle_outline : Icons.thumb_up,
            color: isExpiredType
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            isExpiredType
                ? "ไม่มีรายการของที่หมดอายุ"
                : "ไม่มีรายการของที่ใกล้หมดอายุ",
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

  Widget _buildItemsList(List<Item> items, bool isExpiredType) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item, isExpiredType);
      },
    );
  }

  Widget _buildItemCard(Item item, bool isExpiredType) {
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
    final timeUntilExpiry = _getTimeUntilExpiry(item.expiryDate);

    final isExpired = item.expiryDate.isBefore(DateTime.now());
    final statusColor = isExpired ? CustomColors.error : CustomColors.warning;

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
              isExpired ? 'หมดอายุแล้ว' : 'ใกล้หมดอายุ',
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

                      const SizedBox(height: 4),

                      // Quantity
                      Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "จำนวน: ${item.quantity} ${item.unit}",
                            style: GoogleFonts.notoSansThai(
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Expiry date
                      Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 16,
                            color: isExpired ? CustomColors.error : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "วันหมดอายุ: $expiryDateString",
                            style: GoogleFonts.notoSansThai(
                              color: isExpired
                                  ? CustomColors.error
                                  : Colors.grey[800],
                              fontWeight: isExpired
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Time until expiry
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          timeUntilExpiry,
                          style: GoogleFonts.notoSansThai(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
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
        ],
      ),
    );
  }
}
