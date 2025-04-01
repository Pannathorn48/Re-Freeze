import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/tag_api.dart';
import 'package:mobile_project/components/button.dart';
import 'package:mobile_project/models/item_model.dart';

class TagFilterDialog extends StatefulWidget {
  final List<Tag> selectedTags;
  final Function(List<Tag>) onApplyFilter;

  const TagFilterDialog({
    Key? key,
    required this.selectedTags,
    required this.onApplyFilter,
  }) : super(key: key);

  @override
  State<TagFilterDialog> createState() => _TagFilterDialogState();
}

class _TagFilterDialogState extends State<TagFilterDialog> {
  late List<Tag> _selectedTags;
  late Future<List<Tag>> _tagsFuture;
  final TagApi _tagApi = TagApi();

  @override
  void initState() {
    super.initState();
    // Create a copy of the selected tags list
    _selectedTags = List.from(widget.selectedTags);
    _tagsFuture = _fetchTags();
  }

  Future<List<Tag>> _fetchTags() async {
    try {
      return await _tagApi.getTags();
    } catch (e) {
      // Return empty list if tags can't be fetched
      return [];
    }
  }

  void _toggleTag(Tag tag) {
    setState(() {
      if (_selectedTags.any((t) => t.uid == tag.uid)) {
        _selectedTags.removeWhere((t) => t.uid == tag.uid);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
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
                    child: Text(
                      "กรองตาม Tag",
                      style: GoogleFonts.notoSansThai(
                        fontSize: 22,
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
            const SizedBox(height: 16),
            Text(
              "เลือก Tags ที่ต้องการกรอง",
              style: GoogleFonts.notoSansThai(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Tag>>(
                future: _tagsFuture,
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

                  final tags = snapshot.data ?? [];

                  if (tags.isEmpty) {
                    return Center(
                      child: Text(
                        'ไม่พบ Tags',
                        style: GoogleFonts.notoSansThai(),
                      ),
                    );
                  }

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      final isSelected =
                          _selectedTags.any((t) => t.uid == tag.uid);
                      return FilterChip(
                        selected: isSelected,
                        selectedColor: tag.color.withOpacity(0.8),
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,
                        label: Text(
                          tag.name,
                          style: GoogleFonts.notoSansThai(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        side: BorderSide(
                          color: tag.color,
                          width: 1,
                        ),
                        onSelected: (selected) {
                          _toggleTag(tag);
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button(
                  onPressed: () {
                    setState(() {
                      _selectedTags = [];
                    });
                  },
                  text: "ล้างตัวกรอง",
                  width: 150,
                  height: 40,
                  fontColor: Colors.black87,
                  overlayColor: Colors.black12,
                  backgroundColor: Colors.white,
                ),
                Button(
                  onPressed: () {
                    widget.onApplyFilter(_selectedTags);
                    Navigator.of(context).pop();
                  },
                  text: "นำไปใช้",
                  width: 150,
                  height: 40,
                  fontColor: Colors.white,
                  overlayColor: Colors.white24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
