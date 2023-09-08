import 'package:flutter/material.dart';
import 'package:hajj_app/widgets/components/bottom_nav_bar.dart';
import 'package:hajj_app/widgets/pages/first.dart';
import 'package:hajj_app/widgets/pages/second.dart';
import 'package:hajj_app/widgets/pages/third.dart';
import 'package:hajj_app/widgets/pages/fourth.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
