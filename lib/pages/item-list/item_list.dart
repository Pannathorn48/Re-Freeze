import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemListPage extends StatefulWidget {
  final String freezeName = "ตู้เย็น 1";
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
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
    );
  }
}
