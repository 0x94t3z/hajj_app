import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/screens/features/profile/edit.dart';
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
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.white,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditScreen()),
                      );
                    },
                    child: Text(
                      'Edit',
                      style: textStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            body: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
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
                        color: ColorSys.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'muhamadtaopik007@gmail.com',
                      style: textStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'General',
                          style: textStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            // Handle for onTap here
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.notification,
                                  color: ColorSys.darkBlue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Notification',
                                  style: textStyle(
                                    fontSize: 14,
                                    color: ColorSys.darkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Iconsax.arrow_right_3,
                                  color: ColorSys.darkBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(), // Add a Divider here
                        InkWell(
                          onTap: () {
                            // Handle for onTap here
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.translate,
                                  color: ColorSys.darkBlue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Language',
                                  style: textStyle(
                                    fontSize: 14,
                                    color: ColorSys.darkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(width: 8),
                                Text(
                                  'English',
                                  style: textStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                const Icon(
                                  Iconsax.arrow_right_3,
                                  color: ColorSys.darkBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Support',
                          style: textStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            // Handle for onTap here
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.flag,
                                  color: ColorSys.darkBlue,
                                ),
                                const SizedBox(width: 8),
                                Text('Notices',
                                    style: textStyle(
                                        fontSize: 14,
                                        color: ColorSys.darkBlue,
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                const Icon(
                                  Iconsax.arrow_right_3,
                                  color: ColorSys.darkBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        InkWell(
                          onTap: () {
                            // Handle for onTap here
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.shield_tick,
                                  color: ColorSys.darkBlue,
                                ),
                                const SizedBox(width: 8),
                                Text('Terms and Policies',
                                    style: textStyle(
                                        fontSize: 14,
                                        color: ColorSys.darkBlue,
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                const Icon(
                                  Iconsax.arrow_right_3,
                                  color: ColorSys.darkBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        InkWell(
                          onTap: () {
                            // Handle for onTap here
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.info_circle,
                                  color: ColorSys.darkBlue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'App Version',
                                  style: textStyle(
                                      fontSize: 14,
                                      color: ColorSys.darkBlue,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                const SizedBox(width: 8),
                                Text(
                                  'Latest',
                                  style: textStyle(fontSize: 14),
                                ),
                                const Icon(
                                  Iconsax.arrow_right_3,
                                  color: ColorSys.darkBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.logout,
                              color: ColorSys.darkBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: textStyle(
                                  fontSize: 14,
                                  color: ColorSys.darkBlue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Version ${packageInfo?.version ?? 'N/A'}',
                          style: textStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
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
