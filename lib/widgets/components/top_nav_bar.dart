import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
            Iconsax.notification,
            color: Color.fromRGBO(69, 125, 143, 1),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Iconsax.more,
            color: Color.fromRGBO(69, 125, 143, 1),
          ),
          onPressed: () {},
        ),
      ],
      leading: IconButton(
        icon: const Icon(
          Iconsax.menu_1,
          color: Color.fromRGBO(69, 125, 143, 1),
        ),
        onPressed: () {},
      ),
    );
  }
}
