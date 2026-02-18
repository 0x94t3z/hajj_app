import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajj_app/helpers/app_popup.dart';
import 'package:hajj_app/screens/features/finding/maps.dart';
import 'package:hajj_app/screens/features/finding/navigation.dart';
import 'package:hajj_app/screens/features/help/help_chat.dart';
import 'package:hajj_app/screens/features/help/help_inbox.dart';
import 'package:hajj_app/screens/features/profile/edit.dart';
import 'package:hajj_app/screens/presentation/introduction.dart';
import 'package:hajj_app/screens/auth/login.dart';
import 'package:hajj_app/screens/auth/register.dart';
import 'package:hajj_app/screens/auth/forgot.dart';
import 'package:hajj_app/screens/features/menu/home.dart';
import 'package:hajj_app/screens/features/menu/find_my.dart';
import 'package:hajj_app/screens/features/menu/setting.dart';
import 'package:hajj_app/services/local_notification_service.dart';
import 'package:hajj_app/services/user_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load();
  await LocalNotificationService.initialize();

  runApp(const HajjApp());
}

class HajjApp extends StatefulWidget {
  const HajjApp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HajjAppState createState() => _HajjAppState();
}

class _HajjAppState extends State<HajjApp> with WidgetsBindingObserver {
  final UserService _userService = UserService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool isLoggedIn = false;
  bool _isPermissionRequested = false;
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<DatabaseEvent>? _helpNotificationSubscription;
  final Set<String> _seenHelpNotificationIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkLoginStatus();

    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (!mounted) return;
      setState(() {
        isLoggedIn = user != null;
      });

      if (user == null) {
        await _stopLocationTracking();
        await _stopHelpNotificationListener();
        _userService.clearCurrentUserCache();
        return;
      }

      await _startLocationTracking();
      await _startHelpNotificationListener();
    });
  }

  Future<void> checkLoginStatus() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user != null) {
      setState(() {
        isLoggedIn = true;
      });
      await _startLocationTracking();
      await _startHelpNotificationListener();
    }
  }

  Future<void> _startHelpNotificationListener() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _helpNotificationSubscription?.cancel();
    _helpNotificationSubscription = null;
    _seenHelpNotificationIds.clear();

    final query = FirebaseDatabase.instance
        .ref('helpNotificationRequests')
        .orderByChild('receiverUid')
        .equalTo(user.uid);

    _helpNotificationSubscription = query.onValue.listen((event) async {
      final raw = event.snapshot.value;
      if (raw is! Map) return;

      final items = raw.entries
          .map((entry) {
            if (entry.value is! Map) return null;
            final map = Map<String, dynamic>.from(entry.value as Map);
            final id = map['id']?.toString().isNotEmpty == true
                ? map['id'].toString()
                : entry.key.toString();
            final createdAt = map['createdAt'] is int
                ? map['createdAt'] as int
                : int.tryParse(map['createdAt']?.toString() ?? '0') ?? 0;
            return (
              id: id,
              key: entry.key.toString(),
              title: map['title']?.toString() ?? 'Pesan bantuan baru',
              body: map['body']?.toString() ?? '',
              conversationId: map['conversationId']?.toString() ?? '',
              status: map['status']?.toString() ?? '',
              senderUid: map['senderUid']?.toString() ?? '',
              createdAt: createdAt,
            );
          })
          .whereType<
              ({
                String body,
                String conversationId,
                int createdAt,
                String id,
                String key,
                String senderUid,
                String status,
                String title
              })>()
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (final item in items) {
        if (_seenHelpNotificationIds.contains(item.id)) continue;
        if (item.status != 'pending') continue;
        if (item.senderUid == user.uid) continue;

        _seenHelpNotificationIds.add(item.id);
        if (_appLifecycleState != AppLifecycleState.resumed) {
          await LocalNotificationService.showNotification(
            title: item.title,
            body: item.body.isEmpty ? 'Ada pesan bantuan baru.' : item.body,
            payload: item.conversationId,
          );
        } else {
          final navigator = _navigatorKey.currentState;
          if (navigator != null) {
            await showAppPopupFromNavigator(
              navigator,
              type: AppPopupType.info,
              title: item.title,
              message:
                  item.body.isEmpty ? 'Ada pesan bantuan baru.' : item.body,
            );
          }
        }

        try {
          await FirebaseDatabase.instance
              .ref('helpNotificationRequests/${item.key}')
              .update({
            'status': 'delivered',
            'deliveredAt': ServerValue.timestamp,
          });
        } catch (_) {
          // Keep app stable if notification status update is denied by rules.
        }
      }
    });
  }

  Future<void> _stopHelpNotificationListener() async {
    await _helpNotificationSubscription?.cancel();
    _helpNotificationSubscription = null;
    _seenHelpNotificationIds.clear();
  }

  Future<bool> _ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }

    if (_isPermissionRequested) return false;
    _isPermissionRequested = true;
    try {
      permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } finally {
      _isPermissionRequested = false;
    }
  }

  Future<void> _pushCurrentLocationOnce() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _userService.updateCurrentUserLocation(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      debugPrint('Error updating location once: $e');
    }
  }

  Future<void> _startLocationTracking() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) return;

    if (_positionSubscription != null) {
      await _pushCurrentLocationOnce();
      return;
    }

    await _pushCurrentLocationOnce();
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (position) async {
        if (FirebaseAuth.instance.currentUser == null) return;
        try {
          await _userService.updateCurrentUserLocation(
            position.latitude,
            position.longitude,
          );
        } catch (e) {
          debugPrint('Error streaming location update: $e');
        }
      },
      onError: (error) {
        debugPrint('Location stream error: $error');
      },
    );
  }

  Future<void> _stopLocationTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    if (state == AppLifecycleState.resumed && isLoggedIn) {
      _startLocationTracking();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authStateSubscription?.cancel();
    _stopLocationTracking();
    _stopHelpNotificationListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      initialRoute: isLoggedIn ? '/home' : '/introduction',
      routes: {
        '/introduction': (context) => const Introduction(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/find_my': (context) => const FindMyScreen(),
        '/finding': (context) => const MapScreen(),
        '/navigation': (context) => const NavigationScreen(),
        '/help_inbox': (context) => const HelpInboxScreen(),
        '/setting': (context) => const SettingScreen(),
        '/edit': (context) => const EditScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/help_chat') {
          final args = (settings.arguments as Map<String, dynamic>?) ??
              <String, dynamic>{};
          final peerId = args['peerId']?.toString() ?? '';
          final peerName = args['peerName']?.toString() ?? 'User';
          final peerImageUrl = args['peerImageUrl']?.toString() ?? '';
          final peerIsPetugas = args['peerIsPetugas'] == true;
          final peerRole = args['peerRole']?.toString() ?? '';

          return MaterialPageRoute(
            builder: (_) => HelpChatScreen(
              peerId: peerId,
              peerName: peerName,
              peerImageUrl: peerImageUrl,
              peerIsPetugas: peerIsPetugas,
              peerRole: peerRole,
            ),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
