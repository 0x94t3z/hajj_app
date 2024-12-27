// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hajj_app/screens/auth/login.dart';
import 'package:iconsax/iconsax.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/helpers/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int activeIndex = 2;
  late Timer _timer;
  bool _isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> registerWithEmailAndPassword() async {
    try {
      // Fetching current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Creating user account with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Update the user's display name
      await userCredential.user!.updateDisplayName(nameController.text.trim());
      String userId = userCredential.user!.uid;

      // Get the download URL for the default image from Firebase Storage
      Reference storageRef =
          FirebaseStorage.instance.ref().child('images/default_profile.jpg');
      String imageUrl = await storageRef.getDownloadURL();

      // Additional: Save longitude and latitude to Realtime Database along with imageUrl
      DatabaseReference usersRef =
          FirebaseDatabase.instance.ref().child('users');
      usersRef.child(userId).set({
        'userId': userId,
        'displayName': nameController.text.trim(),
        'email': emailController.text.trim(),
        'roles': 'Jemaah Haji',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'imageUrl': imageUrl,
      });

      // Registration successful - Show success message using SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
        ),
      );

      // Registration successful - Navigate to the next screen or perform actions accordingly
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      // Handle registration errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred during registration: $e'),
        ),
      );
      print('Error occurred during registration: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        activeIndex++;

        if (activeIndex == 4) activeIndex = 0;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: SizedBox(
                height: 350,
                child: Stack(children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: activeIndex == 0 ? 1 : 0,
                      duration: const Duration(
                        seconds: 1,
                      ),
                      curve: Curves.linear,
                      child: Image.asset(
                        Strings.stepOneImage,
                        height: 400,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: activeIndex == 1 ? 1 : 0,
                      duration: const Duration(seconds: 1),
                      curve: Curves.linear,
                      child: Image.asset(
                        Strings.stepTwoImage,
                        height: 400,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: activeIndex == 2 ? 1 : 0,
                      duration: const Duration(seconds: 1),
                      curve: Curves.linear,
                      child: Image.asset(
                        Strings.stepThreeImage,
                        height: 400,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: activeIndex == 3 ? 1 : 0,
                      duration: const Duration(seconds: 1),
                      curve: Curves.linear,
                      child: Image.asset(
                        Strings.stepTwoImage,
                        height: 400,
                      ),
                    ),
                  )
                ]),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            FadeInDown(
              delay: const Duration(milliseconds: 400),
              child: TextField(
                controller: nameController,
                cursorColor: ColorSys.primary,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0.0),
                  labelText: 'Name',
                  hintText: 'Full name',
                  labelStyle: textStyle(
                    color: ColorSys.primary,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: textStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                  prefixIcon: const Icon(
                    Iconsax.user,
                    color: ColorSys.primary,
                    size: 18,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade200, width: 2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  floatingLabelStyle: textStyle(
                    color: ColorSys.primary,
                    fontSize: 18.0,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: ColorSys.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            FadeInDown(
              delay: const Duration(milliseconds: 400),
              child: TextField(
                controller: emailController,
                cursorColor: ColorSys.primary,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0.0),
                  labelText: 'Email',
                  hintText: 'Your e-mail',
                  labelStyle: textStyle(
                    color: ColorSys.primary,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: textStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                  prefixIcon: const Icon(
                    Iconsax.sms,
                    color: ColorSys.primary,
                    size: 18,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade200, width: 2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  floatingLabelStyle: textStyle(
                    color: ColorSys.primary,
                    fontSize: 18.0,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: ColorSys.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            FadeInDown(
              delay: const Duration(milliseconds: 400),
              child: TextField(
                controller: passwordController,
                cursorColor: ColorSys.primary,
                obscureText: true, // Set this to true to hide the input text
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0.0),
                  labelText: 'Password',
                  hintText: 'Password',
                  hintStyle: textStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                  labelStyle: textStyle(
                    color: ColorSys.primary,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Iconsax.key,
                    color: ColorSys.primary,
                    size: 18,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade200, width: 2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  floatingLabelStyle: textStyle(
                    color: ColorSys.primary,
                    fontSize: 18.0,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: ColorSys.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            FadeInDown(
              delay: const Duration(milliseconds: 600),
              child: MaterialButton(
                minWidth: double.infinity,
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });

                  // Call the registration method and handle registration
                  registerWithEmailAndPassword().then((_) {
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  }).catchError((error) {
                    setState(() {
                      _isLoading = false;
                    });
                    // Handle registration error, show a snackbar, or display an error message
                    print("Registration error: $error");
                  });
                },
                color: ColorSys.darkBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          color: ColorSys.darkBlue,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Register",
                        style: textStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            FadeInDown(
              delay: const Duration(milliseconds: 800),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: textStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Login',
                      style: textStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
