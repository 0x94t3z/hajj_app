import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/styles.dart';

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
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: ColorSys.darkBlue,
          ),
          onPressed: onMapTap,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkResponse(
              onTap: onSettingsTap,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                        image: NetworkImage(
                            'https://avatars.githubusercontent.com/u/52822242?v=4'),
                        fit: BoxFit.cover)),
                child: Transform.translate(
                  offset: const Offset(15, -15),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(width: 3, color: Colors.white),
                        shape: BoxShape.circle,
                        color: Colors.green),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
