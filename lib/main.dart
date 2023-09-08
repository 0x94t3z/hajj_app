import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajj_app/screens/presentation/introduction.dart';
import 'package:hajj_app/screens/auth/login.dart';
import 'package:hajj_app/screens/auth/register.dart';
import 'package:hajj_app/screens/auth/forgot.dart';
import 'package:hajj_app/screens/features/home.dart';
import 'package:hajj_app/screens/features/find_me.dart';
import 'package:hajj_app/screens/features/search.dart';
import 'package:hajj_app/screens/features/settings.dart';

void main() async {
  // Initialize dotenv package before runApp
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();

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

Future<void> getCurrentLocation() async {
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

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
        '/search': (context) => const SearchScreen(),
        '/settings': (context) => const SettingScreen(),
      },
    );
  }
}
