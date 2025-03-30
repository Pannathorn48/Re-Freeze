import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/custom_bottom_sheet.dart';
import 'package:mobile_project/components/custom_bottom_sheet_input.dart';
import 'package:mobile_project/models/refrigerators_model.dart';
import 'package:mobile_project/services/image_service.dart';

class RefrigeratorCard extends StatelessWidget {
  final Refrigerator refrigerator;
  final VoidCallback onDelete;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;
  final bool isLoading;

  const RefrigeratorCard({
    super.key,
    required this.refrigerator,
    required this.onDelete,
    required this.onFavoriteToggle,
    this.isFavorite = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // Pass the entire refrigerator object instead of just the ID
          Navigator.pushNamed(
            context,
            "/item-list",
            arguments: refrigerator, // Pass the full refrigerator object
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              refrigerator.imageUrl != null && refrigerator.imageUrl!.isNotEmpty
                  ? Image.network(
                      ImageService.getSignURL(refrigerator.imageUrl!),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/no-image.png",
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      "assets/images/no-image.png",
                      width: 100,
                      height: 100,
                    ),
              const SizedBox(height: 25),
              Text(
                refrigerator.name,
                style: GoogleFonts.notoSansThai(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // This is the fixed part - show loading indicator when isLoading is true
                  isLoading
                      ? const SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: onFavoriteToggle,
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                        ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return CustomBottomSheet(
                            title: refrigerator.name,
                            height: 250,
                            titleColor: Theme.of(context).colorScheme.primary,
                            children: [
                              CustomBottomSheetInput(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    "/edit-refrigerator",
                                    arguments: refrigerator,
                                  );
                                },
                                text: "แก้ไข",
                                icon: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                textColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 10),
                              CustomBottomSheetInput(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Show confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        'ยืนยันการลบ',
                                        style: GoogleFonts.notoSansThai(),
                                      ),
                                      content: Text(
                                        'คุณต้องการลบตู้เย็น "${refrigerator.name}" ใช่หรือไม่?',
                                        style: GoogleFonts.notoSansThai(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            'ยกเลิก',
                                            style: GoogleFonts.notoSansThai(),
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
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
