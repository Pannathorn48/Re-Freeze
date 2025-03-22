import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RefrigeratorCard extends StatelessWidget {
  const RefrigeratorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset("assets/images/no-image.png",
                  width: 100, height: 100),
              const SizedBox(height: 25),
              Text(
                "Refrigerator Name",
                style: GoogleFonts.notoSansThai(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border)),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.more_vert))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
