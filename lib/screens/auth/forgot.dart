import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/screens/auth/login.dart';
import 'package:iconsax/iconsax.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/helpers/strings.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;

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
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: AnimatedOpacity(
                          opacity: 1,
                          duration: const Duration(seconds: 1),
                          curve: Curves.linear,
                          child: Image.asset(
                            Strings.stepTwoImage,
                            height: 400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FadeInDown(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  "Forgot Password",
                  style: titleTextStyle(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              FadeInDown(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  "Enter your email address to reset your password",
                  textAlign: TextAlign.center,
                  style: contentTextStyle(
                      color: Colors.grey.shade700, fontSize: 14.0),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              FadeInDown(
                delay: const Duration(milliseconds: 600),
                child: TextField(
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
                height: 30,
              ),
              FadeInDown(
                delay: const Duration(milliseconds: 800),
                child: MaterialButton(
                  minWidth: double.infinity,
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });

                    Future.delayed(const Duration(seconds: 2), () {
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                    });
                  },
                  color: ColorSys.darkBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
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
                          "Next",
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
