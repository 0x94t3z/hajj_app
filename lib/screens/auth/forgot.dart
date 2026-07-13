import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/core/widgets/app_popup.dart';
import 'package:hajj_app/screens/auth/login.dart';
import 'package:iconsax/iconsax.dart';
import 'package:hajj_app/core/theme/app_style.dart';
import 'package:hajj_app/core/constants/onboarding_strings.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _showMessage(
    String message, {
    AppPopupType type = AppPopupType.info,
    String? title,
  }) async {
    if (!mounted) return;
    await showAppPopup(
      context,
      type: type,
      title: title,
      message: message,
    );
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      await _showMessage(
        'Silakan masukkan alamat email.',
        type: AppPopupType.warning,
        title: 'Email Belum Diisi',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      await _showMessage(
        'Tautan reset password telah dikirim ke email Anda.',
        type: AppPopupType.success,
        title: 'Email Terkirim',
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Gagal mengirim email reset password.';
      if (e.code == 'invalid-email') {
        message = 'Alamat email tidak valid.';
      } else if (e.code == 'user-not-found') {
        message = 'Akun dengan email tersebut tidak ditemukan.';
      } else if (e.code == 'too-many-requests') {
        message = 'Terlalu banyak percobaan. Silakan coba lagi nanti.';
      }
      await _showMessage(
        message,
        type: AppPopupType.error,
        title: 'Aksi Gagal',
      );
    } catch (_) {
      await _showMessage(
        'Terjadi kesalahan. Silakan coba lagi.',
        type: AppPopupType.error,
        title: 'Aksi Gagal',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
              const SizedBox(height: 30),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: SizedBox(
                  height: 350,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorSys.primaryTint,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 170,
                          height: 170,
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
                          opacity: 1,
                          duration: const Duration(seconds: 1),
                          curve: Curves.linear,
                          child: Image.asset(
                            OnboardingStrings.stepTwoImage,
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
                  "Lupa Password",
                  style: textStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: ColorSys.darkBlue,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              FadeInDown(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  "Masukkan email untuk mengatur ulang password",
                  textAlign: TextAlign.center,
                  style: contentTextStyle(
                    color: ColorSys.textSecondary,
                    fontSize: 14.0,
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              FadeInDown(
                delay: const Duration(milliseconds: 600),
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
                    suffixIcon: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: textStyle(
                          color: ColorSys.darkBlue,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
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
              const SizedBox(height: 16),
              FadeInDown(
                delay: const Duration(milliseconds: 800),
                child: MaterialButton(
                  minWidth: double.infinity,
                  onPressed: _isLoading ? null : _handleResetPassword,
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
                          "Lanjut",
                          style: textStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
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
