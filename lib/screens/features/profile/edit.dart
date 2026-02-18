import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/name_formatter.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/screens/features/profile/change_name.dart';
import 'package:hajj_app/services/user_service.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final UserService _userService = UserService();
  late String _name = '';
  late String _email = '';
  late String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    getData();
    getLostData();
  }

  void getData() async {
    try {
      final cachedProfile = _userService.getCachedCurrentUserProfile();
      if (cachedProfile != null && mounted) {
        setState(() {
          _name =
              toTitleCaseName(cachedProfile['displayName'] as String? ?? '');
          _email = cachedProfile['email'] as String? ?? '';
          _imageUrl = cachedProfile['imageUrl'] as String? ?? '';
        });
      }

      final userData =
          await _userService.fetchCurrentUserProfile(forceRefresh: true);
      if (!mounted) return;
      if (userData != null) {
        setState(() {
          _name = toTitleCaseName(userData['displayName'] as String? ?? '');
          _email = userData['email'] as String? ?? '';
          _imageUrl = userData['imageUrl'] as String? ?? '';
        });
      } else {
        print("No data available or data not in the expected format");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  Future<void> updateNameInDatabase(String newName) async {
    await _userService.updateCurrentUserData({
      'displayName': toTitleCaseName(newName),
    });
  }

  Future<void> getLostData() async {
    if (Platform.isAndroid) {
      final ImagePicker picker = ImagePicker();
      final LostDataResponse response = await picker.retrieveLostData();

      if (response.isEmpty) {
        return;
      }

      final List<XFile>? files = response.files;
      if (files != null) {
        _handleLostFiles(files);
      } else {
        _handleError(response.exception);
      }
    }
  }

  void _handleLostFiles(List<XFile> files) {
    // Handle lost files here
    // For instance, update the state with recovered image data
    setState(() {
      // Update state with the recovered images from files list
    });
  }

  void _handleError(Object? exception) {
    // Handle error due to lost data
    print('Error: $exception');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Generate a random string for the image name
      final randomImageName =
          randomAlphaNumeric(20); // Adjust the length as needed

      // Get a reference to the Firebase Storage location with the random image name
      final storage = FirebaseStorage.instance;
      final user = FirebaseAuth.instance.currentUser!;
      final oldImageReference =
          storage.ref().child('images/${user.uid}/$_imageUrl');

      // Check if the selected image is the default image
      final Reference defaultImageReference =
          FirebaseStorage.instance.ref().child('images/default_profile.jpg');
      final defaultImageUrl = await defaultImageReference.getDownloadURL();

      if (_imageUrl != defaultImageUrl) {
        // Delete old image if it's not the default image
        try {
          await oldImageReference.delete();
        } catch (e) {
          print('No old image found or unable to delete old image: $e');
        }
      }

      final reference =
          storage.ref().child('images/${user.uid}/$randomImageName.jpg');

      // Upload the file to Firebase Storage
      await reference.putFile(File(pickedFile.path));

      // Get the download URL from Firebase Storage
      var imageUrl = await reference.getDownloadURL();

      // Update the user's profile image URL in the Realtime Database
      await _userService.updateCurrentUserData({'imageUrl': imageUrl});

      // Update the UI by calling getData() to refresh the image
      getData();
    }
  }

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
            Navigator.pop(
              context,
              {
                'name': toTitleCaseName(_name),
                'imageUrl': _imageUrl,
              },
            );
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
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: ClipOval(
                child: _imageUrl.trim().isNotEmpty
                    ? Image.network(
                        _imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Iconsax.profile_circle,
                              color: ColorSys.darkBlue,
                              size: 48,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Iconsax.profile_circle,
                          color: ColorSys.darkBlue,
                          size: 48,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: ColorSys.darkBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Change Image',
                  style: textStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),
            Column(
              children: [
                InkWell(
                  onTap: () async {
                    String? newName = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditNameScreen(
                          initialName: _name,
                          updateName: (String newName) {
                            setState(() {
                              _name = toTitleCaseName(newName);
                            });
                          },
                        ),
                      ),
                    );

                    if (newName != null && newName.isNotEmpty) {
                      // Update the name in the Realtime Database
                      await updateNameInDatabase(newName);

                      getData();
                    }
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
                              color: ColorSys.darkBlue,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          toTitleCaseName(_name),
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
                              color: ColorSys.darkBlue,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const SizedBox(width: 8),
                        Text(
                          _email,
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
