import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> importDataFromCSVToFirebase() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  try {
    final String csvString =
        await rootBundle.loadString('assets/data/table_1.csv');

    final List<List<dynamic>> fields =
        const CsvToListConverter().convert(csvString);

    // Assuming the first row in CSV is headers
    final headers = fields[0];

    for (var i = 1; i < fields.length; i++) {
      final data = fields[i];

      final email = data[headers.indexOf('EMAIL')];
      final password = data[headers.indexOf('PASSWORD')];
      final displayName = data[headers.indexOf('NAMA')];
      final roles = data[headers.indexOf('ROLES')];
      final kloter = data[headers.indexOf('KLOTER')];
      // Extract and process other fields

      try {
        final UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Get userId
        String? userId = userCredential.user?.uid;

        // Get the download URL for the default image from Firebase Storage
        Reference storageRef =
            FirebaseStorage.instance.ref().child('images/default_profile.jpg');
        String imageUrl = await storageRef.getDownloadURL();

        if (userId != null) {
          final DatabaseReference userRef =
              database.ref().child('users/$userId');
          await userRef.set({
            'userId': userId,
            'displayName': displayName,
            'roles': roles,
            'kloter': kloter,
            'latitude': '',
            'longitude': '',
            'imageUrl': imageUrl,
            // Add other fields as needed
          });

          print('User created and added to database: $userId');
        } else {
          print('UserCredential returned null');
        }
      } on FirebaseAuthException catch (e) {
        print('Firebase Auth Error: ${e.message}');
      } catch (e) {
        print('Error creating user: $e');
      }
    }
  } catch (e) {
    print('Error loading CSV file: $e');
  }
}
