import 'package:flutter/material.dart';
import 'package:hajj_app/screens/features/menu/menu_shell_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MenuShellScreen(initialIndex: 2);
  }
}
