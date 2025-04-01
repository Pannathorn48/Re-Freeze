import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_project/api/item_api.dart';
import 'package:mobile_project/pages/item-detail/item_detail_page.dart';
import 'package:mobile_project/services/custom_theme.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  final ItemApi _itemApi = ItemApi();
  int expiredCount = 0;
  int warningCount = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Safe setState that checks if widget is still mounted
  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _loadNotifications() async {
    if (_disposed) return;

    _safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _safeSetState(() {
          _isLoading = false;
          _errorMessage = "ไม่พบข้อมูลผู้ใช้";
        });
        return;
      }

      // Get expired and warning items
      final expiredItems = await _itemApi.getExpiredItems(user.uid);
      final warningItems = await _itemApi.getWarningItems(user.uid);

      // Check if widget is still mounted before updating state
      if (!mounted || _disposed) return;

      // Update state with counts
      _safeSetState(() {
        expiredCount = expiredItems.length;
        warningCount = warningItems.length;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      if (!mounted || _disposed) return;

      _safeSetState(() {
        _isLoading = false;
        _errorMessage = "เกิดข้อผิดพลาดในการโหลดข้อมูล";
      });
    }
  }

  void _navigateToExpiredItems() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemListScreen(type: ItemListType.expired),
      ),
    );
  }

  void _navigateToWarningItems() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemListScreen(type: ItemListType.warning),
      ),
    );
  }

  void _navigateToAllItems() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemListScreen(type: ItemListType.all),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = expiredCount + warningCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("notification",
                style: GoogleFonts.notoSansThai(color: CustomColors.grey)),
            if (totalCount > 0)
              TextButton(
                onPressed: _navigateToAllItems,
                child: Text(
                  "ดูทั้งหมด",
                  style: GoogleFonts.notoSansThai(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        Divider(
          color: CustomColors.grey,
        ),
        const SizedBox(height: 10),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_errorMessage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.notoSansThai(color: CustomColors.error),
              ),
            ),
          )
        else
          Column(
            children: [
              _buildNotificationCard(
                title: "มีของหมดอายุทั้งหมด ",
                count: expiredCount,
                onTap: _navigateToExpiredItems,
                icon: Icons.error_rounded,
                backgroundColor: CustomColors.errorBackground,
                primaryColor: CustomColors.error,
              ),
              const SizedBox(height: 10),
              _buildNotificationCard(
                title: "มีของที่ใกล้หมดอายุทั้งหมด ",
                count: warningCount,
                onTap: _navigateToWarningItems,
                icon: Icons.warning_rounded,
                backgroundColor: CustomColors.warningBackground,
                primaryColor: CustomColors.warning,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required int count,
    required VoidCallback onTap,
    required IconData icon,
    required Color backgroundColor,
    required Color primaryColor,
  }) {
    return Card(
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 50,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.notoSansThai(
                        fontSize: 16, color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 40,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    count.toString(),
                    style: GoogleFonts.notoSansThai(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  " รายการ",
                  style: GoogleFonts.notoSansThai(
                      fontSize: 18, color: Colors.black),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
