import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  List widgetOptions = <Widget>[
    Text("Home"),
    Text("About"),
    Text("Setting"),
    Text("Setting")
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (value) => setState(() => _selectedIndex = value),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(FontAwesome5.snowflake), label: "Freeze"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Setting"),
          ]),
    );
  }
}
