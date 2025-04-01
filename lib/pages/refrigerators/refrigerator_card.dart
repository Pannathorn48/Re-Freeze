import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/custom_bottom_sheet.dart';
import 'package:mobile_project/components/custom_bottom_sheet_input.dart';
import 'package:mobile_project/models/refrigerators_model.dart';
import 'package:mobile_project/pages/refrigerators/edit/edit_refrigerator_dialog.dart';
import 'package:mobile_project/services/image_service.dart';

class RefrigeratorCard extends StatelessWidget {
  final Refrigerator refrigerator;
  final VoidCallback onDelete;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;
  final bool isLoading;
  final String? filterGroupId; // Add parameter for the current filter

  const RefrigeratorCard({
    super.key,
    required this.refrigerator,
    required this.onDelete,
    required this.onFavoriteToggle,
    this.isFavorite = false,
    this.isLoading = false,
    this.filterGroupId, // New parameter
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    String? createdDate;
    if (refrigerator.createdAt != null) {
      createdDate =
          "${refrigerator.createdAt!.day}/${refrigerator.createdAt!.month}/${refrigerator.createdAt!.year}";
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            "/item-list",
            arguments: refrigerator,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image container with consistent height
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Hero(
                tag: 'refrigerator-${refrigerator.uid}',
                child: refrigerator.imageUrl != null &&
                        refrigerator.imageUrl!.isNotEmpty
                    ? Image.network(
                        ImageService.getSignURL(refrigerator.imageUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/images/no-image.png",
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        "assets/images/no-image.png",
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Refrigerator name
                  Text(
                    refrigerator.name,
                    style: GoogleFonts.notoSansThai(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),

                  const SizedBox(height: 4),

                  // Show private/shared status and created date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: refrigerator.isPrivate
                              ? Colors.grey[200]
                              : theme.colorScheme.secondary
                                  .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          refrigerator.isPrivate ? "ส่วนตัว" : "แชร์",
                          style: GoogleFonts.notoSansThai(
                            color: refrigerator.isPrivate
                                ? Colors.grey[700]
                                : theme.colorScheme.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      if (createdDate != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          createdDate,
                          style: GoogleFonts.notoSansThai(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
                      if (refrigerator.users != null &&
                          refrigerator.users!.isNotEmpty) ...[
                        const Spacer(),
                        Icon(
                          Icons.people,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "${refrigerator.users!.length}",
                          style: GoogleFonts.notoSansThai(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Action row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Favorite button
                      isLoading
                          ? const SizedBox(
                              width: 40,
                              height: 40,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: onFavoriteToggle,
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    isFavorite ? Colors.red : Colors.grey[600],
                                size: 22,
                              ),
                              visualDensity: VisualDensity.compact,
                              splashRadius: 20,
                            ),

                      // More options button
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              return CustomBottomSheet(
                                title: refrigerator.name,
                                height: 250,
                                titleColor: primaryColor,
                                children: [
                                  CustomBottomSheetInput(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            EditRefrigeratorDialog(
                                          refrigerator: refrigerator,
                                          filterGroupId:
                                              filterGroupId, // Pass the filter group ID
                                        ),
                                      ).then((refreshNeeded) {
                                        // Handle refresh if returned true
                                        if (refreshNeeded == true) {
                                          // You might need to add a callback for refresh here
                                        }
                                      });
                                    },
                                    text: "แก้ไข",
                                    textColor: primaryColor,
                                    icon: Icon(
                                      Icons.edit,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  CustomBottomSheetInput(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                            'ยืนยันการลบ',
                                            style: GoogleFonts.notoSansThai(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: Text(
                                            'คุณต้องการลบตู้เย็น "${refrigerator.name}" ใช่หรือไม่?',
                                            style: GoogleFonts.notoSansThai(),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(
                                                'ยกเลิก',
                                                style:
                                                    GoogleFonts.notoSansThai(),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                onDelete();
                                              },
                                              child: Text(
                                                'ลบ',
                                                style: GoogleFonts.notoSansThai(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    text: "ลบ",
                                    textColor: Colors.redAccent,
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey[700],
                          size: 22,
                        ),
                        visualDensity: VisualDensity.compact,
                        splashRadius: 20,
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
  }
}
