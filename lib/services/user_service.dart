import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hajj_app/core/utils/name_formatter.dart';

class UserService {
  static const String defaultProfileImageUrl =
      'https://i.ibb.co.com/jNCnb00/default-profile.png';
  static const List<String> validPetugasHajiRoles = [
    "KETUA KLOTER (TPHI)",
    "PEMBIMBING IBADAH (TPIHI)",
    "PELAYANAN AKOMODASI",
    "PELAYANAN IBADAH",
    "PELAYANAN KONSUMSI",
    "PELAYANAN TRANSPORTASI"
  ];

  final FirebaseAuth _auth;
  final FirebaseDatabase _database;
  static String? _cachedUid;
  static String? _cachedUserRefPath;
  static Map<String, dynamic>? _cachedRawUserData;
  static Map<String, dynamic>? _cachedProfileData;

  UserService({
    FirebaseAuth? auth,
    FirebaseDatabase? database,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _database = database ?? FirebaseDatabase.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  bool _isCacheValidForCurrentUser() {
    final uid = currentUserId;
    return uid != null && uid == _cachedUid;
  }

  void clearCurrentUserCache() {
    _cachedUid = null;
    _cachedUserRefPath = null;
    _cachedRawUserData = null;
    _cachedProfileData = null;
  }

  Map<String, dynamic> _profileFromAuth(User user) {
    return {
      'userId': user.uid,
      'displayName': toTitleCaseName(user.displayName ?? ''),
      'email': user.email ?? '',
      'imageUrl': user.photoURL ?? '',
      'roles': 'Jemaah Haji',
      'latitude': 0.0,
      'longitude': 0.0,
    };
  }

  void seedCacheFromAuthUser([User? user]) {
    final authUser = user ?? _auth.currentUser;
    if (authUser == null) return;
    _cachedUid = authUser.uid;
    _cachedProfileData = _profileFromAuth(authUser);
  }

  Map<String, dynamic>? getCachedCurrentUserProfile() {
    final authUser = _auth.currentUser;
    if (authUser == null) return null;

    if (_isCacheValidForCurrentUser()) {
      final cached = _cachedProfileData;
      if (cached != null) return Map<String, dynamic>.from(cached);
    }

    // Return auth fallback instantly while waiting for Firebase data.
    final fallback = _profileFromAuth(authUser);
    _cachedUid = authUser.uid;
    _cachedProfileData = Map<String, dynamic>.from(fallback);
    return fallback;
  }

  String _normalizeRole(String role) {
    return role.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  bool isPetugasHajiRole(String role) {
    final normalizedRole = _normalizeRole(role);
    if (normalizedRole.isEmpty) return false;
    if (normalizedRole == 'PETUGAS HAJI') return true;

    return validPetugasHajiRoles.map(_normalizeRole).contains(normalizedRole);
  }

  Future<Map<String, dynamic>?> fetchCurrentUserData({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _isCacheValidForCurrentUser()) {
      final cached = _cachedRawUserData;
      if (cached != null) return Map<String, dynamic>.from(cached);
    }

    final userRef = await _resolveCurrentUserRef(forceRefresh: forceRefresh);
    if (userRef == null) {
      clearCurrentUserCache();
      return null;
    }
    try {
      final snapshot = await userRef.get();
      if (!snapshot.exists || snapshot.value == null) {
        clearCurrentUserCache();
        return null;
      }
      final rawData = Map<String, dynamic>.from(snapshot.value as Map);
      _cachedUid = currentUserId;
      _cachedUserRefPath = userRef.path;
      _cachedRawUserData = Map<String, dynamic>.from(rawData);
      return rawData;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return null;
      }
      rethrow;
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String && value.isNotEmpty) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  String? _firstNonEmptyString(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final raw = data[key];
      if (raw == null) continue;
      final value = raw.toString().trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  bool _looksLikeUserMap(Map<String, dynamic> data) {
    return data.containsKey('userId') ||
        data.containsKey('displayName') ||
        data.containsKey('email') ||
        data.containsKey('roles') ||
        data.containsKey('imageUrl');
  }

  Future<Map<String, dynamic>?> fetchUserDataById(String uid) async {
    try {
      final snapshot = await _database.ref('users').child(uid).get();
      if (!snapshot.exists || snapshot.value == null) return null;
      return Map<String, dynamic>.from(snapshot.value as Map);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return null;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchAnyUserDataById(String uid) async {
    if (uid.trim().isEmpty) return null;
    final usersRef = _database.ref('users');

    try {
      final directSnapshot = await usersRef.child(uid).get();
      if (directSnapshot.exists && directSnapshot.value is Map) {
        return Map<String, dynamic>.from(directSnapshot.value as Map);
      }
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
    }

    try {
      final byUserId = await usersRef
          .orderByChild('userId')
          .equalTo(uid)
          .limitToFirst(1)
          .get();
      if (byUserId.exists && byUserId.value is Map) {
        final found = byUserId.value as Map<dynamic, dynamic>;
        if (found.isNotEmpty) {
          final raw = found.values.first;
          if (raw is Map) {
            return Map<String, dynamic>.from(raw);
          }
        }
      }
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
    }

    try {
      final snapshot = await usersRef.get();
      if (!snapshot.exists || snapshot.value == null) return null;
      final value = snapshot.value;
      if (value is! Map) return null;

      final rootMap = Map<String, dynamic>.from(value);
      if (_looksLikeUserMap(rootMap) &&
          (rootMap['userId']?.toString() ?? '') == uid) {
        return rootMap;
      }

      for (final entry in value.entries) {
        final row = entry.value;
        if (row is! Map) continue;
        final mapValue = Map<String, dynamic>.from(row);
        if ((mapValue['userId']?.toString() ?? '') == uid ||
            entry.key.toString() == uid) {
          return mapValue;
        }
      }
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
    }

    return null;
  }

  Future<DatabaseReference?> _resolveCurrentUserRef({
    bool forceRefresh = false,
  }) async {
    final uid = currentUserId;
    final firebaseUser = _auth.currentUser;
    if (uid == null || firebaseUser == null) return null;

    if (!forceRefresh && _isCacheValidForCurrentUser()) {
      final cachedPath = _cachedUserRefPath;
      if (cachedPath != null && cachedPath.isNotEmpty) {
        return _database.ref(cachedPath);
      }
    }

    final usersRef = _database.ref('users');
    final directRef = usersRef.child(uid);
    final email = (firebaseUser.email ?? '').trim().toLowerCase();

    // 1) Try direct node /users/{uid}
    try {
      final directSnapshot = await directRef.get();
      if (directSnapshot.exists) {
        _cachedUid = uid;
        _cachedUserRefPath = directRef.path;
        return directRef;
      }
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        rethrow;
      }
    }

    // 2) Query by userId (faster transfer than reading all users)
    try {
      final byUserId = await usersRef
          .orderByChild('userId')
          .equalTo(uid)
          .limitToFirst(1)
          .get();
      if (byUserId.exists && byUserId.value is Map) {
        final found = byUserId.value as Map<dynamic, dynamic>;
        if (found.isNotEmpty) {
          final nodeKey = found.keys.first.toString();
          final resolvedRef = usersRef.child(nodeKey);
          _cachedUid = uid;
          _cachedUserRefPath = resolvedRef.path;
          return resolvedRef;
        }
      }
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        rethrow;
      }
    }

    // 3) Query by email
    if (email.isNotEmpty) {
      try {
        final byEmail = await usersRef
            .orderByChild('email')
            .equalTo(email)
            .limitToFirst(1)
            .get();
        if (byEmail.exists && byEmail.value is Map) {
          final found = byEmail.value as Map<dynamic, dynamic>;
          if (found.isNotEmpty) {
            final nodeKey = found.keys.first.toString();
            final resolvedRef = usersRef.child(nodeKey);
            _cachedUid = uid;
            _cachedUserRefPath = resolvedRef.path;
            return resolvedRef;
          }
        }
      } on FirebaseException catch (e) {
        if (e.code != 'permission-denied') {
          rethrow;
        }
      }
    }

    // 4) Fallback scan /users (legacy / inconsistent structure)
    try {
      final allSnapshot = await usersRef.get();
      if (!allSnapshot.exists || allSnapshot.value == null) {
        return null;
      }

      final values = allSnapshot.value as Map<dynamic, dynamic>;

      // Handle single-object structure directly under /users
      final rootMap = Map<String, dynamic>.from(values);
      if (_looksLikeUserMap(rootMap)) {
        final rootUserId = rootMap['userId']?.toString() ?? '';
        final rootEmail = (rootMap['email']?.toString() ?? '').toLowerCase();
        if (rootUserId == uid || (email.isNotEmpty && rootEmail == email)) {
          _cachedUid = uid;
          _cachedUserRefPath = usersRef.path;
          return usersRef;
        }
      }

      // Handle map-of-users structure /users/{key}
      for (final entry in values.entries) {
        final nodeKey = entry.key.toString();
        final value = entry.value;
        if (value is! Map) continue;
        final mapValue = Map<String, dynamic>.from(value);
        final rowUserId = mapValue['userId']?.toString() ?? '';
        final rowEmail = (mapValue['email']?.toString() ?? '').toLowerCase();
        if (nodeKey == uid ||
            rowUserId == uid ||
            (email.isNotEmpty && rowEmail == email)) {
          final resolvedRef = usersRef.child(nodeKey);
          _cachedUid = uid;
          _cachedUserRefPath = resolvedRef.path;
          return resolvedRef;
        }
      }
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return null;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentUserProfile({
    bool forceRefresh = false,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    if (!forceRefresh && _isCacheValidForCurrentUser()) {
      final cachedProfile = _cachedProfileData;
      if (cachedProfile != null) {
        return Map<String, dynamic>.from(cachedProfile);
      }
    }

    final userData = await fetchCurrentUserData(forceRefresh: forceRefresh) ??
        <String, dynamic>{};
    final displayName = _firstNonEmptyString(
      userData,
      const ['displayName', 'name', 'fullName'],
    );
    final email = _firstNonEmptyString(
      userData,
      const ['email', 'mail'],
    );
    final imageUrl = _firstNonEmptyString(
      userData,
      const ['imageUrl', 'imageURL', 'photoUrl', 'photoURL', 'image'],
    );
    final roles = _firstNonEmptyString(
      userData,
      const ['roles', 'role', 'status'],
    );

    final cachedProfile = _cachedProfileData ?? _profileFromAuth(firebaseUser);
    final profile = {
      'userId': userData['userId']?.toString().isNotEmpty == true
          ? userData['userId'].toString()
          : cachedProfile['userId'],
      'displayName': toTitleCaseName(
        displayName ?? cachedProfile['displayName']?.toString() ?? '',
      ),
      'email': email ?? cachedProfile['email'] ?? '',
      'imageUrl': imageUrl ?? cachedProfile['imageUrl'] ?? '',
      'roles': roles ?? cachedProfile['roles'] ?? 'Jemaah Haji',
      'latitude': _toDouble(userData['latitude']),
      'longitude': _toDouble(userData['longitude']),
    };

    _cachedUid = currentUserId;
    _cachedProfileData = Map<String, dynamic>.from(profile);
    return profile;
  }

  Future<Map<String, dynamic>?> primeCurrentUserCache() {
    return fetchCurrentUserProfile(forceRefresh: true);
  }

  Future<String> fetchCurrentUserRole({
    String defaultRole = 'Jemaah Haji',
    bool forceRefresh = false,
  }) async {
    final userData = await fetchCurrentUserProfile(forceRefresh: forceRefresh);
    final role = userData?['roles']?.toString().trim() ?? '';
    return role.isNotEmpty ? role : defaultRole;
  }

  Future<void> updateCurrentUserData(Map<String, dynamic> data) async {
    final userRef = await _resolveCurrentUserRef();
    if (userRef == null) return;
    final normalizedData = <String, dynamic>{...data};
    if (normalizedData['displayName'] != null) {
      normalizedData['displayName'] = toTitleCaseName(
        normalizedData['displayName'].toString(),
      );
    }

    await userRef.update(normalizedData);

    final uid = currentUserId;
    if (uid != null) {
      _cachedUid = uid;
      final mergedRaw = <String, dynamic>{
        ...?_cachedRawUserData,
        ...normalizedData,
      };
      _cachedRawUserData = mergedRaw;
      final mergedProfile = <String, dynamic>{
        ...?getCachedCurrentUserProfile(),
        ...normalizedData,
      };
      _cachedProfileData = mergedProfile;
    }
  }

  Future<void> updateCurrentUserLocation(double latitude, double longitude) {
    return updateCurrentUserData({
      'latitude': latitude,
      'longitude': longitude,
    });
  }
}

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

        final String imageUrl = UserService.defaultProfileImageUrl;

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
