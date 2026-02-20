import 'package:flutter/material.dart';
import 'package:hajj_app/screens/features/menu/tabs/find_my_tab.dart';
import 'package:hajj_app/screens/features/menu/tabs/home_clock_tab.dart';
import 'package:hajj_app/screens/features/menu/settings_screen.dart';
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
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 2);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _setCurrentTab(int index, {bool animated = false}) {
    if (index < 0 || index > 2) return;

    if (index == 1 && _currentIndex != 1) {
      setState(() {
        _findMyRefreshTick++;
      });
    }

    if (index == _currentIndex && _pageController.hasClients) return;

    if (!_pageController.hasClients) {
      setState(() {
        _currentIndex = index;
      });
      return;
    }

    if (animated) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    if (_currentIndex == index) return;
    setState(() {
      if (index == 1 && _currentIndex != 1) {
        _findMyRefreshTick++;
      }
      _currentIndex = index;
    });
  }

  void _openSettingsWithLeftSlide() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: animation.drive(slide),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex != 2
          ? TopNavBar(
              onSettingTap: _openSettingsWithLeftSlide,
              onMyProfileTap: () => _setCurrentTab(2, animated: true),
            )
          : null,
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: _onPageChanged,
        children: [
          const HomeClockTab(),
          FindMyTab(refreshTick: _findMyRefreshTick),
          const SettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => _setCurrentTab(index, animated: true),
      ),
    );
  }
}
