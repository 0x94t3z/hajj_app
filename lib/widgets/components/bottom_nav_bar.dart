import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:hajj_app/helpers/styles.dart';

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
          HomeScreen(),
          FindMeScreen(),
          SearchScreen(),
          ProfileScreen(),
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
            icon: const Icon(Icons.home),
            title: const Text("Home"),
            selectedColor: ColorSys.darkBlue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.explore_outlined),
            title: const Text("Find Me"),
            selectedColor: ColorSys.darkBlue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.data_usage),
            title: const Text("Search"),
            selectedColor: ColorSys.darkBlue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.settings),
            title: const Text("Profile"),
            selectedColor: ColorSys.darkBlue,
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Text('Home Screen'),
      ),
    );
  }
}

class FindMeScreen extends StatelessWidget {
  const FindMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Text('Find Me Screen'),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Text('Search Screen'),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}
