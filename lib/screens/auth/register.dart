// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hajj_app/core/widgets/app_popup.dart';
import 'package:hajj_app/screens/auth/login.dart';
import 'package:iconsax/iconsax.dart';
import 'package:hajj_app/core/utils/name_formatter.dart';
import 'package:hajj_app/core/theme/app_style.dart';
import 'package:hajj_app/core/constants/onboarding_strings.dart';
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
  bool _obscurePassword = true;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController kloterController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> registerWithEmailAndPassword() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final kloter = kloterController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || kloter.isEmpty || password.isEmpty) {
      await showAppPopup(
        context,
        type: AppPopupType.warning,
        title: 'Data Belum Lengkap',
        message: 'Silakan isi nama, email, kloter, dan password.',
      );
      return;
    }

    if (password.length < 6) {
      await showAppPopup(
        context,
        type: AppPopupType.warning,
        title: 'Password Terlalu Pendek',
        message: 'Kata sandi minimal 6 karakter.',
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
      String message = 'Terjadi kesalahan saat pendaftaran.';
      if (e.code == 'email-already-in-use') {
        message = 'Email sudah digunakan.';
      } else if (e.code == 'invalid-email') {
        message = 'Alamat email tidak valid.';
      } else if (e.code == 'weak-password') {
        message = 'Kata sandi terlalu lemah.';
      }
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Pendaftaran Gagal',
        message: message,
      );
      return;
    } catch (_) {
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Pendaftaran Gagal',
        message: 'Akun tidak dapat dibuat. Silakan coba lagi.',
      );
      return;
    }

    final user = userCredential.user;
    if (user == null) {
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Pendaftaran Gagal',
        message: 'Akun berhasil dibuat, tetapi data akun belum tersedia.',
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

    try {
      final usersRef = FirebaseDatabase.instance.ref().child('users');
      await usersRef.child(user.uid).set({
        'userId': user.uid,
        'displayName': normalizedName,
        'email': email,
        'roles': 'Jemaah Haji',
        'kloter': kloter,
        'latitude': position?.latitude ?? '',
        'longitude': position?.longitude ?? '',
        'imageUrl': '',
      });
    } catch (_) {
      try {
        await user.delete();
      } catch (_) {
        // If deletion fails, keep the account but still report profile failure.
      }
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Pendaftaran Gagal',
        message:
            'Akun tidak dapat menyimpan data profil. Silakan coba daftar kembali.',
      );
      return;
    }

    await showAppPopup(
      context,
      type: AppPopupType.success,
      title: 'Pendaftaran Berhasil',
      message: 'Akun berhasil dibuat. Silakan masuk.',
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
    nameController.dispose();
    emailController.dispose();
    kloterController.dispose();
    passwordController.dispose();
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
                            OnboardingStrings.stepOneImage,
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
                            OnboardingStrings.stepTwoImage,
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
                            OnboardingStrings.stepThreeImage,
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
                            OnboardingStrings.stepTwoImage,
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
                      labelText: 'Nama',
                      hintText: 'Nama lengkap',
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
                      hintText: 'Alamat email',
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
                    controller: kloterController,
                    cursorColor: ColorSys.darkBlue,
                    keyboardType: TextInputType.text,
                    style: textStyle(
                      color: ColorSys.textPrimary,
                      fontSize: 14.0,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(0.0),
                      labelText: 'Kloter',
                      hintText: 'Nomor kloter',
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
                        Iconsax.people,
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
                    obscureText: _obscurePassword,
                    style: textStyle(
                      color: ColorSys.textPrimary,
                      fontSize: 14.0,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(0.0),
                      labelText: 'Password',
                      hintText: 'Kata sandi',
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
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
                          color: ColorSys.darkBlue,
                          size: 18,
                        ),
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
                            "Daftar",
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
                        'Sudah punya akun?',
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
                          'Masuk',
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
