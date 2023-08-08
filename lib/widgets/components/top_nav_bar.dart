import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications,
            color: Color.fromRGBO(69, 125, 143, 1),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.more_vert,
            color: Color.fromRGBO(69, 125, 143, 1),
          ),
          onPressed: () {},
        ),
      ],
      leading: IconButton(
        icon: const Icon(
          Icons.menu,
          color: Color.fromRGBO(69, 125, 143, 1),
        ),
        onPressed: () {},
      ),
    );
  }
}
