import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:iconsax/iconsax.dart';

class User {
  final String name;
  String distance;
  final String duration;
  final Color backgroundColor;
  final Color buttonColor;
  final String buttonText;
  final IconData buttonIcon;
  final String imageUrl;
  final double latitude;
  final double longitude;

  User({
    required this.name,
    required this.distance,
    required this.duration,
    required this.backgroundColor,
    required this.buttonColor,
    required this.buttonText,
    required this.buttonIcon,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });
}

List<User> initializeUsers() {
  // Initialize the list of users with their initial data
  List<User> users = [
    User(
      name: 'Muhamad Taopik',
      distance: '0 Km',
      duration: '10 Min',
      backgroundColor: Colors.white,
      buttonColor: ColorSys.darkBlue,
      buttonText: 'Go',
      buttonIcon: Iconsax.direct_up,
      imageUrl:
          'https://www.upwork.com/profile-portraits/c1zSnFOuQiSndrhY4MYKOJ81UMHqFq4uSoNrQ12NpLI2-gwhJMyE7YWso8ZNZXHR22',
      latitude: 21.422627,
      longitude: 39.826115,
    ),
    User(
      name: 'Imam Firdaus',
      distance: '0 Km',
      duration: '15 Min',
      backgroundColor: Colors.white,
      buttonColor: ColorSys.darkBlue,
      buttonText: 'Go',
      buttonIcon: Iconsax.direct_up,
      imageUrl: 'https://avatars.githubusercontent.com/u/65115314?v=4',
      latitude: 21.423797,
      longitude: 39.825303,
    ),
    User(
      name: 'Ilham Fadhlurahman',
      distance: '0 Km',
      duration: '20 Min',
      backgroundColor: Colors.white,
      buttonColor: ColorSys.darkBlue,
      buttonText: 'Go',
      buttonIcon: Iconsax.direct_up,
      imageUrl:
          'https://ugc.production.linktr.ee/17BkMbInQs600WGFE5cv_ml7ui23Oxne18rwt?io=true&size=avatar',
      latitude: 21.421034,
      longitude: 39.825859,
    ),
    User(
      name: 'Ikhsan Khoreul',
      distance: '0 Km',
      duration: '25 Min',
      backgroundColor: Colors.white,
      buttonColor: ColorSys.darkBlue,
      buttonText: 'Go',
      buttonIcon: Iconsax.direct_up,
      imageUrl: 'https://avatars.githubusercontent.com/u/64008898?v=4',
      latitude: 21.421835,
      longitude: 39.826029,
    ),
    User(
      name: 'Fauzan',
      distance: '0 Km',
      duration: '30 Min',
      backgroundColor: Colors.white,
      buttonColor: ColorSys.darkBlue,
      buttonText: 'Go',
      buttonIcon: Iconsax.direct_up,
      imageUrl:
          'https://i.pinimg.com/564x/c6/3f/72/c63f724ff95d6d869cac725215559fff.jpg',
      latitude: 21.421515,
      longitude: 39.827269,
    ),
  ];

  return users;
}
