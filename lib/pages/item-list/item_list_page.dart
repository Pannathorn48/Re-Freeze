import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/custom_bottom_sheet.dart';
import 'package:mobile_project/components/custom_bottom_sheet_input.dart';
import 'package:mobile_project/models/item.dart';
import 'package:mobile_project/pages/item-list/_item_add_dialog.dart';
import 'package:mobile_project/pages/item-list/_item_edit_bottom_sheet.dart';

class ItemListPage extends StatefulWidget {
  final String freezeName = "ตู้เย็น 1";
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  late final Item testItem;
  late final List<Item> items;
  String searchText = "";
  TextEditingController searchController = TextEditingController();

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
    items = [testItem, testItem, testItem, testItem];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 236, 236),
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
                Icons.info_outline,
                color: Colors.white,
              ))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.blue[100]!),
                          )),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.filter_list))
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: SizedBox(
                    width: double.infinity,
                    height: 170,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Image.asset(
                          'assets/images/no-image.png',
                          width: 130,
                          height: 130,
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
                                                    BorderRadius.circular(20)),
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
                            icon: const Icon(Icons.more_horiz_outlined),
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return EditBottomSheet(
                                        title: items[index].name);
                                  });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.lightBlue,
        shape: const CircleBorder(),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AddItemDialog();
              });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
