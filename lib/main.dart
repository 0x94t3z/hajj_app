import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajj_app/screens/features/finding/maps.dart';
import 'package:hajj_app/screens/features/profile/edit.dart';
import 'package:hajj_app/screens/presentation/introduction.dart';
import 'package:hajj_app/screens/auth/login.dart';
import 'package:hajj_app/screens/auth/register.dart';
import 'package:hajj_app/screens/auth/forgot.dart';
import 'package:hajj_app/screens/features/menu/home.dart';
import 'package:hajj_app/screens/features/menu/find_me.dart';
import 'package:hajj_app/screens/features/menu/contact.dart';
import 'package:hajj_app/screens/features/menu/settings.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load();

  initializeApp().then((_) {
    runApp(const HajjApp());
  });
}

bool _isPermissionRequested = false; // Flag to track permission request status

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse) {
    print('Location permission already granted');
    getCurrentLocation(); // Call the function to print current location
  } else if (!_isPermissionRequested) {
    await requestPermissions();
  }
}

Future<void> requestPermissions() async {
  _isPermissionRequested = true; // Set flag to indicate permission request
  LocationPermission permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse) {
    print('Location permission granted');
    getCurrentLocation(); // Call the function to print current location
  } else {
    print('Location permission denied');
  }
  _isPermissionRequested = false; // Reset the flag after permission request
}

Future<void> _updateUserLocation(double latitude, double longitude) async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users/${currentUser.uid}');
      await userRef.update({
        'latitude': latitude,
        'longitude': longitude,
      });
      print('User location updated successfully.');
    } else {
      print('User is not authenticated.');
    }
  } catch (e) {
    print('Error updating user location: $e');
  }
}

Future<void> getCurrentLocation() async {
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  // Update current user's location in Firebase Realtime Database
  await _updateUserLocation(position.latitude, position.longitude);

  // Print the current location
  print(
      'Current Latitude: ${position.latitude} Longitude: ${position.longitude}');
}

class HajjApp extends StatelessWidget {
  const HajjApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/introduction',
      routes: {
        '/introduction': (context) => const Introduction(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/find_me': (context) => const FindMeScreen(),
        '/find_officers': (context) => const MapScreen(),
        '/contact': (context) => const ContactScreen(),
        '/settings': (context) => const SettingScreen(),
        '/edit': (context) => const EditScreen(),
      },
    );
  }
}
