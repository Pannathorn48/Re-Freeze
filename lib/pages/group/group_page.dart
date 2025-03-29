import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_project/components/custom_float_button.dart';
import 'package:mobile_project/models/group_model.dart';
import 'package:mobile_project/pages/group/group_card.dart';
import 'package:mobile_project/pages/group/group_create.dart';
import 'package:mobile_project/services/custom_theme.dart';

final groups = <Group>[
  Group(
      name: "test",
      color: Colors.deepOrangeAccent,
      creatorName: 'hello 1',
      description: 'this is for test'),
  Group(
      name: "ลูก",
      color: Colors.lightBlueAccent,
      creatorName: 'hello 2',
      description: 'this is for my child\' sweet'),
  Group(
      name: "พ่อครัว",
      color: Colors.indigoAccent,
      creatorName: 'hello 3',
      description: 'this is for my ketchen and chef')
];

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  Future<void> test() async {
    print("hello");
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return Scaffold(
      backgroundColor: CustomColors.greyBackground,
      appBar: AppBar(
        title: Text("Groups",
            style: GoogleFonts.notoSansThai(
                color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Scrollbar(
          controller: scrollController,
          thickness: 3,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return GroupCard(group: groups[index]);
                }),
          ),
        ),
      ),
      floatingActionButton: CustomFloatButton(onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return const CreateGroupDialog();
            });
      }),
    );
  }
}
