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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: ColorSys.primary),
        title: const Text(
          'My Profile',
          style: TextStyle(color: ColorSys.primary),
        ),
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
                backgroundColor: ColorSys.primary, // Set the text color
                elevation: 0, // Remove the button's elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8.0), // Adjust the border radius as needed
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Change Image',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditNameScreen()),
                );
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    children: [
                      const Text('Name'),
                      const Spacer(),
                      Text(
                        'Muhamad Taopik',
                        style: textStyle(fontSize: 14),
                      ),
                      const Icon(Iconsax.arrow_right_3),
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                // Handle for onTap here
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    children: [
                      const Text('Email'),
                      const Spacer(),
                      const SizedBox(width: 8),
                      Text(
                        'muhamadtaopik007@gmail.com',
                        style: textStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
