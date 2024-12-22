import 'package:flutter/material.dart';
import 'package:hajj_app/widgets/components/top_nav_bar.dart';
import 'package:hajj_app/widgets/components/bottom_nav_bar.dart';
import 'package:hajj_app/widgets/pages/first.dart';
import 'package:hajj_app/widgets/pages/second.dart';
import 'package:hajj_app/widgets/pages/third.dart';
import 'package:hajj_app/widgets/pages/fourth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex != 3
          ? TopNavBar(
              onSettingsTap: () {
                // Handle Settings tap (_currentIndex = 3)
                setState(() {
                  _currentIndex = 3;
                });
              },
              onMyProfileTap: () {
                // Handle My Profile tap (_currentIndex = 3)
                setState(() {
                  _currentIndex = 3;
                });
              },
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          FirstWidget(),
          SecondWidget(),
          ThirdWidget(),
          FourthWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
