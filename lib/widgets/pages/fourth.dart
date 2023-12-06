import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/screens/features/profile/edit.dart';
import 'package:iconsax/iconsax.dart';
import 'package:package_info/package_info.dart';

class FourthWidget extends StatefulWidget {
  const FourthWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FourthWidgetState createState() => _FourthWidgetState();
}

class _FourthWidgetState extends State<FourthWidget> {
  late String imageUrl = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    userRef.once().then((DatabaseEvent event) {
      if (mounted) {
        DataSnapshot snapshot = event.snapshot;
        var userData = snapshot.value;
        if (userData != null && userData is Map) {
          setState(() {
            imageUrl = userData['imageUrl'] as String? ?? '';
          });
        } else {
          print("No data available or data not in the expected format");
        }
      }
    }).catchError((error) {
      print("Error fetching data: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Assuming user data structure is similar to the real-time database structure
      String name = user.displayName ?? "";
      String email = user.email ?? "";

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
                      onTap: () async {
                        final updatedImageUrl = await Navigator.push<String?>(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditScreen()),
                        );

                        // Update the image URL in the state when receiving the updated URL
                        setState(() {
                          imageUrl = updatedImageUrl ?? imageUrl;
                        });
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
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                          backgroundColor: imageUrl.isNotEmpty
                              ? Colors.transparent
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        name,
                        style: textStyle(
                          fontSize: 24,
                          color: ColorSys.darkBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
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
                                    Iconsax.profile_tick,
                                    color: ColorSys.darkBlue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Status',
                                    style: textStyle(
                                      fontSize: 14,
                                      color: ColorSys.darkBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Jemaah Haji',
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
                      const Divider(),
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
                                Iconsax.unlock,
                                color: ColorSys.darkBlue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Change Password',
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
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'About',
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
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () async {
                          // Perform Firebase sign-out
                          try {
                            await FirebaseAuth.instance.signOut();
                            // Navigate to the login screen after successfully logging out
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacementNamed(context, '/login');
                          } catch (e) {
                            // Handle sign-out errors, if any
                            print("Error while logging out: $e");
                            // Display error message or take appropriate action
                          }
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
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '  Version ${packageInfo?.version ?? 'N/A'}',
                            style: textStyle(fontSize: 12),
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
    } else {
      // Handle if the user is not logged in
      // You might want to redirect the user to the login screen
      return const Scaffold(
        body: Center(
          child: Text('User not logged in!'),
        ),
      );
    }
  }
}
