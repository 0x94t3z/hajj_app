import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/core/widgets/app_popup.dart';
import 'package:hajj_app/core/utils/name_formatter.dart';
import 'package:hajj_app/core/theme/app_style.dart';
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
  static const String _defaultProfileAsset =
      'assets/images/default_profile.png';

  final UserService _userService = UserService();
  final TextEditingController _imageUrlController = TextEditingController();
  late String _name = '';
  late String _email = '';
  late String _imageUrl = '';
  bool _isLoggingOut = false;

  static const Set<String> _allowedImageUrlHosts = {
    'ibb.co',
    'i.ibb.co',
    'ibb.co.com',
    'i.ibb.co.com',
    'imgur.com',
    'i.imgur.com',
    'firebasestorage.googleapis.com',
    'storage.googleapis.com',
  };

  @override
  void initState() {
    super.initState();
    getData();
    getLostData();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  void getData() async {
    try {
      final cachedProfile = _userService.getCachedCurrentUserProfile();
      if (cachedProfile != null && mounted) {
        setState(() {
          _name =
              toTitleCaseName(cachedProfile['displayName'] as String? ?? '');
          _email = cachedProfile['email'] as String? ?? '';
          _imageUrl = UserService.normalizeProfileImageUrl(
            cachedProfile['imageUrl'] as String?,
          );
        });
      }

      final userData =
          await _userService.fetchCurrentUserProfile(forceRefresh: true);
      if (!mounted) return;
      if (userData != null) {
        setState(() {
          _name = toTitleCaseName(userData['displayName'] as String? ?? '');
          _email = userData['email'] as String? ?? '';
          _imageUrl = UserService.normalizeProfileImageUrl(
            userData['imageUrl'] as String?,
          );
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

  Widget _buildProfileImage(String imageUrl) {
    final normalizedUrl = UserService.normalizeProfileImageUrl(imageUrl);
    if (normalizedUrl.isEmpty ||
        normalizedUrl == UserService.defaultProfileImageUrl) {
      return Image.asset(_defaultProfileAsset, fit: BoxFit.cover);
    }
    return Image.network(
      normalizedUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(_defaultProfileAsset, fit: BoxFit.cover);
      },
    );
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

    if (pickedFile == null) {
      if (mounted) {
        await showAppPopup(
          context,
          type: AppPopupType.warning,
          title: 'Foto Belum Dipilih',
          message: 'Silakan pilih foto untuk memperbarui profil.',
        );
      }
      return;
    }

    try {
      // Generate a random string for the image name
      final randomImageName = randomAlphaNumeric(20);

      // Get a reference to the Firebase Storage location with the random image name
      final storage = FirebaseStorage.instance;
      final user = FirebaseAuth.instance.currentUser!;
      final defaultImageUrl = UserService.defaultProfileImageUrl;

      if (_imageUrl.isNotEmpty && _imageUrl != defaultImageUrl) {
        try {
          final oldRef = FirebaseStorage.instance.refFromURL(_imageUrl);
          await oldRef.delete();
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

      if (mounted) {
        await showAppPopup(
          context,
          type: AppPopupType.success,
          title: 'Foto Diperbarui',
          message: 'Foto profil berhasil diperbarui.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      var message = 'Foto profil tidak dapat diperbarui. Silakan coba lagi.';
      if (e is FirebaseException) {
        if (e.code == 'quota-exceeded' ||
            e.code == 'unauthorized' ||
            e.message?.contains('402') == true) {
          message =
              'Upload foto ditolak oleh Firebase Storage. Periksa billing, kuota, atau aturan Storage.';
        }
      }
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Pembaruan Gagal',
        message: message,
      );
      print('Image update error: $e');
    }
  }

  bool _isAllowedImageUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return false;
    if (uri.scheme != 'https') return false;

    final host = uri.host.toLowerCase();
    return _allowedImageUrlHosts.contains(host) ||
        host.endsWith('.ibb.co') ||
        host.endsWith('.ibb.co.com') ||
        host.endsWith('.imgur.com') ||
        host.endsWith('.googleusercontent.com');
  }

  Future<void> _updateImageFromUrl() async {
    _imageUrlController.text = _imageUrl;
    final imageUrl = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Gunakan URL Foto',
            style: textStyle(
              fontSize: 18,
              color: ColorSys.darkBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _imageUrlController,
            keyboardType: TextInputType.url,
            cursorColor: ColorSys.darkBlue,
            style: textStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'URL gambar',
              hintText: 'https://i.ibb.co.com/...',
              labelStyle: textStyle(
                fontSize: 13,
                color: ColorSys.textSecondary,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorSys.darkBlue),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Batal',
                style: textStyle(
                  fontSize: 13,
                  color: ColorSys.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(_imageUrlController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorSys.darkBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Simpan',
                style: textStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (imageUrl == null) return;
    final normalizedUrl = UserService.normalizeProfileImageUrl(imageUrl);
    if (normalizedUrl.isEmpty || !_isAllowedImageUrl(normalizedUrl)) {
      if (!mounted) return;
      await showAppPopup(
        context,
        type: AppPopupType.warning,
        title: 'URL Tidak Valid',
        message:
            'Gunakan URL gambar HTTPS dari domain yang didukung, misalnya i.ibb.co.com.',
      );
      return;
    }

    try {
      await _userService.updateCurrentUserData({'imageUrl': normalizedUrl});
      if (!mounted) return;
      setState(() {
        _imageUrl = normalizedUrl;
      });
      await showAppPopup(
        context,
        type: AppPopupType.success,
        title: 'Foto Diperbarui',
        message: 'Foto profil berhasil diperbarui dari URL.',
      );
    } catch (e) {
      if (!mounted) return;
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Pembaruan Gagal',
        message: 'URL foto belum dapat disimpan. Silakan coba lagi.',
      );
    }
  }

  Future<void> _showPhotoUpdateOptions() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading:
                      const Icon(Iconsax.gallery, color: ColorSys.darkBlue),
                  title: Text(
                    'Pilih dari Galeri',
                    style: textStyle(
                      fontSize: 14,
                      color: ColorSys.darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Menggunakan Firebase Storage.',
                    style: textStyle(fontSize: 12),
                  ),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
                ListTile(
                  leading: const Icon(Iconsax.link, color: ColorSys.darkBlue),
                  title: Text(
                    'Gunakan URL Gambar',
                    style: textStyle(
                      fontSize: 14,
                      color: ColorSys.darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Contoh: i.ibb.co.com, imgur.com.',
                    style: textStyle(fontSize: 12),
                  ),
                  onTap: () => Navigator.pop(context, 'url'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == 'gallery') {
      await _pickImage();
    } else if (selected == 'url') {
      await _updateImageFromUrl();
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() {
      _isLoggingOut = true;
    });

    try {
      _userService.clearCurrentUserCache();
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (e) {
      if (!mounted) return;
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Keluar Gagal',
        message: 'Akun belum dapat keluar. Silakan coba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
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
          'Profil Saya',
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
                child: _buildProfileImage(_imageUrl),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _showPhotoUpdateOptions,
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
                  'Ubah Foto',
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
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditNameScreen(
                          initialName: _name,
                          updateName: (String newName) async {
                            await updateNameInDatabase(newName);
                            if (!mounted) return;
                            setState(() {
                              _name = toTitleCaseName(newName);
                            });
                            getData();
                          },
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14.0),
                    child: Row(
                      children: [
                        Text(
                          'Nama',
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
            const Spacer(),
            InkWell(
              onTap: _isLoggingOut ? null : _logout,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isLoggingOut
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: ColorSys.darkBlue,
                            ),
                          )
                        : const Icon(
                            Iconsax.logout,
                            color: ColorSys.darkBlue,
                          ),
                    const SizedBox(width: 8),
                    Text(
                      'Keluar',
                      style: textStyle(
                        fontSize: 14,
                        color: ColorSys.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
