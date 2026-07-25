import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static const _androidChannelId = 'help_messages_alert_channel_v4';
  static const _androidProgressChannelId = 'help_tracking_status_channel_v1';
  static const _androidChannelName = 'Pesan Bantuan Mendesak';
  static const _androidChannelDescription =
      'Notifikasi bantuan mendesak antara jemaah dan petugas.';
  static const _androidProgressChannelName = 'Status Bantuan Aktif';
  static const _androidProgressChannelDescription =
      'Status progres petugas menuju lokasi jemaah.';
  static const _androidAlertSound =
      RawResourceAndroidNotificationSound('universfield_new_notification');
  static const _iosAlertSound = 'universfield-new-notification.caf';
  static const int trackingStatusNotificationId = 940021;

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  static String? _launchPayload;
  static void Function(String? payload)? onNotificationTap;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _launchPayload = launchDetails?.notificationResponse?.payload;
    }

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response.payload);
      },
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: _androidChannelDescription,
        importance: Importance.max,
        playSound: true,
        sound: _androidAlertSound,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidProgressChannelId,
        _androidProgressChannelName,
        description: _androidProgressChannelDescription,
        importance: Importance.high,
        playSound: true,
        sound: _androidAlertSound,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.notification,
      ),
    );

    await androidPlugin?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    _isInitialized = true;
  }

  static String? takeLaunchPayload() {
    final payload = _launchPayload;
    _launchPayload = null;
    return payload;
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: _androidAlertSound,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      ticker: 'ticker',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      sound: _iosAlertSound,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationId =
        id ?? DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    await _plugin.show(notificationId, title, body, details, payload: payload);
  }

  static Future<void> showTrackingStatus({
    required String title,
    required String body,
    String? payload,
    bool ongoing = true,
    bool playSound = true,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final androidDetails = AndroidNotificationDetails(
      _androidProgressChannelId,
      _androidProgressChannelName,
      channelDescription: _androidProgressChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
      sound: playSound ? _androidAlertSound : null,
      enableVibration: playSound,
      ongoing: ongoing,
      autoCancel: !ongoing,
      onlyAlertOnce: !playSound,
      category: AndroidNotificationCategory.navigation,
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(body),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
      presentBanner: true,
      presentList: true,
      sound: playSound ? _iosAlertSound : null,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      trackingStatusNotificationId,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> cancelTrackingStatus() async {
    if (!_isInitialized) {
      await initialize();
    }
    await _plugin.cancel(trackingStatusNotificationId);
  }
}
