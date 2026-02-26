import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajj_app/core/theme/app_style.dart';
import 'package:hajj_app/screens/features/finding/map_screen.dart';
import 'package:hajj_app/screens/features/finding/navigation_screen.dart';
import 'package:hajj_app/screens/features/help/help_chat.dart';
import 'package:hajj_app/screens/features/help/help_inbox.dart';
import 'package:hajj_app/screens/features/profile/edit.dart';
import 'package:hajj_app/screens/presentation/onboarding_screen.dart';
import 'package:hajj_app/screens/auth/login.dart';
import 'package:hajj_app/screens/auth/register.dart';
import 'package:hajj_app/screens/auth/forgot.dart';
import 'package:hajj_app/screens/features/menu/home_screen.dart';
import 'package:hajj_app/screens/features/menu/find_my_screen.dart';
import 'package:hajj_app/screens/features/menu/settings_screen.dart';
import 'package:hajj_app/services/local_notification_service.dart';
import 'package:hajj_app/services/user_service.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show MapboxOptions;
import 'package:iconsax/iconsax.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _configureFirebaseAppCheck();

  await dotenv.load();
  _configureMapboxAccessToken();
  await LocalNotificationService.initialize();

  runApp(const HajjApp());
}

Future<void> _configureFirebaseAppCheck() async {
  // Debug provider removes noisy "No AppCheckProvider installed" warnings
  // while keeping release builds ready for real provider attestation.
  try {
    if (kIsWeb) return;
    await FirebaseAppCheck.instance.activate(
      providerAndroid:
          kReleaseMode
              ? const AndroidPlayIntegrityProvider()
              : const AndroidDebugProvider(),
      providerApple:
          kReleaseMode
              ? const AppleDeviceCheckProvider()
              : const AppleDebugProvider(),
    );
  } catch (e) {
    debugPrint('Firebase App Check activation failed: $e');
  }
}

void _configureMapboxAccessToken() {
  final token = dotenv.env['MAPBOX_PUBLIC_KEY']?.trim();
  if (token == null || token.isEmpty) {
    debugPrint('MAPBOX_PUBLIC_KEY is missing.');
    return;
  }
  MapboxOptions.setAccessToken(token);
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
  late final _AppRouteObserver _routeObserver;
  bool isLoggedIn = false;
  bool _isPermissionRequested = false;
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  LocationPermission _lastKnownLocationPermission = LocationPermission.denied;
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _helpNotificationPollTimer;
  bool _isPollingHelpNotifications = false;
  String? _helpNotificationListenerUid;
  int _helpNotificationListenerEpoch = 0;
  final Set<String> _seenHelpNotificationIds = <String>{};
  int _lastHelpPopupEpochMs = 0;
  bool? _cachedIsPetugas;
  String _currentRouteName = '';
  bool _hasLoggedLocationPermissionIssue = false;
  bool _realtimeDbOnline = true;

  bool _isIgnoredIosLocationError(Object error) {
    final text = error.toString();
    return text.contains('kCLErrorDomain') && text.contains('error 1');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appLifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
    _routeObserver = _AppRouteObserver(
      onRouteChanged: (routeName) {
        if (routeName == null || routeName.trim().isEmpty) return;
        _currentRouteName = routeName;
      },
    );
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
        _setRealtimeDatabaseOnline(false);
        _userService.clearCurrentUserCache();
        return;
      }

      _setRealtimeDatabaseOnline(true);
      await _startLocationTracking();
      await _startHelpNotificationListener();
    });
  }

  void _setRealtimeDatabaseOnline(bool online) {
    if (_realtimeDbOnline == online) return;
    _realtimeDbOnline = online;
    try {
      if (online) {
        FirebaseDatabase.instance.goOnline();
      } else {
        FirebaseDatabase.instance.goOffline();
      }
    } catch (_) {
      // Keep auth/session transitions resilient even when DB transport toggles fail.
    }
  }

  Future<void> checkLoginStatus() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    setState(() {
      isLoggedIn = user != null;
    });
  }

  Future<void> _startHelpNotificationListener() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_helpNotificationListenerUid == user.uid &&
        _helpNotificationPollTimer != null) {
      return;
    }

    _helpNotificationPollTimer?.cancel();
    _helpNotificationPollTimer = null;
    _helpNotificationListenerUid = user.uid;
    _isPollingHelpNotifications = false;
    final listenerEpoch = ++_helpNotificationListenerEpoch;
    // Keep seen ids during runtime to prevent repeated popups when
    // listener is reattached (e.g. initial auth sync).

    unawaited(
      _pollHelpNotifications(
        listenerEpoch: listenerEpoch,
        receiverUid: user.uid,
      ),
    );

    _helpNotificationPollTimer = Timer.periodic(
      const Duration(seconds: 12),
      (_) {
        unawaited(
          _pollHelpNotifications(
            listenerEpoch: listenerEpoch,
            receiverUid: user.uid,
          ),
        );
      },
    );
  }

  Future<void> _pollHelpNotifications({
    required int listenerEpoch,
    required String receiverUid,
  }) async {
    if (_isPollingHelpNotifications) return;
    if (listenerEpoch != _helpNotificationListenerEpoch) return;
    _isPollingHelpNotifications = true;
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('helpNotificationRequests')
          .orderByChild('receiverUid')
          .equalTo(receiverUid)
          .get();
      if (listenerEpoch != _helpNotificationListenerEpoch) return;
      final raw = snapshot.value;
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
              senderName: map['senderName']?.toString() ?? '',
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
                String senderName,
                String senderUid,
                String status,
                String title
              })>()
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final newItems = <({
        String body,
        String conversationId,
        int createdAt,
        String id,
        String key,
        String senderName,
        String senderUid,
        String status,
        String title
      })>[];
      final staleItems = <({
        String body,
        String conversationId,
        int createdAt,
        String id,
        String key,
        String senderName,
        String senderUid,
        String status,
        String title
      })>[];

      for (final item in items) {
        if (listenerEpoch != _helpNotificationListenerEpoch) return;
        if (_seenHelpNotificationIds.contains(item.id)) continue;
        if (item.status != 'pending') continue;
        if (item.senderUid == receiverUid) continue;
        final conversationId = item.conversationId.trim();
        if (conversationId.isNotEmpty) {
          final isConversationActive =
              await _isConversationActive(conversationId);
          if (!isConversationActive) {
            _seenHelpNotificationIds.add(item.id);
            staleItems.add(item);
            continue;
          }
        }
        _seenHelpNotificationIds.add(item.id);
        newItems.add(item);
      }

      for (final item in staleItems) {
        if (listenerEpoch != _helpNotificationListenerEpoch) return;
        try {
          await FirebaseDatabase.instance
              .ref('helpNotificationRequests/${item.key}')
              .update({
            'status': 'ignored',
            'ignoredAt': ServerValue.timestamp,
          });
        } catch (_) {
          // Keep app stable if notification status update is denied by rules.
        }
      }

      if (newItems.isEmpty) return;
      if (listenerEpoch != _helpNotificationListenerEpoch) return;

      final isPetugas = await _resolveIsPetugas();
      final uniqueSenderUids = newItems
          .map((item) => item.senderUid.trim())
          .where((id) => id.isNotEmpty)
          .toSet();
      final senderCount =
          uniqueSenderUids.isEmpty ? newItems.length : uniqueSenderUids.length;
      final popupCount = isPetugas ? senderCount : newItems.length;

      if (_appLifecycleState != AppLifecycleState.resumed) {
        await LocalNotificationService.showNotification(
          title: isPetugas ? 'Urgent Help Request' : 'New Message',
          body: _newMessageCountText(popupCount),
          payload: newItems.first.conversationId,
        );
      } else {
        final navigator = _navigatorKey.currentState;
        final isInHelpChat = _currentRouteName == '/help_chat';
        if (navigator != null && !isInHelpChat) {
          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - _lastHelpPopupEpochMs > 1000) {
            _lastHelpPopupEpochMs = now;
            await _showHelpRequestCountPopup(
              navigator,
              count: popupCount,
              isUrgent: isPetugas,
            );
          }
        }
      }

      for (final item in newItems) {
        if (listenerEpoch != _helpNotificationListenerEpoch) return;
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
    } finally {
      _isPollingHelpNotifications = false;
    }
  }

  Future<bool> _isConversationActive(String conversationId) async {
    // Avoid extra per-notification reads at startup. In strict rules setups,
    // probing unknown/non-participant conversation ids can trigger
    // permission-denied log spam from native Firebase SDK.
    return conversationId.trim().isNotEmpty;
  }

  Future<bool> _resolveIsPetugas() async {
    if (_cachedIsPetugas != null) return _cachedIsPetugas!;
    final cachedRole =
        _userService.getCachedCurrentUserProfile()?['roles']?.toString() ?? '';
    if (cachedRole.trim().isNotEmpty) {
      _cachedIsPetugas = _userService.isPetugasHajiRole(cachedRole);
      return _cachedIsPetugas!;
    }
    final role = await _userService.fetchCurrentUserRole();
    _cachedIsPetugas = _userService.isPetugasHajiRole(role);
    return _cachedIsPetugas!;
  }

  String _newMessageCountText(int count) {
    final total = count < 1 ? 1 : count;
    return 'You have $total new message.';
  }

  Future<void> _showHelpRequestCountPopup(
    NavigatorState navigator, {
    required int count,
    required bool isUrgent,
  }) async {
    final accent = isUrgent ? ColorSys.error : ColorSys.darkBlue;
    final title = isUrgent ? 'Urgent Help Request' : 'New Message';
    await showDialog<void>(
      context: navigator.context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 26),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    isUrgent ? Iconsax.danger : Iconsax.message_question,
                    color: accent,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textStyle(
                    fontSize: 18,
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _newMessageCountText(count),
                  textAlign: TextAlign.center,
                  style: textStyle(
                    fontSize: 13,
                    color: ColorSys.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: accent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'No',
                          style: textStyle(
                            fontSize: 14,
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          navigator.pushNamed('/help_inbox');
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'View',
                          style: textStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _stopHelpNotificationListener() async {
    _helpNotificationListenerEpoch++;
    _helpNotificationPollTimer?.cancel();
    _helpNotificationPollTimer = null;
    _isPollingHelpNotifications = false;
    _helpNotificationListenerUid = null;
    _seenHelpNotificationIds.clear();
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!_hasLoggedLocationPermissionIssue) {
        _hasLoggedLocationPermissionIssue = true;
        debugPrint('Location service is disabled.');
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    _lastKnownLocationPermission = permission;

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      _hasLoggedLocationPermissionIssue = false;
      return true;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!_hasLoggedLocationPermissionIssue) {
        _hasLoggedLocationPermissionIssue = true;
        debugPrint('Location permission denied forever.');
      }
      return false;
    }

    if (_isPermissionRequested) return false;
    _isPermissionRequested = true;
    try {
      permission = await Geolocator.requestPermission();
      _lastKnownLocationPermission = permission;
      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!granted && !_hasLoggedLocationPermissionIssue) {
        _hasLoggedLocationPermissionIssue = true;
        debugPrint('Location permission not granted: $permission');
      }
      if (granted) {
        _hasLoggedLocationPermissionIssue = false;
      }
      return granted;
    } finally {
      _isPermissionRequested = false;
    }
  }

  Future<void> _pushCurrentLocationOnce() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    if (_appLifecycleState != AppLifecycleState.resumed) return;
    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      await _userService.updateCurrentUserLocation(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      if (_isIgnoredIosLocationError(e)) return;
      debugPrint('Error updating location once: $e');
    }
  }

  Future<void> _startLocationTracking() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    if (_appLifecycleState != AppLifecycleState.resumed) return;
    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) return;

    if (_positionSubscription != null) {
      await _pushCurrentLocationOnce();
      return;
    }

    await _pushCurrentLocationOnce();
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
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
        if (_isIgnoredIosLocationError(error)) return;
        // iOS often emits transient kCLErrorDomain errors when app transitions
        // to background. We stop tracking on background state, so skip noisy logs.
        if (_appLifecycleState == AppLifecycleState.resumed) {
          debugPrint('Location stream error: $error');
        }
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
    if (state == AppLifecycleState.resumed) {
      if (isLoggedIn) {
        unawaited(_startLocationTracking());
      }
      return;
    }
    final canTrackInBackground =
        _lastKnownLocationPermission == LocationPermission.always;
    if (!canTrackInBackground) {
      unawaited(_stopLocationTracking());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authStateSubscription?.cancel();
    _stopLocationTracking();
    _stopHelpNotificationListener();
    _setRealtimeDatabaseOnline(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      navigatorObservers: <NavigatorObserver>[_routeObserver],
      initialRoute: isLoggedIn ? '/home' : '/introduction',
      routes: {
        '/introduction': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/find_my': (context) => const FindMyScreen(),
        '/finding': (context) => const MapScreen(),
        '/navigation': (context) => const NavigationScreen(),
        '/help_inbox': (context) => const HelpInboxScreen(),
        '/setting': (context) => const SettingsScreen(),
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
          final conversationId = args['conversationId']?.toString();
          final readOnly = args['readOnly'] == true;

          return MaterialPageRoute(
            builder: (_) => HelpChatScreen(
              peerId: peerId,
              peerName: peerName,
              peerImageUrl: peerImageUrl,
              peerIsPetugas: peerIsPetugas,
              peerRole: peerRole,
              conversationId: conversationId,
              readOnly: readOnly,
            ),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

class _AppRouteObserver extends NavigatorObserver {
  _AppRouteObserver({
    required this.onRouteChanged,
  });

  final void Function(String? routeName) onRouteChanged;

  void _notify(Route<dynamic>? route) {
    onRouteChanged(route?.settings.name);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _notify(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _notify(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _notify(newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _notify(previousRoute);
  }
}
