import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/core/widgets/app_popup.dart';
import 'package:hajj_app/services/user_service.dart';
import 'package:iconsax/iconsax.dart';
import 'package:hajj_app/screens/auth/forgot.dart';
import 'package:hajj_app/screens/auth/register.dart';
import 'package:hajj_app/screens/features/menu/home_screen.dart';
import 'package:hajj_app/core/theme/app_style.dart';
import 'package:hajj_app/core/constants/onboarding_strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int activeIndex = 1;
  late Timer _timer;
  bool _isLoading = false;
  bool _obscurePassword = true;

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

  void _navigateToHomeScreen(BuildContext context) {
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder:
              (_, Animation<double> animation, __, Widget child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ));
  }

  void _navigateToForgotPasswordScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ForgotPasswordScreen(),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToRegisterScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RegisterScreen(),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void _loginUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        final firebaseUser = userCredential.user!;
        _userService.seedCacheFromAuthUser(firebaseUser);
        if (!mounted) return;
        _navigateToHomeScreen(context);

        // Refresh in background so UI can render instantly with cached values.
        unawaited(() async {
          final profileData = await _userService.primeCurrentUserCache();
          final name =
              (profileData?['displayName']?.toString().trim().isNotEmpty ??
                      false)
                  ? profileData!['displayName'].toString().trim()
                  : (firebaseUser.displayName?.trim().isNotEmpty ?? false)
                      ? firebaseUser.displayName!.trim()
                      : 'Unknown User';
          final roles =
              (profileData?['roles']?.toString().trim().isNotEmpty ?? false)
                  ? profileData!['roles'].toString().trim()
                  : 'Unknown Role';
          debugPrint(
            '[LOGIN] name=$name, roles=$roles',
          );
        }());

        return;
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (e.code == 'wrong-password') {
        await showAppPopup(
          context,
          type: AppPopupType.error,
          title: 'Login Failed',
          message: 'The password is incorrect. Please try again.',
        );
      } else if (e.code == 'user-not-found') {
        await showAppPopup(
          context,
          type: AppPopupType.warning,
          title: 'Login Failed',
          message: 'No user found for that email.',
        );
      } else {
        await showAppPopup(
          context,
          type: AppPopupType.error,
          title: 'Login Failed',
          message: e.message ?? 'Something went wrong while logging in.',
        );
      }
    }
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
                  height: 30,
                ),
                FadeInDown(
                  delay: const Duration(milliseconds: 400),
                  child: TextField(
                    controller: _emailController,
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
                    controller: _passwordController,
                    cursorColor: ColorSys.darkBlue,
                    obscureText: _obscurePassword,
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
                FadeInDown(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _navigateToForgotPasswordScreen(context);
                        },
                        child: Text(
                          'Forgot Password?',
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
                const SizedBox(
                  height: 30,
                ),
                FadeInDown(
                  delay: const Duration(milliseconds: 600),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });

                      Future.delayed(const Duration(seconds: 2), () {
                        // setState(() {
                        //   _isLoading = false;
                        // });
                        _loginUser();
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => const HomeScreen()));
                      });
                    },
                    color: ColorSys.darkBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
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
                            "Login",
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
                        'Don\'t have an account?',
                        style: textStyle(
                          color: ColorSys.textSecondary,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _navigateToRegisterScreen(context);
                        },
                        child: Text(
                          'Register',
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
