import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajj_app/core/theme/app_style.dart';
import 'package:hajj_app/screens/features/finding/map_screen.dart';
import 'package:hajj_app/screens/features/finding/navigation_screen.dart';
import 'package:hajj_app/screens/features/help/help_chat.dart';
import 'package:hajj_app/screens/features/help/help_inbox.dart';
import 'package:hajj_app/screens/features/help/help_tracking_screen.dart';
import 'package:hajj_app/screens/features/profile/edit.dart';
import 'package:hajj_app/screens/presentation/onboarding_screen.dart';
import 'package:hajj_app/screens/auth/login.dart';
import 'package:hajj_app/screens/auth/register.dart';
import 'package:hajj_app/screens/auth/forgot.dart';
import 'package:hajj_app/screens/features/menu/home_screen.dart';
import 'package:hajj_app/screens/features/menu/find_my_screen.dart';
import 'package:hajj_app/screens/features/menu/settings_screen.dart';
import 'package:hajj_app/services/help_service.dart';
import 'package:hajj_app/services/local_notification_service.dart';
import 'package:hajj_app/services/user_service.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    show MapboxOptions;
import 'package:iconsax/iconsax.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

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
      providerAndroid: kReleaseMode
          ? const AndroidPlayIntegrityProvider()
          : const AndroidDebugProvider(),
      providerApple: kReleaseMode
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
  final HelpService _helpService = HelpService();
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
  String? _currentRouteName;
  int _helpNotificationListenerEpoch = 0;
  final Set<String> _seenHelpNotificationIds = <String>{};
  final Set<String> _seenUnreadHelpConversationKeys = <String>{};
  int _lastHelpPopupEpochMs = 0;
  bool? _cachedIsPetugas;
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
        _currentRouteName = routeName;
      },
    );
    LocalNotificationService.onNotificationResponse =
        _handleLocalNotificationResponse;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final launchPayload = LocalNotificationService.takeLaunchPayload();
      if (launchPayload != null && launchPayload.trim().isNotEmpty) {
        _handleLocalNotificationResponse(
          launchPayload,
          LocalNotificationService.takeLaunchActionId(),
        );
      }
    });
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
      unawaited(
        _pollHelpNotifications(
          listenerEpoch: _helpNotificationListenerEpoch,
          receiverUid: user.uid,
        ),
      );
      return;
    }

    _helpNotificationPollTimer?.cancel();
    _helpNotificationPollTimer = null;
    if (_helpNotificationListenerUid != user.uid) {
      _cachedIsPetugas = null;
      _seenHelpNotificationIds.clear();
      _seenUnreadHelpConversationKeys.clear();
    }
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
      final items = <_HelpNotificationItem>[];

      if (raw is Map) {
        items.addAll(
          raw.entries.map((entry) {
            if (entry.value is! Map) return null;
            final map = Map<String, dynamic>.from(entry.value as Map);
            final id = map['id']?.toString().isNotEmpty == true
                ? map['id'].toString()
                : entry.key.toString();
            final createdAt = map['createdAt'] is int
                ? map['createdAt'] as int
                : int.tryParse(map['createdAt']?.toString() ?? '0') ?? 0;
            return _HelpNotificationItem(
              id: id,
              key: entry.key.toString(),
              type: map['type']?.toString() ?? '',
              priority: map['priority']?.toString() ?? '',
              helpStatus: map['helpStatus']?.toString() ?? '',
              title: map['title']?.toString() ?? 'Pesan bantuan baru',
              body: map['body']?.toString() ?? '',
              conversationId: map['conversationId']?.toString() ?? '',
              status: map['status']?.toString() ?? '',
              senderUid: map['senderUid']?.toString() ?? '',
              senderName: map['senderName']?.toString() ?? '',
              senderRole: map['senderRole']?.toString() ?? '',
              senderKloter: map['senderKloter']?.toString() ?? '',
              messageText: map['messageText']?.toString() ??
                  map['body']?.toString() ??
                  '',
              routeDistanceMeters:
                  _toNotificationDouble(map['routeDistanceMeters']),
              routeDurationSeconds:
                  _toNotificationDouble(map['routeDurationSeconds']),
              estimatedArrivalAt: _toNotificationInt(map['estimatedArrivalAt']),
              createdAt: createdAt,
            );
          }).whereType<_HelpNotificationItem>(),
        );
      }
      items.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final newItems = <_HelpNotificationItem>[];
      final staleItems = <_HelpNotificationItem>[];

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

      if (newItems.isEmpty) {
        await _pollUnreadHelpInbox(
          listenerEpoch: listenerEpoch,
          receiverUid: receiverUid,
        );
        return;
      }
      if (listenerEpoch != _helpNotificationListenerEpoch) return;

      final isPetugas = await _resolveIsPetugas();
      final uniqueSenderUids = newItems
          .map((item) => item.senderUid.trim())
          .where((id) => id.isNotEmpty)
          .toSet();
      final senderCount =
          uniqueSenderUids.isEmpty ? newItems.length : uniqueSenderUids.length;
      final popupCount = isPetugas ? senderCount : newItems.length;
      final firstItem = newItems.first;
      final senderKloter = await _resolveHelpSenderKloter(firstItem);
      if (listenerEpoch != _helpNotificationListenerEpoch) return;
      final isHelpRequest = firstItem.type == 'help_request' ||
          (firstItem.priority == 'urgent' && firstItem.helpStatus.isEmpty);
      final shouldOpenTracking = isHelpRequest ||
          (firstItem.type == 'help_status' &&
              {
                HelpService.statusAccepted,
                HelpService.statusOnTheWay,
                HelpService.statusArrived,
                HelpService.statusClosed,
              }.contains(firstItem.helpStatus));

      await _presentHelpNotification(
        count: popupCount,
        isUrgent: isHelpRequest,
        title: isHelpRequest ? 'Permintaan Bantuan Mendesak' : firstItem.title,
        payload: firstItem.conversationId,
        senderName: firstItem.senderName,
        senderRole: firstItem.senderRole,
        senderKloter: senderKloter,
        messageText: firstItem.messageText,
        peerIsPetugas: !isPetugas,
        openTracking: shouldOpenTracking,
        showRequestActions: isHelpRequest && isPetugas,
        helpStatus: firstItem.helpStatus,
        routeDistanceMeters: firstItem.routeDistanceMeters,
        routeDurationSeconds: firstItem.routeDurationSeconds,
        estimatedArrivalAt: firstItem.estimatedArrivalAt,
      );

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

  Future<void> _pollUnreadHelpInbox({
    required int listenerEpoch,
    required String receiverUid,
  }) async {
    if (listenerEpoch != _helpNotificationListenerEpoch) return;

    try {
      final isPetugas = await _resolveIsPetugas();
      final items = await _helpService.fetchAllInboxOnce(
        currentUid: receiverUid,
        currentIsPetugas: isPetugas,
      );
      if (listenerEpoch != _helpNotificationListenerEpoch) return;

      final unreadItems = items.where((item) {
        if (item.status == 'closed' || item.archived) return false;
        if (item.lastSenderId.isEmpty || item.lastSenderId == receiverUid) {
          return false;
        }
        if (item.unreadMessageCount <= 0) return false;

        final seenKey =
            '${item.conversationId}:${item.lastMessageAt}:${item.lastSenderId}';
        if (_seenUnreadHelpConversationKeys.contains(seenKey)) return false;
        _seenUnreadHelpConversationKeys.add(seenKey);
        return true;
      }).toList()
        ..sort((a, b) => a.lastMessageAt.compareTo(b.lastMessageAt));

      if (unreadItems.isEmpty) return;
      final senderCount = unreadItems
          .map((item) => item.peerId.trim())
          .where((id) => id.isNotEmpty)
          .toSet()
          .length;

      await _presentHelpNotification(
        count: isPetugas && senderCount > 0 ? senderCount : unreadItems.length,
        isUrgent: isPetugas,
        payload: unreadItems.first.conversationId,
        senderName: unreadItems.first.peerName,
        senderRole: unreadItems.first.peerRole,
        senderKloter: unreadItems.first.peerKloter,
        messageText: unreadItems.first.lastMessage,
        peerIsPetugas: !isPetugas,
        openTracking: true,
        showRequestActions: isPetugas,
      );
    } catch (_) {
      // The notification queue already handles the main path. Inbox polling is
      // a fallback, so never block the app when Firebase rules are restrictive.
    }
  }

  Future<void> _presentHelpNotification({
    required int count,
    required bool isUrgent,
    String title = '',
    String? payload,
    String senderName = '',
    String senderRole = '',
    String senderKloter = '',
    String messageText = '',
    bool peerIsPetugas = false,
    bool openTracking = false,
    bool showRequestActions = false,
    String helpStatus = '',
    double routeDistanceMeters = 0,
    double routeDurationSeconds = 0,
    int estimatedArrivalAt = 0,
  }) async {
    if (_isOnHelpChatRoute || HelpService.isHelpChatScreenActive) return;

    final popupCount = count < 1 ? 1 : count;
    final shouldOpenTracking = isUrgent || openTracking;
    final notificationTitle = title.trim().isNotEmpty
        ? title.trim()
        : (isUrgent ? 'Permintaan Bantuan Mendesak' : 'Pesan Baru');
    final notificationBody = _helpNotificationText(
      popupCount,
      isUrgent: isUrgent,
      senderName: senderName,
      senderKloter: senderKloter,
      messageText: messageText,
    );
    final notificationPayload = _buildHelpNotificationPayload(
      payload,
      openTracking: shouldOpenTracking,
    );
    final foregroundNavigator = _appLifecycleState == AppLifecycleState.resumed
        ? _navigatorKey.currentState
        : null;
    final shouldOpenRequestDirectly = showRequestActions &&
        payload?.trim().isNotEmpty == true &&
        foregroundNavigator != null;

    if (!shouldOpenRequestDirectly) {
      if (showRequestActions && notificationPayload != null) {
        await LocalNotificationService.showHelpRequestNotification(
          title: notificationTitle,
          body: notificationBody,
          payload: notificationPayload,
        );
      } else if (openTracking) {
        await LocalNotificationService.showTrackingStatus(
          title: _trackingNotificationTitle(
            helpStatus,
            fallbackTitle: notificationTitle,
            estimatedArrivalAt: estimatedArrivalAt,
          ),
          body: _trackingNotificationBody(
            helpStatus,
            senderName: senderName,
            fallbackBody: notificationBody,
            routeDistanceMeters: routeDistanceMeters,
            routeDurationSeconds: routeDurationSeconds,
          ),
          payload: notificationPayload,
          ongoing: helpStatus == HelpService.statusAccepted ||
              helpStatus == HelpService.statusOnTheWay,
          playSound: true,
          showJourneyProgress: helpStatus == HelpService.statusOnTheWay,
        );
      } else {
        await LocalNotificationService.showNotification(
          title: notificationTitle,
          body: notificationBody,
          payload: notificationPayload,
        );
      }
    }

    if (_appLifecycleState != AppLifecycleState.resumed) {
      return;
    }

    final navigator = foregroundNavigator ?? _navigatorKey.currentState;
    if (navigator == null) return;

    if (shouldOpenRequestDirectly) {
      _openHelpNotificationTarget(
        navigator,
        conversationId: payload,
        peerName: senderName,
        peerRole: senderRole,
        peerIsPetugas: peerIsPetugas,
        openTracking: true,
      );
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastHelpPopupEpochMs <= 1000) return;
    _lastHelpPopupEpochMs = now;
    await _showHelpRequestCountPopup(
      navigator,
      count: popupCount,
      isUrgent: isUrgent,
      title: notificationTitle,
      senderName: senderName,
      senderRole: senderRole,
      senderKloter: senderKloter,
      messageText: messageText,
      payload: payload,
      peerIsPetugas: peerIsPetugas,
      openTracking: shouldOpenTracking,
    );
  }

  String? _buildHelpNotificationPayload(
    String? conversationId, {
    required bool openTracking,
  }) {
    final cleanConversationId = conversationId?.trim() ?? '';
    if (cleanConversationId.isEmpty) return null;
    final target = openTracking ? 'tracking' : 'chat';
    return '$target:$cleanConversationId';
  }

  Future<void> _handleLocalNotificationResponse(
    String? rawPayload,
    String? actionId,
  ) async {
    if (!mounted) return;
    final payload = rawPayload?.trim() ?? '';
    if (payload.isEmpty) return;

    var target = 'chat';
    var conversationId = payload;
    final separatorIndex = payload.indexOf(':');
    if (separatorIndex > 0) {
      final prefix = payload.substring(0, separatorIndex);
      if (prefix == 'chat' || prefix == 'tracking') {
        target = prefix;
        conversationId = payload.substring(separatorIndex + 1);
      }
    }

    final cleanConversationId = conversationId.trim();
    if (cleanConversationId.isEmpty) return;

    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleLocalNotificationResponse(rawPayload, actionId);
      });
      return;
    }

    if (actionId == LocalNotificationService.acceptHelpActionId ||
        actionId == LocalNotificationService.rejectHelpActionId) {
      try {
        await _helpService.updateConversationStatus(
          conversationId: cleanConversationId,
          status: actionId == LocalNotificationService.acceptHelpActionId
              ? HelpService.statusAccepted
              : HelpService.statusRejected,
        );
      } catch (error) {
        debugPrint('Help notification action failed: $error');
        await LocalNotificationService.showNotification(
          title: 'Status bantuan gagal diperbarui',
          body: 'Buka aplikasi dan coba kembali.',
          payload: 'tracking:$cleanConversationId',
        );
        return;
      }
      if (!mounted) return;
      target = 'tracking';
    }

    if (target == 'tracking') {
      navigator.pushNamed(
        '/help_tracking',
        arguments: {
          'conversationId': cleanConversationId,
        },
      );
      return;
    }

    navigator.pushNamed(
      '/help_chat',
      arguments: {
        'conversationId': cleanConversationId,
        'readOnly': false,
        'peerId': '',
        'peerName': 'Pesan Bantuan',
        'peerImageUrl': '',
        'peerIsPetugas': false,
        'peerRole': '',
      },
    );
  }

  String _trackingNotificationTitle(
    String helpStatus, {
    required String fallbackTitle,
    required int estimatedArrivalAt,
  }) {
    switch (helpStatus) {
      case HelpService.statusAccepted:
        return 'Permintaan bantuan diterima';
      case HelpService.statusOnTheWay:
        final arrivalTime = _formatArrivalTime(estimatedArrivalAt);
        return arrivalTime.isEmpty
            ? 'Petugas menuju lokasi Anda'
            : 'Petugas tiba sekitar $arrivalTime';
      case HelpService.statusArrived:
        return 'Petugas sudah sampai';
      case HelpService.statusClosed:
        return 'Bantuan telah selesai';
      default:
        return fallbackTitle;
    }
  }

  String _trackingNotificationBody(
    String helpStatus, {
    required String senderName,
    required String fallbackBody,
    required double routeDistanceMeters,
    required double routeDurationSeconds,
  }) {
    final name = senderName.trim().isEmpty ? 'Petugas' : senderName.trim();
    switch (helpStatus) {
      case HelpService.statusAccepted:
        return '$name menerima permintaan bantuan. Buka untuk melacak posisi petugas.';
      case HelpService.statusOnTheWay:
        final metrics = <String>[
          if (routeDistanceMeters > 0)
            _formatNotificationDistance(routeDistanceMeters),
          if (routeDurationSeconds > 0)
            _formatNotificationDuration(routeDurationSeconds),
        ];
        final suffix = metrics.isEmpty ? '' : ' • ${metrics.join(' • ')}';
        return '$name sedang menuju lokasi Anda$suffix. Buka untuk melacak.';
      case HelpService.statusArrived:
        return '$name sudah berada di sekitar lokasi Anda.';
      case HelpService.statusClosed:
        return 'Proses bantuan telah diselesaikan.';
      default:
        return fallbackBody;
    }
  }

  String _formatArrivalTime(int epochMillis) {
    if (epochMillis <= 0) return '';
    final value = DateTime.fromMillisecondsSinceEpoch(epochMillis).toLocal();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
  }

  String _formatNotificationDistance(double distanceMeters) {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  String _formatNotificationDuration(double durationSeconds) {
    final minutes = (durationSeconds / 60).ceil().clamp(1, 999);
    return '$minutes menit';
  }

  static double _toNotificationDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toNotificationInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
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
    final role = await _userService.fetchCurrentUserRole(forceRefresh: true);
    _cachedIsPetugas = _userService.isPetugasHajiRole(role);
    return _cachedIsPetugas!;
  }

  Future<String> _fetchUserKloter(String uid) async {
    if (uid.trim().isEmpty) return '';
    try {
      final data = await _userService.fetchAnyUserDataById(uid);
      return data?['kloter']?.toString().trim() ??
          data?['KLOTER']?.toString().trim() ??
          data?['kelompokTerbang']?.toString().trim() ??
          '';
    } catch (_) {
      return '';
    }
  }

  Future<String> _fetchConversationSenderKloter(
    String conversationId,
    String senderUid,
  ) async {
    final cleanConversationId = conversationId.trim();
    final cleanSenderUid = senderUid.trim();
    if (cleanConversationId.isEmpty || cleanSenderUid.isEmpty) return '';

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('helpConversations/$cleanConversationId')
          .get();
      if (!snapshot.exists || snapshot.value is! Map) return '';

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final pilgrimId = data['pilgrimId']?.toString().trim() ?? '';
      final officerId = data['officerId']?.toString().trim() ?? '';
      if (cleanSenderUid == pilgrimId) {
        return data['pilgrimKloter']?.toString().trim() ?? '';
      }
      if (cleanSenderUid == officerId) {
        return data['officerKloter']?.toString().trim() ?? '';
      }
    } catch (_) {
      return '';
    }
    return '';
  }

  Future<String> _resolveHelpSenderKloter(_HelpNotificationItem item) async {
    final requestKloter = item.senderKloter.trim();
    if (requestKloter.isNotEmpty) return requestKloter;

    final conversationKloter = await _fetchConversationSenderKloter(
      item.conversationId,
      item.senderUid,
    );
    if (conversationKloter.isNotEmpty) return conversationKloter;

    return _fetchUserKloter(item.senderUid);
  }

  String _helpNotificationText(
    int count, {
    required bool isUrgent,
    String senderName = '',
    String senderKloter = '',
    String messageText = '',
  }) {
    final total = count < 1 ? 1 : count;
    final cleanName = senderName.trim();
    final cleanKloter = senderKloter.trim();
    final cleanMessage = messageText.trim();
    if (isUrgent) {
      if (cleanName.isNotEmpty) {
        final kloterText = cleanKloter.isNotEmpty
            ? 'Kloter $cleanKloter'
            : 'kloter belum tersedia';
        return total > 1
            ? 'Ada $total permintaan bantuan baru. Salah satunya dari $cleanName, $kloterText.'
            : 'Permintaan bantuan baru dari $cleanName, $kloterText.';
      }
      return 'Ada $total permintaan bantuan baru dari jemaah.';
    }
    if (cleanName.isNotEmpty && cleanMessage.isNotEmpty) {
      return '$cleanName: $cleanMessage';
    }
    return 'Ada $total pesan baru.';
  }

  Widget _buildUrgentHelpPopupContent({
    required int count,
    required String senderName,
    required String senderKloter,
  }) {
    final total = count < 1 ? 1 : count;
    final cleanName =
        senderName.trim().isEmpty ? 'Jemaah Haji' : senderName.trim();
    final cleanKloter =
        senderKloter.trim().isEmpty ? 'Belum tersedia' : senderKloter.trim();
    final summaryText = total > 1
        ? 'Ada $total permintaan bantuan baru. Berikut salah satu jemaah yang perlu ditindaklanjuti.'
        : 'Permintaan bantuan baru diterima dari jemaah berikut.';

    Widget infoRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 62,
              child: Text(
                label,
                style: textStyle(
                  fontSize: 12,
                  color: ColorSys.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textStyle(
                  fontSize: 12.5,
                  color: ColorSys.darkBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(
          summaryText,
          textAlign: TextAlign.center,
          style: textStyle(
            fontSize: 12.5,
            color: ColorSys.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ColorSys.error.withValues(alpha: 0.14),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              infoRow('Jemaah', cleanName),
              infoRow('Kloter', cleanKloter),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showHelpRequestCountPopup(
    NavigatorState navigator, {
    required int count,
    required bool isUrgent,
    String title = '',
    String senderName = '',
    String senderRole = '',
    String senderKloter = '',
    String messageText = '',
    String? payload,
    bool peerIsPetugas = false,
    bool openTracking = false,
  }) async {
    final accent = isUrgent ? ColorSys.error : ColorSys.darkBlue;
    final popupTitle = title.trim().isNotEmpty
        ? title.trim()
        : (isUrgent ? 'Permintaan Bantuan Mendesak' : 'Pesan Baru');
    final backgroundColor = isUrgent ? const Color(0xFFFFFBFB) : Colors.white;
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
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: isUrgent
                  ? Border.all(
                      color: ColorSys.error.withValues(alpha: 0.22),
                      width: 1.2,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: (isUrgent ? ColorSys.error : Colors.black)
                      .withValues(alpha: isUrgent ? 0.18 : 0.15),
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
                  popupTitle,
                  textAlign: TextAlign.center,
                  style: textStyle(
                    fontSize: 18,
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                isUrgent
                    ? _buildUrgentHelpPopupContent(
                        count: count,
                        senderName: senderName,
                        senderKloter: senderKloter,
                      )
                    : Text(
                        _helpNotificationText(
                          count,
                          isUrgent: isUrgent,
                          senderName: senderName,
                          senderKloter: senderKloter,
                          messageText: messageText,
                        ),
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
                          'Tidak',
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
                          _openHelpNotificationTarget(
                            navigator,
                            conversationId: payload,
                            peerName: senderName,
                            peerRole: senderRole,
                            peerIsPetugas: peerIsPetugas,
                            openTracking: openTracking,
                          );
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
                          'Lihat',
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

  void _openHelpNotificationTarget(
    NavigatorState navigator, {
    required String? conversationId,
    required String peerName,
    required String peerRole,
    required bool peerIsPetugas,
    bool openTracking = false,
  }) {
    final targetConversationId = conversationId?.trim() ?? '';
    if (targetConversationId.isEmpty) {
      navigator.pushNamed('/help_inbox');
      return;
    }

    if (openTracking) {
      navigator.pushNamed(
        '/help_tracking',
        arguments: {
          'conversationId': targetConversationId,
        },
      );
      return;
    }

    final fallbackName = peerIsPetugas ? 'Petugas Haji' : 'Jemaah Haji';
    final fallbackRole = peerIsPetugas ? 'Petugas Haji' : 'Jemaah Haji';
    navigator.pushNamed(
      '/help_chat',
      arguments: {
        'conversationId': targetConversationId,
        'readOnly': false,
        'peerId': '',
        'peerName': peerName.trim().isEmpty ? fallbackName : peerName.trim(),
        'peerImageUrl': '',
        'peerIsPetugas': peerIsPetugas,
        'peerRole': peerRole.trim().isEmpty ? fallbackRole : peerRole.trim(),
      },
    );
  }

  bool get _isOnHelpChatRoute =>
      _currentRouteName == '/help_chat' ||
      _currentRouteName == '/help_tracking';

  Future<void> _stopHelpNotificationListener() async {
    _helpNotificationListenerEpoch++;
    _helpNotificationPollTimer?.cancel();
    _helpNotificationPollTimer = null;
    _isPollingHelpNotifications = false;
    _helpNotificationListenerUid = null;
    _seenHelpNotificationIds.clear();
    _seenUnreadHelpConversationKeys.clear();
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
        unawaited(_startHelpNotificationListener());
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
    if (LocalNotificationService.onNotificationResponse ==
        _handleLocalNotificationResponse) {
      LocalNotificationService.onNotificationResponse = null;
    }
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
      theme: lightTheme,
      darkTheme: darkTheme,
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
        '/help_tracking': (context) => const HelpTrackingScreen(),
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

class _HelpNotificationItem {
  const _HelpNotificationItem({
    required this.id,
    required this.key,
    required this.type,
    required this.priority,
    required this.helpStatus,
    required this.title,
    required this.body,
    required this.conversationId,
    required this.status,
    required this.senderUid,
    required this.senderName,
    required this.senderRole,
    required this.senderKloter,
    required this.messageText,
    required this.routeDistanceMeters,
    required this.routeDurationSeconds,
    required this.estimatedArrivalAt,
    required this.createdAt,
  });

  final String id;
  final String key;
  final String type;
  final String priority;
  final String helpStatus;
  final String title;
  final String body;
  final String conversationId;
  final String status;
  final String senderUid;
  final String senderName;
  final String senderRole;
  final String senderKloter;
  final String messageText;
  final double routeDistanceMeters;
  final double routeDurationSeconds;
  final int estimatedArrivalAt;
  final int createdAt;
}
