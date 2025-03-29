import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/api/refrigerator_api.dart';
import 'package:mobile_project/pages/home/favorite_refrigerator_card.dart';
import 'package:mobile_project/services/custom_theme.dart';

class FavoriteRefrigeratorWidget extends StatelessWidget {
  FavoriteRefrigeratorWidget({
    super.key,
    required ScrollController favoriteScrollController,
  }) : _favoriteScrollController = favoriteScrollController;

  final ScrollController _favoriteScrollController;
  final RefrigeratorApi refrigeratorApi = RefrigeratorApi();

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
          child: FutureBuilder(
              future: refrigeratorApi.getFavoriteRefrigerators(
                  FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                return ListView.builder(
                  controller: _favoriteScrollController,
                  itemCount: snapshot.data?.length ?? 0,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return FavoriteRefrigeratorCard(
                      refrigeratorImage:
                          Image.asset("assets/images/no-image.png"),
                      refrigeratorName: snapshot.data![index].name,
                      onTap: () {},
                    );
                  },
                );
              }),
        ),
      ),
    ]);
  }
}
