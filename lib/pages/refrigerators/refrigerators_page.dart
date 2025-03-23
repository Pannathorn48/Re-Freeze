import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/search_text_input.dart';
import 'package:mobile_project/pages/refrigerators/add_refrigerator_dialog.dart';
import 'package:mobile_project/pages/refrigerators/refrigerator_card.dart';

class RefrigeratorsPage extends StatefulWidget {
  const RefrigeratorsPage({super.key});

  @override
  State<RefrigeratorsPage> createState() => _RefrigeratorsPageState();
}

class _RefrigeratorsPageState extends State<RefrigeratorsPage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 236, 236),
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 20),
          child: Text("ตู้เย็นทั้งหมด",
              style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => const AddRefrigeratorDialog());
        },
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SearchTextInput(controller: _searchController),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                ),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return const RefrigeratorCard();
                }),
          )
        ],
      ),
    );
  }
}
