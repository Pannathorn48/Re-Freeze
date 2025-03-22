import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteRefrigeratorCard extends StatelessWidget {
  final Image refrigeratorImage;
  final String refrigeratorName;
  final void Function() onTap;
  const FavoriteRefrigeratorCard(
      {super.key,
      required this.refrigeratorImage,
      required this.refrigeratorName,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
      child: Card(
        elevation: 5,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {},
          child: Ink(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    width: 80,
                    child: refrigeratorImage,
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
}
