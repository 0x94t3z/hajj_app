import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/screens/features/finding/maps.dart';

class TopNavBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsTap;
  final VoidCallback onMapTap;

  const TopNavBar({
    Key? key,
    required this.onSettingsTap,
    required this.onMapTap,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TopNavBarState createState() => _TopNavBarState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Implementing preferredSize
}

class _TopNavBarState extends State<TopNavBar> {
  late String imageUrl = ''; // Initialize imageUrl as an empty string

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    userRef.once().then((DatabaseEvent event) {
      if (mounted) {
        DataSnapshot snapshot = event.snapshot;
        var userData = snapshot.value;
        if (userData != null && userData is Map) {
          setState(() {
            imageUrl = userData['imageUrl'] as String? ?? '';
          });
        } else {
          print("No data available or data not in the expected format");
        }
      }
    }).catchError((error) {
      print("Error fetching data: $error");
    });
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapScreen()),
            );
          },
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkResponse(
              onTap: widget.onSettingsTap,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: imageUrl.isNotEmpty ? null : Colors.white,
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Transform.translate(
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
              ),
            ),
          )
        ],
      ),
    );
  }
}
