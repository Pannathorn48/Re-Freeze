import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/group_api.dart';
import 'package:mobile_project/components/custom_float_button.dart';
import 'package:mobile_project/models/group_model.dart';
import 'package:mobile_project/pages/group/group_card.dart';
import 'package:mobile_project/pages/group/group_create.dart';
import 'package:mobile_project/pages/group/group_edit.dart';
import 'package:mobile_project/pages/group/group_confirm_delete.dart';
import 'package:mobile_project/services/custom_theme.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final GroupApi _groupApi = GroupApi();
  bool _isLoading = false;
  List<Group> _groups = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    // Check if the widget is still mounted before updating state
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final groups = await _groupApi.getUserGroups();
      // Check again if the widget is still mounted after the async call
      if (!mounted) return;

      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      // Check again if the widget is still mounted after the async call
      if (!mounted) return;

      setState(() {
        _errorMessage = "ไม่สามารถโหลดข้อมูลกลุ่มได้: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshGroups() async {
    await _loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.greyBackground,
      appBar: AppBar(
        title: Text(
          "Groups",
          style: GoogleFonts.notoSansThai(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _refreshGroups,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: CustomFloatButton(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => const CreateGroupDialog(),
          );

          // Check if widget is still mounted and if dialog returned true
          if (mounted && result == true) {
            _refreshGroups();
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: GoogleFonts.notoSansThai(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshGroups,
              child: Text(
                "ลองใหม่",
                style: GoogleFonts.notoSansThai(),
              ),
            ),
          ],
        ),
      );
    }

    if (_groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              "ยังไม่มีกลุ่ม",
              style: GoogleFonts.notoSansThai(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "สร้างกลุ่มใหม่หรือเข้าร่วมกลุ่มที่มีอยู่แล้ว",
              style: GoogleFonts.notoSansThai(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => const CreateGroupDialog(),
                );

                // Check if widget is still mounted and if dialog returned true
                if (mounted && result == true) {
                  _refreshGroups();
                }
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: Text(
                "สร้างหรือเข้าร่วมกลุ่ม",
                style: GoogleFonts.notoSansThai(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshGroups,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80), // Add padding for FAB
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          return GroupCard(
            group: _groups[index],
            onGroupChanged: _refreshGroups,
          );
        },
      ),
    );
  }
}
