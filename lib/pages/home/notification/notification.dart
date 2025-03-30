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

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
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

      // Get expired and warning items
      final expiredItems = await _itemApi.getExpiredItems(user.uid);
      final warningItems = await _itemApi.getWarningItems(user.uid);

      // Update state with counts
      setState(() {
        expiredCount = expiredItems.length;
        warningCount = warningItems.length;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("notification",
            style: GoogleFonts.notoSansThai(color: CustomColors.grey)),
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
                Text(
                  title,
                  style: GoogleFonts.notoSansThai(
                      fontSize: 16, color: Colors.black),
                ),
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
