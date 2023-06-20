import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:hajj_app/screens/home.dart';
import 'package:hajj_app/screens/find_me.dart';
import 'package:hajj_app/screens/search.dart';
import 'package:hajj_app/screens/profile.dart';

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
    return SalomonBottomBar(
      currentIndex: widget.currentIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.green,
      margin: const EdgeInsets.only(bottom: 30, top: 10, right: 20, left: 20),
      items: [
        SalomonBottomBarItem(
          icon: const Icon(Icons.home),
          title: const Text("Home"),
          selectedColor: Colors.green,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.explore_outlined),
          title: const Text("Find Me"),
          selectedColor: Colors.green,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.data_usage),
          title: const Text("Search"),
          selectedColor: Colors.green,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.settings),
          title: const Text("Profile"),
          selectedColor: Colors.green,
        ),
      ],
      onTap: (int index) {
        widget.onTap(
            index); // Invoke the onTap callback provided by the parent widget
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FindMeScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            break;
        }
      },
    );
  }
}
