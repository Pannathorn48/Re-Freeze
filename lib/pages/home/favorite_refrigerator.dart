import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/models/refrigerators_model.dart';
import 'package:mobile_project/pages/home/favorite_refrigerator_card.dart';
import 'package:mobile_project/services/custom_theme.dart';

class FavoriteRefrigeratorWidget extends StatelessWidget {
  final List<Refrigerator> favoriteRefrigerators;
  const FavoriteRefrigeratorWidget({
    super.key,
    required ScrollController favoriteScrollController,
    required this.favoriteRefrigerators,
  }) : _favoriteScrollController = favoriteScrollController;

  final ScrollController _favoriteScrollController;

  @override
  Widget build(BuildContext context) {
    if (favoriteRefrigerators.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(10),
        child: Text(
          "ไม่มีตู้เย็นที่ชื่นชอบ",
          style: GoogleFonts.notoSansThai(color: CustomColors.grey),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "favorite",
        style: GoogleFonts.notoSansThai(color: CustomColors.grey),
      ),
      Divider(
        color: CustomColors.grey,
      ),
      SizedBox(
        height: 200,
        child: Scrollbar(
          thumbVisibility: true,
          thickness: 3,
          controller: _favoriteScrollController,
          child: ListView.builder(
            controller: _favoriteScrollController,
            itemCount: favoriteRefrigerators.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return FavoriteRefrigeratorCard(
                refrigeratorImage: Image.asset("assets/images/no-image.png"),
                refrigeratorName: favoriteRefrigerators[index].name,
                onTap: () {},
              );
            },
          ),
        ),
      ),
    ]);
  }
}
