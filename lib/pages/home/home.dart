import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/services/fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final username = "Pannathorn";
  final TextEditingController searchController = TextEditingController();
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 400,
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  // Background container
                  Container(
                    height: 320,
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Hi, $username",
                          style: GoogleFonts.notoSansThai(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            "assets/images/no-image.png",
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search and category container
                  Positioned(
                    top: 150,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 230,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade500,
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: searchController,
                              style: GoogleFonts.notoSansThai(),
                              onChanged: (value) {
                                setState(() {
                                  searchText = value;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "ค้นหา",
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide:
                                      BorderSide(color: Colors.blue[100]!),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildCategoryIcon(
                                    icon: SvgPicture.asset(
                                        'assets/icons/Refrigerator.svg',
                                        width: 30),
                                    title: "ตู้เย็นทั้งหมด",
                                    onPressed: () {}),
                                _buildCategoryIcon(
                                    icon: const Icon(Icons.warning),
                                    title: "ใกล้หมดอายุ",
                                    onPressed: () {}),
                                _buildCategoryIcon(
                                    icon: const Icon(Icons.shopping_bag),
                                    title: "เหลือน้อย",
                                    onPressed: () {}),
                                _buildCategoryIcon(
                                    icon: const Icon(Icons.add),
                                    title: "เพิ่มรายการ",
                                    onPressed: () {})
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "favorite",
                    style: GoogleFonts.notoSansThai(color: CustomColors.grey),
                  ),
                  Divider(
                    color: CustomColors.grey,
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                        itemCount: 4,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Container(
                              width: 100,
                              color: Colors.green,
                            ),
                          );
                        }),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon({
    required Widget icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
      child: Column(
        children: [
          IconButton(
            onPressed: onPressed,
            icon: icon,
            style: IconButton.styleFrom(
              iconSize: 30,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: Colors.blue[100],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            title,
            style: GoogleFonts.notoSansThai(),
          )
        ],
      ),
    );
  }
}
