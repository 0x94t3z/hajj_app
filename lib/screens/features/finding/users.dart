import 'package:flutter/material.dart';

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
