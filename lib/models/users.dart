import 'package:firebase_database/firebase_database.dart';

class User {
  final String userId;
  final String name;
  String distance;
  String duration;
  final String roles;
  final String imageUrl;
  final double latitude;
  final double longitude;

  User({
    required this.userId,
    required this.name,
    required this.distance,
    required this.duration,
    required this.roles,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      userId: data['userId'] ?? '',
      name: data['displayName'] ?? '',
      distance: '0 Km',
      duration: '10 Mins',
      roles: data['roles'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
    );
  }
}

Future<Map<String, List<User>>> fetchUsersFromFirebase() async {
  final databaseReference = FirebaseDatabase.instance.ref();
  DatabaseEvent event =
      await databaseReference.child('users').once(); // Await directly here

  List<User> allUsers = []; // Fetch all users

  Map<dynamic, dynamic>? values =
      event.snapshot.value as Map<dynamic, dynamic>?;

  if (values != null) {
    values.forEach((key, value) {
      allUsers.add(User.fromMap(Map<String, dynamic>.from(value)));
    });
  }

  // Filter users with role 'jemaah haji'
  List<User> jemaahHaji =
      allUsers.where((user) => user.roles == 'jemaah haji').toList();

  // Filter users with role 'petugas haji'
  List<User> petugasHaji =
      allUsers.where((user) => user.roles == 'petugas haji').toList();

  return {
    'jemaahHaji': jemaahHaji,
    'petugasHaji': petugasHaji,
  };
}
