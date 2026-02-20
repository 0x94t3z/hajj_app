import 'package:flutter/material.dart';
import 'package:hajj_app/screens/features/menu/tabs/find_my_tab.dart';
import 'package:hajj_app/screens/features/menu/tabs/home_clock_tab.dart';
import 'package:hajj_app/screens/features/menu/tabs/settings_tab.dart';
import 'package:hajj_app/widgets/components/bottom_nav_bar.dart';
import 'package:hajj_app/widgets/components/top_nav_bar.dart';

class MenuShellScreen extends StatefulWidget {
  const MenuShellScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  final int initialIndex;

  @override
  State<MenuShellScreen> createState() => _MenuShellScreenState();
}

class _MenuShellScreenState extends State<MenuShellScreen> {
  late int _currentIndex;
  int _findMyRefreshTick = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 2);
  }

  void _setCurrentTab(int index) {
    setState(() {
      if (index == 1 && _currentIndex != 1) {
        _findMyRefreshTick++;
      }
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex != 2
          ? TopNavBar(
              onSettingTap: () => _setCurrentTab(2),
              onMyProfileTap: () => _setCurrentTab(2),
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeClockTab(),
          FindMyTab(refreshTick: _findMyRefreshTick),
          const SettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _setCurrentTab,
      ),
    );
  }
}
