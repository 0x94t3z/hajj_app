import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:hajj_app/helpers/styles.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SalomonBottomBar(
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: ColorSys.darkBlue,
      margin: const EdgeInsets.only(bottom: 20, top: 20, right: 20, left: 20),
      onTap: onTap,
      items: [
        SalomonBottomBarItem(
          icon: const Icon(Iconsax.home),
          title: const Text("Home"),
          selectedColor: ColorSys.darkBlue,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Iconsax.radar_1),
          title: const Text("Find Me"),
          selectedColor: ColorSys.darkBlue,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Iconsax.star_1),
          title: const Text("Contact"),
          selectedColor: ColorSys.darkBlue,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Iconsax.setting_2),
          title: const Text("Settings"),
          selectedColor: ColorSys.darkBlue,
        ),
      ],
    );
  }
}
