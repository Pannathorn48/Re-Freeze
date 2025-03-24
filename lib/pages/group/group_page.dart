import 'package:flutter/material.dart';
import 'package:mobile_project/components/custom_float_button.dart';
import 'package:mobile_project/services/custom_theme.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.greyBackground,
      floatingActionButton: CustomFloatButton(onPressed: () {}),
    );
  }
}
