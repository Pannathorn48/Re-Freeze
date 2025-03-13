import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/models/item.dart';

class ItemListPage extends StatefulWidget {
  final String freezeName = "ตู้เย็น 1";
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  late final Item testItem;
  late final List<Item> items;

  @override
  void initState() {
    super.initState();
    testItem = Item(
      name: "ไข่ไก่",
      quantity: 10,
      expiryDate: DateTime.now(),
      imageUrl: "test",
      tags: [Tag(name: "Hello", color: Colors.red)],
      unit: "ฟอง",
    );
    items = [testItem];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          leading: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
          title: Text(
            widget.freezeName,
            style: GoogleFonts.notoSansThai(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.error_rounded,
                  color: Colors.white,
                ))
          ],
        ),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: SizedBox(
                width: double.infinity,
                height: 150,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Image.asset(
                      'assets/images/no-image.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "ชื่อ: ",
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: items[index].name,
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "จำนวน ",
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      "${items[index].quantity} ${items[index].unit}",
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "วันหมดอายุ ",
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: items[index].expiryDateString,
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: items[index]
                                  .tags
                                  .map((tag) => Chip(
                                        side: BorderSide(
                                            color: tag.color, width: 1),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        backgroundColor: tag.color,
                                        label: Text(
                                          tag.name,
                                          style: GoogleFonts.notoSansThai(
                                              color: Colors.white,
                                              fontSize: 10),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Add your edit functionality here
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
