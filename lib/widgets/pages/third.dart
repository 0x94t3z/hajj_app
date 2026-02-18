import 'dart:convert';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/name_formatter.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/screens/features/help/help_inbox.dart';
import 'package:hajj_app/screens/features/profile/edit.dart';
import 'package:hajj_app/services/help_service.dart';
import 'package:hajj_app/services/user_service.dart';
import 'package:iconsax/iconsax.dart';
import 'package:package_info/package_info.dart';

class ThirdWidget extends StatefulWidget {
  const ThirdWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ThirdWidgetState createState() => _ThirdWidgetState();
}

class _ThirdWidgetState extends State<ThirdWidget> {
  final UserService _userService = UserService();
  final HelpService _helpService = HelpService();
  late String _name = '';
  late String _email = '';
  late String _imageUrl = '';
  late String _roles = '';
  StreamSubscription<List<HelpConversationSummary>>? _helpInboxSubscription;
  int _totalUnreadHelpMessages = 0;

  @override
  void initState() {
    super.initState();
    getData();
    _watchUnreadHelpMessages();
  }

  @override
  void dispose() {
    _helpInboxSubscription?.cancel();
    super.dispose();
  }

  Future<void> _watchUnreadHelpMessages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final role = await _userService.fetchCurrentUserRole();
    final isPetugas = _userService.isPetugasHajiRole(role);

    await _helpInboxSubscription?.cancel();
    _helpInboxSubscription = _helpService
        .watchInbox(
      currentUid: user.uid,
      currentIsPetugas: isPetugas,
    )
        .listen(
      (conversations) {
        if (!mounted) return;
        final total = conversations.fold<int>(
          0,
          (sum, item) => sum + item.unreadMessageCount,
        );
        setState(() {
          _totalUnreadHelpMessages = total;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _totalUnreadHelpMessages = 0;
        });
      },
    );
  }

  void updateName(String newName) {
    setState(() {
      _name = toTitleCaseName(newName);
    });
  }

  void getData() async {
    try {
      final cachedProfile = _userService.getCachedCurrentUserProfile();
      if (cachedProfile != null && mounted) {
        final cachedRoleRaw = cachedProfile['roles'] as String? ?? '';
        final cachedRoleStatus = _userService.isPetugasHajiRole(cachedRoleRaw)
            ? 'Petugas Haji'
            : 'Jemaah Haji';
        setState(() {
          _name =
              toTitleCaseName(cachedProfile['displayName'] as String? ?? '');
          _email = cachedProfile['email'] as String? ?? '';
          _imageUrl = cachedProfile['imageUrl'] as String? ?? '';
          _roles = cachedRoleStatus;
        });
      }

      final rawUserData =
          await _userService.fetchCurrentUserData(forceRefresh: true);
      final userData =
          await _userService.fetchCurrentUserProfile(forceRefresh: true);
      debugPrint(
        '[SETTINGS] rawUserData=${jsonEncode(rawUserData ?? <String, dynamic>{})}',
      );
      debugPrint(
        '[SETTINGS] resolvedProfile=${jsonEncode(userData ?? <String, dynamic>{})}',
      );
      if (!mounted) return;
      if (userData != null) {
        final roleRaw = userData['roles'] as String? ?? '';
        final roleStatus = _userService.isPetugasHajiRole(roleRaw)
            ? 'Petugas Haji'
            : 'Jemaah Haji';
        setState(() {
          _name = toTitleCaseName(userData['displayName'] as String? ?? '');
          _email = userData['email'] as String? ?? '';
          _imageUrl = userData['imageUrl'] as String? ?? '';
          _roles = roleStatus;
        });
      } else {
        print("No data available or data not in the expected format");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final packageInfo = snapshot.data;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.white,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 20),
                  child: GestureDetector(
                    onTap: () async {
                      final updatedData =
                          await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditScreen()),
                      );

                      if (updatedData != null) {
                        setState(() {
                          _name = toTitleCaseName(updatedData['name'] ?? '');
                          _imageUrl = updatedData['imageUrl'];
                        });
                      }
                    },
                    child: Text(
                      'Edit',
                      style: textStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            body: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: ClipOval(
                        child: _imageUrl.trim().isNotEmpty
                            ? Image.network(
                                _imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Iconsax.profile_circle,
                                      color: ColorSys.darkBlue,
                                      size: 48,
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Icon(
                                  Iconsax.profile_circle,
                                  color: ColorSys.darkBlue,
                                  size: 48,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      toTitleCaseName(_name),
                      style: textStyle(
                        fontSize: 24,
                        color: ColorSys.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _email,
                      style: textStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'General',
                          style: textStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            // Handle for onTap here
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.profile_tick,
                                  color: ColorSys.darkBlue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Status',
                                  style: textStyle(
                                    fontSize: 14,
                                    color: ColorSys.darkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(width: 8),
                                Text(
                                  _roles,
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
                      ],
                    ),
                    const Divider(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpInboxScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.message_question,
                              color: ColorSys.darkBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Help Requests',
                              style: textStyle(
                                fontSize: 14,
                                color: ColorSys.darkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              constraints: const BoxConstraints(minWidth: 28),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _totalUnreadHelpMessages > 0
                                    ? Colors.red
                                    : Colors.white,
                                border: Border.all(
                                  color: _totalUnreadHelpMessages > 0
                                      ? Colors.red
                                      : ColorSys.darkBlue.withValues(
                                          alpha: 0.4,
                                        ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _totalUnreadHelpMessages > 99
                                    ? '99+'
                                    : _totalUnreadHelpMessages.toString(),
                                style: textStyle(
                                  fontSize: 11,
                                  color: _totalUnreadHelpMessages > 0
                                      ? Colors.white
                                      : ColorSys.darkBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.unlock,
                              color: ColorSys.darkBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Change Password',
                              style: textStyle(
                                fontSize: 14,
                                color: ColorSys.darkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Iconsax.arrow_right_3,
                              color: ColorSys.darkBlue,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'About',
                          style: textStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            // Handle for onTap here
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.shield_tick,
                                  color: ColorSys.darkBlue,
                                ),
                                const SizedBox(width: 8),
                                Text('Terms and Policies',
                                    style: textStyle(
                                        fontSize: 14,
                                        color: ColorSys.darkBlue,
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
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
                                horizontal: 16.0, vertical: 10.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.info_circle,
                                  color: ColorSys.darkBlue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'App Version',
                                  style: textStyle(
                                      fontSize: 14,
                                      color: ColorSys.darkBlue,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                const SizedBox(width: 8),
                                Text(
                                  'Latest',
                                  style: textStyle(fontSize: 14),
                                ),
                                const Icon(
                                  Iconsax.arrow_right_3,
                                  color: ColorSys.darkBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        // Perform Firebase sign-out
                        try {
                          _userService.clearCurrentUserCache();
                          await FirebaseAuth.instance.signOut();
                          // Navigate to the login screen after successfully logging out
                          // ignore: use_build_context_synchronously
                          Navigator.pushReplacementNamed(context, '/login');
                        } catch (e) {
                          // Handle sign-out errors, if any
                          print("Error while logging out: $e");
                          // Display error message or take appropriate action
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.logout,
                              color: ColorSys.darkBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: textStyle(
                                  fontSize: 14,
                                  color: ColorSys.darkBlue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          '  Version ${packageInfo?.version ?? 'N/A'}',
                          style: textStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // Show a loading indicator while fetching package info
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
