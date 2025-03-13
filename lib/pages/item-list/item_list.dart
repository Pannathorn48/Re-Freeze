import 'package:flutter/material.dart';
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
      tags: [],
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
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return Container();
          }),
    );
  }
}
