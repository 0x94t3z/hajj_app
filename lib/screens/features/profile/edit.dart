import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/screens/features/profile/change_name.dart';
import 'package:iconsax/iconsax.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: ColorSys.primary),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'My Profile',
          style: textStyle(color: ColorSys.primary),
        ),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 30),
            const CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 100,
              backgroundImage: NetworkImage(
                  'https://avatars.githubusercontent.com/u/52822242?v=4'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Handle the button press here
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: ColorSys.lightPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Change Image',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 35),
            Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditNameScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14.0),
                    child: Row(
                      children: [
                        Text(
                          'Name',
                          style: textStyle(
                              fontSize: 14,
                              color: ColorSys.primary,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          'Muhamad Taopik',
                          style: textStyle(
                            fontSize: 14,
                          ),
                        ),
                        const Icon(
                          Iconsax.arrow_right_3,
                          color: ColorSys.primary,
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
                        horizontal: 16.0, vertical: 14.0),
                    child: Row(
                      children: [
                        Text(
                          'Email',
                          style: textStyle(
                              fontSize: 14,
                              color: ColorSys.primary,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const SizedBox(width: 8),
                        Text(
                          'muhamadtaopik007@gmail.com',
                          style: textStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
