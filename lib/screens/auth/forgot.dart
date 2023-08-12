import 'package:flutter/material.dart';
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
              SizedBox(
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
              Text(
                "Forgot Password",
                style: titleTextStyle(),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Enter your email address to reset your password",
                textAlign: TextAlign.center,
                style: contentTextStyle(
                    color: Colors.grey.shade700, fontSize: 14.0),
              ),
              const SizedBox(
                height: 50,
              ),
              TextField(
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
              const SizedBox(
                height: 30,
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                height: 45,
                color: ColorSys.darkBlue,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
