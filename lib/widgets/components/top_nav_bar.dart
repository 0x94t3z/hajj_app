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
      actions: const [
        // IconButton(
        //   icon: const Icon(
        //     Iconsax.notification,
        //     color: Color.fromRGBO(69, 125, 143, 1),
        //   ),
        //   onPressed: () {},
        // ),
        // IconButton(
        //   icon: const Icon(
        //     Iconsax.user,
        //     color: Color.fromRGBO(69, 125, 143, 1),
        //   ),
        //   onPressed: () {},
        // ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
                'https://avatars.githubusercontent.com/u/52822242?v=4'), // Replace with your profile image URL
          ),
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
