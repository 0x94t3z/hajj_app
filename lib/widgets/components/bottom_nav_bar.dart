import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/widgets/pages/first.dart';
import 'package:hajj_app/widgets/pages/second.dart';
import 'package:hajj_app/widgets/pages/third.dart';
import 'package:hajj_app/widgets/pages/fourth.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black12,
      body: IndexedStack(
        index: widget.currentIndex,
        children: const [
          FirstWidget(),
          SecondWidget(),
          ThirdWidget(),
          FourthWidget(),
        ],
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: widget.currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: ColorSys.darkBlue,
        margin: const EdgeInsets.only(bottom: 20, top: 20, right: 20, left: 20),
        onTap: widget.onTap,
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Iconsax.home),
            title: const Text("Home"),
            selectedColor: ColorSys.darkBlue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Iconsax.routing),
            title: const Text("Find Me"),
            selectedColor: ColorSys.darkBlue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Iconsax.search_normal),
            title: const Text("Search"),
            selectedColor: ColorSys.darkBlue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Iconsax.user),
            title: const Text("Profile"),
            selectedColor: ColorSys.darkBlue,
          ),
        ],
      ),
    );
  }
}
