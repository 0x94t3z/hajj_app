import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/core/widgets/app_popup.dart';
import 'package:hajj_app/core/theme/app_style.dart';
import 'package:iconsax/iconsax.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _handleChangePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      await _showMessage(
        'Silakan lengkapi semua kolom password.',
        type: AppPopupType.warning,
        title: 'Data Belum Lengkap',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      await _showMessage(
        'Kata sandi baru dan konfirmasi tidak sama.',
        type: AppPopupType.warning,
        title: 'Password Tidak Sama',
      );
      return;
    }

    if (newPassword.length < 6) {
      await _showMessage(
        'Kata sandi baru minimal 6 karakter.',
        type: AppPopupType.warning,
        title: 'Password Terlalu Pendek',
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      await _showMessage(
        'Akun tidak ditemukan. Silakan masuk kembali.',
        type: AppPopupType.error,
        title: 'Aksi Gagal',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      if (!mounted) return;
      await _showMessage(
        'Kata sandi berhasil diperbarui.',
        type: AppPopupType.success,
        title: 'Berhasil',
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Gagal memperbarui password.';
      if (e.code == 'wrong-password') {
        message = 'Kata sandi saat ini salah.';
      } else if (e.code == 'weak-password') {
        message = 'Kata sandi baru terlalu lemah.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Silakan masuk kembali untuk memperbarui password.';
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
        'Terjadi kesalahan saat memperbarui password.',
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    required IconData prefixIcon,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          cursorColor: ColorSys.darkBlue,
          style: textStyle(
            color: ColorSys.textPrimary,
            fontSize: 14.0,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(0.0),
            labelText: label,
            labelStyle: textStyle(
              color: ColorSys.darkBlue,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
            hintStyle: textStyle(
              color: ColorSys.textSecondary,
              fontSize: 14.0,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: ColorSys.darkBlue,
              size: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: ColorSys.border, width: 2),
              borderRadius: BorderRadius.circular(10.0),
            ),
            floatingLabelStyle: textStyle(
              color: ColorSys.darkBlue,
              fontSize: 18.0,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: ColorSys.darkBlue, width: 1.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscureText ? Iconsax.eye : Iconsax.eye_slash,
                color: ColorSys.darkBlue,
                size: 18,
              ),
            ),
          ),
        ),
        if (helperText != null && helperText.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            helperText,
            style: textStyle(
              fontSize: 12,
              color: ColorSys.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: ColorSys.darkBlue),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ubah Password',
          style: textStyle(
            color: ColorSys.darkBlue,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            _buildPasswordField(
              controller: _currentPasswordController,
              label: 'Password Saat Ini',
              obscureText: _obscureCurrent,
              onToggle: () {
                setState(() {
                  _obscureCurrent = !_obscureCurrent;
                });
              },
              prefixIcon: Iconsax.lock_1,
              helperText: 'Masukkan password saat ini.',
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'Password Baru',
              obscureText: _obscureNew,
              onToggle: () {
                setState(() {
                  _obscureNew = !_obscureNew;
                });
              },
              prefixIcon: Iconsax.shield_tick,
              helperText: 'Kata sandi minimal 6 karakter.',
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Konfirmasi Password',
              obscureText: _obscureConfirm,
              onToggle: () {
                setState(() {
                  _obscureConfirm = !_obscureConfirm;
                });
              },
              prefixIcon: Iconsax.tick_circle,
              helperText: 'Harus sama dengan password baru.',
            ),
            const SizedBox(height: 24),
            MaterialButton(
              minWidth: double.infinity,
              onPressed: _isLoading ? null : _handleChangePassword,
              color: ColorSys.darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
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
                      'Perbarui Password',
                      style: textStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
