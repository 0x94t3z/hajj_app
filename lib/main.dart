import 'package:flutter/material.dart';
import 'package:hajj_app/screens/presentation/introduction.dart';
import 'package:hajj_app/screens/auth/login.dart';
import 'package:hajj_app/screens/auth/register.dart';
import 'package:hajj_app/screens/features/home.dart';
import 'package:hajj_app/screens/features/find_me.dart';
import 'package:hajj_app/screens/features/search.dart';
import 'package:hajj_app/screens/features/profile.dart';

void main() {
  runApp(const HajjApp());
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
        '/home': (context) => const HomeScreen(),
        '/find_me': (context) => const FindMeScreen(),
        '/search': (context) => const SearchScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
