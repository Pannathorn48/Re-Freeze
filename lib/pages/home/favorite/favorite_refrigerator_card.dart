import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/models/refrigerators_model.dart';
import 'package:mobile_project/services/image_service.dart';

class FavoriteRefrigeratorCard extends StatelessWidget {
  final String? refrigeratorImagePath;
  final String refrigeratorName;
  final Refrigerator refrigerator; // Add the refrigerator object
  final void Function() onTap;

  const FavoriteRefrigeratorCard({
    super.key,
    required this.refrigeratorImagePath,
    required this.refrigeratorName,
    required this.refrigerator, // Required parameter
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
      child: Card(
        elevation: 5,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            // Pass the refrigerator object to the item list page
            Navigator.pushNamed(
              context,
              "/item-list",
              arguments: refrigerator,
            );
          },
          child: Ink(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: _buildImage(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    refrigeratorName,
                    style: GoogleFonts.notoSansThai(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (refrigeratorImagePath == null) {
      return Image.asset(
        "assets/images/no-image.png",
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        refrigeratorImagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            "assets/images/no-image.png",
            fit: BoxFit.cover,
          );
        },
      );
    }
  }
}
