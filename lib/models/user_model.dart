import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:hajj_app/core/utils/name_formatter.dart';

class UserModel {
  final String userId;
  final String name;
  String distance;
  String duration;
  final String roles;
  final String imageUrl;
  final double latitude;
  final double longitude;

  UserModel({
    required this.userId,
    required this.name,
    required this.distance,
    required this.duration,
    required this.roles,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      userId: data['userId'] ?? '',
      name: toTitleCaseName(data['displayName']?.toString() ?? ''),
      distance: '0 Km',
      duration: '10 Mins',
      roles: data['roles'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      latitude: (data['latitude'] is String && data['latitude'].isNotEmpty)
          ? double.tryParse(data['latitude']) ?? 0.0
          : (data['latitude'] is double
              ? data['latitude']
              : 0.0), // Fallback to 0.0 for invalid values
      longitude: (data['longitude'] is String && data['longitude'].isNotEmpty)
          ? double.tryParse(data['longitude']) ?? 0.0
          : (data['longitude'] is double
              ? data['longitude']
              : 0.0), // Fallback to 0.0 for invalid values
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': name,
      'distance': distance,
      'duration': duration,
      'roles': roles,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class UserDataAccessException implements Exception {
  final String message;
  UserDataAccessException(this.message);

  @override
  String toString() => message;
}

Future<Map<String, List<UserModel>>> fetchModelsFromFirebase({
  bool logPetugasJson = false,
}) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    throw UserDataAccessException('Please sign in to access user data.');
  }

  final usersRef = FirebaseDatabase.instance.ref('users');
  late DataSnapshot snapshot;
  try {
    snapshot = await usersRef.get();
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') {
      throw UserDataAccessException(
        'Permission denied by Firebase rules when reading /users.',
      );
    }
    rethrow;
  }

  List<UserModel> allUsers = []; // Fetch all users
  final values = snapshot.value as Map<dynamic, dynamic>?;
  if (values != null) {
    final rootMap = Map<String, dynamic>.from(values);
    final isSingleUserObject = rootMap.containsKey('userId') ||
        rootMap.containsKey('displayName') ||
        rootMap.containsKey('email') ||
        rootMap.containsKey('roles') ||
        rootMap.containsKey('imageUrl');

    if (isSingleUserObject) {
      allUsers.add(UserModel.fromMap(rootMap));
    } else {
      values.forEach((key, value) {
        if (value is Map) {
          allUsers.add(UserModel.fromMap(Map<String, dynamic>.from(value)));
        }
      });
    }
  }

  // List of valid roles for Petugas Haji
  const validPetugasHajiRoles = [
    "KETUA KLOTER (TPHI)",
    "PEMBIMBING IBADAH (TPIHI)",
    "PELAYANAN AKOMODASI",
    "PELAYANAN IBADAH",
    "PELAYANAN KONSUMSI",
    "PELAYANAN TRANSPORTASI"
  ];

  bool isPetugasHajiRole(String role) => validPetugasHajiRoles.contains(role);

  final petugasRawJson = <Map<String, dynamic>>[];
  if (values != null) {
    final rootMap = Map<String, dynamic>.from(values);
    final isSingleUserObject = rootMap.containsKey('userId') ||
        rootMap.containsKey('displayName') ||
        rootMap.containsKey('email') ||
        rootMap.containsKey('roles') ||
        rootMap.containsKey('imageUrl');

    if (isSingleUserObject) {
      final role = rootMap['roles']?.toString() ?? '';
      if (isPetugasHajiRole(role)) {
        petugasRawJson.add(rootMap);
      }
    } else {
      values.forEach((key, value) {
        if (value is Map) {
          final mapValue = Map<String, dynamic>.from(value);
          final role = mapValue['roles']?.toString() ?? '';
          if (isPetugasHajiRole(role)) {
            petugasRawJson.add(mapValue);
          }
        }
      });
    }
  }

  // Role di dalam daftar = Petugas Haji
  List<UserModel> petugasHaji =
      allUsers.where((user) => isPetugasHajiRole(user.roles)).toList();

  // Selain role petugas = Jemaah Haji
  List<UserModel> jemaahHaji =
      allUsers.where((user) => !isPetugasHajiRole(user.roles)).toList();

  if (logPetugasJson) {
    final prettyJson =
        const JsonEncoder.withIndent('  ').convert(petugasRawJson);
    debugPrint('PETUGAS_HAJI_JSON: $prettyJson');
  }

  return {
    'jemaahHaji': jemaahHaji,
    'petugasHaji': petugasHaji,
  };
}
