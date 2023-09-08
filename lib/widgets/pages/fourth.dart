import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:iconsax/iconsax.dart';
import 'package:package_info/package_info.dart';

class FourthWidget extends StatelessWidget {
  const FourthWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final packageInfo = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 20),
                  child: GestureDetector(
                    // onTap: navigateToLogin,
                    child: Text(
                      'Edit',
                      style: textStyle(fontSize: 18),
                    ),
                  ),
                )
              ],
            ),
            body: Align(
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                        'https://avatars.githubusercontent.com/u/52822242?v=4'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Muhamad Taopik',
                    style: textStyle(
                        fontSize: 24,
                        color: ColorSys.primary,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'muhamadtaopik007@gmail.com',
                    style: textStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'General',
                        style: textStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Card(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Iconsax.notification, color: ColorSys.darkBlue),
                          SizedBox(width: 8),
                          Text('Notification',
                              style: TextStyle(color: ColorSys.darkBlue)),
                          Spacer(),
                          Icon(Iconsax.arrow_right_3, color: ColorSys.darkBlue),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          const Icon(Iconsax.translate,
                              color: ColorSys.darkBlue),
                          const SizedBox(width: 8),
                          const Text('Language',
                              style: TextStyle(color: ColorSys.darkBlue)),
                          const Spacer(),
                          const SizedBox(
                              width:
                                  8), // Add spacing between the arrow and the text
                          Text(
                            'English',
                            style: textStyle(fontSize: 14),
                          ),
                          const Icon(Iconsax.arrow_right_3,
                              color: ColorSys.darkBlue),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Support',
                        style: textStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Card(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Iconsax.flag, color: ColorSys.darkBlue),
                          SizedBox(width: 8),
                          Text('Notices',
                              style: TextStyle(color: ColorSys.darkBlue)),
                          Spacer(),
                          Icon(Iconsax.arrow_right_3, color: ColorSys.darkBlue),
                        ],
                      ),
                    ),
                  ),
                  const Card(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Iconsax.shield_tick, color: ColorSys.darkBlue),
                          SizedBox(width: 8),
                          Text('Terms and Polices',
                              style: TextStyle(color: ColorSys.darkBlue)),
                          Spacer(),
                          Icon(Iconsax.arrow_right_3, color: ColorSys.darkBlue),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          const Icon(Iconsax.info_circle,
                              color: ColorSys.darkBlue),
                          const SizedBox(width: 8),
                          const Text('App Version',
                              style: TextStyle(color: ColorSys.darkBlue)),
                          const Spacer(),
                          const SizedBox(
                              width:
                                  8), // Add spacing between the arrow and the text
                          Text(
                            'Latest',
                            style: textStyle(fontSize: 14),
                          ),
                          const Icon(Iconsax.arrow_right_3,
                              color: ColorSys.darkBlue),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        packageInfo?.version ?? 'N/A',
                        style: textStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Show a loading indicator while fetching package info
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
