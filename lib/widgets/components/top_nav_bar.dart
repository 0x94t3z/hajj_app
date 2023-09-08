import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsTap;
  final VoidCallback onMapTap;

  const TopNavBar({
    Key? key,
    required this.onSettingsTap,
    required this.onMapTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: InkResponse(
              onTap: onSettingsTap,
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://avatars.githubusercontent.com/u/52822242?v=4',
                ),
              ),
            ),
          )
        ],
        leading: IconButton(
          icon: const Icon(
            Iconsax.menu_1,
            color: Color.fromRGBO(69, 125, 143, 1),
          ),
          onPressed: onMapTap,
        ),
      ),
    );
  }
}
