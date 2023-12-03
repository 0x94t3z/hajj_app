import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:hajj_app/screens/auth/forgot.dart';
import 'package:hajj_app/screens/auth/register.dart';
import 'package:hajj_app/screens/features/menu/home.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/helpers/strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int activeIndex = 1;
  late Timer _timer;
  bool _isLoading = false;

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

      // If the user is successfully authenticated, navigate to the home screen
      if (userCredential.user != null) {
        // Successfully signed in
        print('User ID: ${userCredential.user?.uid}');
        print('User Email: ${userCredential.user?.email}');

        // ignore: use_build_context_synchronously
        _navigateToHomeScreen(context);
      }
    } catch (e) {
      // Handle authentication errors here
      print("Error: $e");
      // Display error message to the user if needed
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              height: 30,
            ),
            FadeInDown(
              delay: const Duration(milliseconds: 400),
              child: TextField(
                controller: _emailController,
                cursorColor: ColorSys.primary,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0.0),
                  labelText: 'Email',
                  hintText: 'Your e-mail',
                  labelStyle: const TextStyle(
                    color: ColorSys.primary,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: const TextStyle(
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
                  floatingLabelStyle: const TextStyle(
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
                controller: _passwordController,
                cursorColor: ColorSys.primary,
                obscureText: true, // Set this to true to hide the input text
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0.0),
                  labelText: 'Password',
                  hintText: 'Password',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                  labelStyle: const TextStyle(
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
                  floatingLabelStyle: const TextStyle(
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
            FadeInDown(
              delay: const Duration(milliseconds: 400),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _navigateToForgotPasswordScreen(context);
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400),
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
                    : const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
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
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400),
                  ),
                  TextButton(
                    onPressed: () {
                      _navigateToRegisterScreen(context);
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
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
