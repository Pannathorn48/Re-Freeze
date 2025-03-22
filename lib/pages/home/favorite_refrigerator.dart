import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/services/fonts.dart';

class FavoriteRefrigeratorWidget extends StatelessWidget {
  const FavoriteRefrigeratorWidget({
    super.key,
    required ScrollController favoriteScrollController,
  }) : _favoriteScrollController = favoriteScrollController;

  final ScrollController _favoriteScrollController;

  @override
  Widget build(BuildContext context) {
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
            itemCount: 4,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Card(
                  elevation: 5,
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      width: 150,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ]);
  }
}
