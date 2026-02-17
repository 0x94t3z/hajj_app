import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/screens/features/profile/edit.dart';
import 'package:hajj_app/services/user_service.dart';

class TopNavBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onSettingTap;
  final VoidCallback onMyProfileTap;

  const TopNavBar({
    Key? key,
    required this.onSettingTap,
    required this.onMyProfileTap,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TopNavBarState createState() => _TopNavBarState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Implementing preferredSize
}

class _TopNavBarState extends State<TopNavBar> {
  final UserService _userService = UserService();
  late String imageUrl = ''; // Initialize imageUrl as an empty string

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    try {
      final cachedProfile = _userService.getCachedCurrentUserProfile();
      if (cachedProfile != null && mounted) {
        setState(() {
          imageUrl = cachedProfile['imageUrl'] as String? ?? '';
        });
      }

      final userData =
          await _userService.fetchCurrentUserProfile(forceRefresh: true);
      if (!mounted) return;
      if (userData != null) {
        setState(() {
          imageUrl = userData['imageUrl'] as String? ?? '';
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
    return SafeArea(
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: ColorSys.darkBlue,
          ),
          onPressed: widget.onSettingTap,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkResponse(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditScreen()),
                );
              },
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl.trim().isEmpty
                            ? const Icon(
                                Icons.person,
                                color: ColorSys.darkBlue,
                                size: 20,
                              )
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    color: ColorSys.darkBlue,
                                    size: 20,
                                  );
                                },
                              ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(15, -15),
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(width: 3, color: Colors.white),
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
