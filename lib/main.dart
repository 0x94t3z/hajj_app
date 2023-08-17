import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hajj_app/screens/presentation/introduction.dart';
import 'package:hajj_app/screens/auth/login.dart';
import 'package:hajj_app/screens/auth/register.dart';
import 'package:hajj_app/screens/auth/forgot.dart';
import 'package:hajj_app/screens/features/home.dart';
import 'package:hajj_app/screens/features/find_me.dart';
import 'package:hajj_app/screens/features/search.dart';
import 'package:hajj_app/screens/features/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions(); // Request permissions before running the app
  Position currentPosition =
      await _getCurrentLocation(); // Get current location
  print(
      'Current Latitude: ${currentPosition.latitude}, Longitude: ${currentPosition.longitude}');
  runApp(const HajjApp());
}

Future<void> _requestPermissions() async {
  LocationPermission permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse) {
    print('Location permission granted');
  } else {
    print('Location permission denied');
  }
}

Future<Position> _getCurrentLocation() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  return position;
}

class HajjApp extends StatelessWidget {
  const HajjApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute:
          '/introduction', // Set the initial route to the Introduction screen
      routes: {
        '/introduction': (context) => const Introduction(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/find_me': (context) => const FindMeScreen(),
        '/search': (context) => const SearchScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
