// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hajj_app/helpers/app_popup.dart';
import 'package:hajj_app/screens/auth/login.dart';
import 'package:iconsax/iconsax.dart';
import 'package:hajj_app/helpers/name_formatter.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/helpers/strings.dart';
import 'package:hajj_app/services/user_service.dart';
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
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      await showAppPopup(
        context,
        type: AppPopupType.warning,
        title: 'Missing Information',
        message: 'Please fill in name, email, and password.',
      );
      return;
    }

    if (password.length < 6) {
      await showAppPopup(
        context,
        type: AppPopupType.warning,
        title: 'Password Too Short',
        message: 'Password must be at least 6 characters.',
      );
      return;
    }

    final normalizedName = toTitleCaseName(name);
    UserCredential userCredential;

    try {
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Error occurred during registration.';
      if (e.code == 'email-already-in-use') {
        message = 'Email is already in use.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      }
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Registration Failed',
        message: message,
      );
      return;
    } catch (_) {
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Registration Failed',
        message: 'Unable to create your account. Please try again.',
      );
      return;
    }

    final user = userCredential.user;
    if (user == null) {
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Registration Failed',
        message: 'Account was created, but user data is unavailable.',
      );
      return;
    }

    try {
      await user.updateDisplayName(normalizedName);
    } catch (_) {
      // Non-fatal: continue registration flow.
    }

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      position = null;
    }

    final imageUrl = UserService.defaultProfileImageUrl;

    try {
      final usersRef = FirebaseDatabase.instance.ref().child('users');
      await usersRef.child(user.uid).set({
        'userId': user.uid,
        'displayName': normalizedName,
        'email': email,
        'roles': 'Jemaah Haji',
        'latitude': position?.latitude ?? '',
        'longitude': position?.longitude ?? '',
        'imageUrl': imageUrl,
      });
    } catch (_) {
      // Non-fatal: account exists even if profile write fails.
    }

    await showAppPopup(
      context,
      type: AppPopupType.success,
      title: 'Registration Successful',
      message: 'Your account has been created. Please log in.',
    );

    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // Ignore sign-out failures; the login screen will still show.
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
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
        backgroundColor: ColorSys.surface,
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
                      Center(
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorSys.primaryTint,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorSys.primarySoft,
                          ),
                        ),
                      ),
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
                    cursorColor: ColorSys.darkBlue,
                    style: textStyle(
                      color: ColorSys.textPrimary,
                      fontSize: 14.0,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(0.0),
                      labelText: 'Name',
                      hintText: 'Full name',
                      labelStyle: textStyle(
                        color: ColorSys.darkBlue,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                      hintStyle: textStyle(
                        color: ColorSys.textSecondary,
                        fontSize: 14.0,
                      ),
                      prefixIcon: const Icon(
                        Iconsax.user,
                        color: ColorSys.darkBlue,
                        size: 18,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: ColorSys.border, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      floatingLabelStyle: textStyle(
                        color: ColorSys.darkBlue,
                        fontSize: 18.0,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: ColorSys.darkBlue, width: 1.5),
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
                    cursorColor: ColorSys.darkBlue,
                    style: textStyle(
                      color: ColorSys.textPrimary,
                      fontSize: 14.0,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(0.0),
                      labelText: 'Email',
                      hintText: 'Your e-mail',
                      labelStyle: textStyle(
                        color: ColorSys.darkBlue,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                      hintStyle: textStyle(
                        color: ColorSys.textSecondary,
                        fontSize: 14.0,
                      ),
                      prefixIcon: const Icon(
                        Iconsax.sms,
                        color: ColorSys.darkBlue,
                        size: 18,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: ColorSys.border, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      floatingLabelStyle: textStyle(
                        color: ColorSys.darkBlue,
                        fontSize: 18.0,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: ColorSys.darkBlue, width: 1.5),
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
                    cursorColor: ColorSys.darkBlue,
                    obscureText:
                        true, // Set this to true to hide the input text
                    style: textStyle(
                      color: ColorSys.textPrimary,
                      fontSize: 14.0,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(0.0),
                      labelText: 'Password',
                      hintText: 'Password',
                      hintStyle: textStyle(
                        color: ColorSys.textSecondary,
                        fontSize: 14.0,
                      ),
                      labelStyle: textStyle(
                        color: ColorSys.darkBlue,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: const Icon(
                        Iconsax.key,
                        color: ColorSys.darkBlue,
                        size: 18,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: ColorSys.border, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      floatingLabelStyle: textStyle(
                        color: ColorSys.darkBlue,
                        fontSize: 18.0,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: ColorSys.darkBlue, width: 1.5),
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
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await registerWithEmailAndPassword();
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                    color: ColorSys.darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
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
                          color: ColorSys.textSecondary,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Login',
                          style: textStyle(
                            color: ColorSys.darkBlue,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
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
