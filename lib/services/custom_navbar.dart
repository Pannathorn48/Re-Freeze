import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_project/pages/group/group_page.dart';
import 'package:mobile_project/pages/home/home_page.dart';
import 'package:mobile_project/pages/refrigerators/refrigerators_page.dart';
import 'package:mobile_project/services/custom_theme.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    super.key,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  List widgetOptions = <Widget>[
    const HomePage(),
    const RefrigeratorsPage(),
    const GroupPage(),
    Text("Setting")
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.greyBackground,
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (value) => setState(() => _selectedIndex = value),
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  "assets/icons/Refrigerator.svg",
                  height: 17,
                  colorFilter: const ColorFilter.mode(
                      Color.fromRGBO(117, 117, 117, 1), BlendMode.srcIn),
                ),
                activeIcon: SvgPicture.asset(
                  "assets/icons/Refrigerator.svg",
                  height: 17,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary, BlendMode.srcIn),
                ),
                label: "Freeze"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.group), label: "Group"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Setting"),
          ]),
    );
  }
}
