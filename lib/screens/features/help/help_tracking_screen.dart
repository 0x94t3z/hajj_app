import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:hajj_app/core/widgets/app_popup.dart';
import 'package:hajj_app/core/theme/app_style.dart';
import 'package:hajj_app/core/utils/name_formatter.dart';
import 'package:hajj_app/models/user_model.dart';
import 'package:hajj_app/screens/features/finding/haversine_algorithm.dart';
import 'package:hajj_app/screens/features/finding/navigation_screen.dart';
import 'package:hajj_app/services/help_service.dart';
import 'package:hajj_app/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;

class HelpTrackingScreen extends StatefulWidget {
  const HelpTrackingScreen({super.key});

  @override
  State<HelpTrackingScreen> createState() => _HelpTrackingScreenState();
}

class _HelpTrackingScreenState extends State<HelpTrackingScreen> {
  final HelpService _helpService = HelpService();
  final UserService _userService = UserService();

  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
  final Map<String, Uint8List> _avatarMarkerCache = <String, Uint8List>{};
  Uint8List? _currentLocationMarker;
  StreamSubscription<Map<String, dynamic>?>? _officerLocationSubscription;
  StreamSubscription<Map<String, dynamic>?>? _pilgrimLocationSubscription;
  StreamSubscription<geo.Position>? _deviceLocationSubscription;
  Stream<Map<String, dynamic>?>? _conversationStream;

  String _conversationId = '';
  String _lastOfficerId = '';
  String _lastPilgrimId = '';
  String _lastRenderedRouteKey = '';
  Map<String, dynamic> _officerUserData = <String, dynamic>{};
  Map<String, dynamic> _pilgrimUserData = <String, dynamic>{};
  double _routeDistanceMeters = 0;
  double _routeDurationSeconds = 0;
  bool _hasRouteMetrics = false;
  bool _isRenderingRoute = false;
  bool _renderRequested = false;
  bool _isUpdatingStatus = false;
  bool _isStartingDeviceTracking = false;
  bool _isPublishingDeviceLocation = false;
  bool _isDisposed = false;
  int _mapGeneration = 0;
  geo.Position? _lastPublishedDevicePosition;
  DateTime? _lastPublishedDeviceLocationAt;
  _TrackingCoordinates? _latestCoordinates;
  Map<String, dynamic> _latestTrackingData = <String, dynamic>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
    final conversationId = args['conversationId']?.toString().trim() ?? '';
    if (conversationId.isNotEmpty && conversationId != _conversationId) {
      _conversationId = conversationId;
      _conversationStream = _helpService.watchConversation(conversationId);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _mapGeneration++;
    _mapboxMap = null;
    _pointAnnotationManager = null;
    _polylineAnnotationManager = null;
    _officerLocationSubscription?.cancel();
    _pilgrimLocationSubscription?.cancel();
    _deviceLocationSubscription?.cancel();
    super.dispose();
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _formatDistance(double meters) {
    if (!_hasRouteMetrics || meters < 0) return '-';
    if (meters < 1) return '0 m';
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  String _formatDuration(double seconds, {required double distanceMeters}) {
    if (!_hasRouteMetrics) return '-';
    if (distanceMeters >= 0 && distanceMeters < 1) return '0 menit';
    if (seconds <= 0) return '-';
    final minutes = math.max(1, (seconds / 60).round());
    return '$minutes menit';
  }

  String _formatKloter(dynamic value) {
    final kloter = value?.toString().trim() ?? '';
    if (kloter.isEmpty) return '';
    if (kloter.toLowerCase().startsWith('kloter')) return kloter;
    return 'Kloter $kloter';
  }

  _TrackingCoordinates? _resolveTrackingCoordinates(
    Map<String, dynamic> data,
  ) {
    final officerLat = _toDouble(_officerUserData['latitude']) != 0
        ? _toDouble(_officerUserData['latitude'])
        : _toDouble(data['officerLat']);
    final officerLng = _toDouble(_officerUserData['longitude']) != 0
        ? _toDouble(_officerUserData['longitude'])
        : _toDouble(data['officerLng']);
    final pilgrimLat = _toDouble(_pilgrimUserData['latitude']) != 0
        ? _toDouble(_pilgrimUserData['latitude'])
        : _toDouble(data['pilgrimLat']);
    final pilgrimLng = _toDouble(_pilgrimUserData['longitude']) != 0
        ? _toDouble(_pilgrimUserData['longitude'])
        : _toDouble(data['pilgrimLng']);

    if (officerLat == 0 ||
        officerLng == 0 ||
        pilgrimLat == 0 ||
        pilgrimLng == 0) {
      return null;
    }

    return _TrackingCoordinates(
      officerLat: officerLat,
      officerLng: officerLng,
      pilgrimLat: pilgrimLat,
      pilgrimLng: pilgrimLng,
    );
  }

  CameraOptions _initialCameraOptions(_TrackingCoordinates coordinates) {
    final distanceMeters = calculateHaversineDistance(
          coordinates.officerLat,
          coordinates.officerLng,
          coordinates.pilgrimLat,
          coordinates.pilgrimLng,
        ) *
        1000;
    final zoom = switch (distanceMeters) {
      <= 100 => 18.2,
      <= 300 => 17.2,
      <= 800 => 16.0,
      <= 2000 => 14.8,
      <= 5000 => 13.5,
      _ => 11.5,
    };

    return CameraOptions(
      center: Point(
        coordinates: Position(
          (coordinates.officerLng + coordinates.pilgrimLng) / 2,
          (coordinates.officerLat + coordinates.pilgrimLat) / 2,
        ),
      ),
      zoom: zoom,
      bearing: 0,
      pitch: 0,
    );
  }

  int _toMillis(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  bool _currentIsPetugas(Map<String, dynamic> data) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return uid.isNotEmpty && uid == (data['officerId']?.toString() ?? '');
  }

  int _unreadMessageCount(Map<String, dynamic> data) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return 0;

    var lastReadAt = 0;
    final readMetaRaw = data['readMeta'];
    if (readMetaRaw is Map) {
      final currentReadMeta = readMetaRaw[uid];
      if (currentReadMeta is Map) {
        lastReadAt = _toMillis(currentReadMeta['lastReadAt']);
      }
    }

    var unread = 0;
    final messagesRaw = data['messages'];
    if (messagesRaw is Map) {
      for (final value in messagesRaw.values) {
        if (value is! Map) continue;
        final senderId = value['senderId']?.toString() ?? '';
        final createdAt = _toMillis(value['createdAt']);
        if (senderId != uid && createdAt > lastReadAt) unread++;
      }
      return unread;
    }

    final lastSenderId = data['lastSenderId']?.toString() ?? '';
    final lastMessageAt = _toMillis(data['lastMessageAt']);
    if (lastSenderId.isNotEmpty &&
        lastSenderId != uid &&
        lastMessageAt > lastReadAt) {
      return 1;
    }
    return 0;
  }

  String _statusTitle(String status, {required bool currentIsPetugas}) {
    switch (status) {
      case HelpService.statusAccepted:
        return currentIsPetugas
            ? 'Permintaan sudah diterima'
            : 'Petugas menerima permintaan';
      case HelpService.statusOnTheWay:
        return currentIsPetugas
            ? 'Anda sedang menuju lokasi jemaah'
            : 'Petugas sedang menuju lokasi Anda';
      case HelpService.statusArrived:
        return currentIsPetugas
            ? 'Anda sudah sampai di lokasi jemaah'
            : 'Petugas sudah sampai di sekitar lokasi';
      case HelpService.statusRejected:
        return 'Permintaan belum dapat diterima';
      case HelpService.statusClosed:
        return 'Bantuan telah selesai';
      default:
        return currentIsPetugas
            ? 'Permintaan bantuan masuk'
            : 'Menunggu konfirmasi petugas';
    }
  }

  String _statusMessage(String status, {required bool currentIsPetugas}) {
    switch (status) {
      case HelpService.statusAccepted:
        return currentIsPetugas
            ? 'Jemaah sudah diberi tahu bahwa permintaan bantuan diterima.'
            : 'Petugas sudah menerima permintaan bantuan. Anda dapat memantau estimasi jarak dan waktu kedatangan.';
      case HelpService.statusOnTheWay:
        return currentIsPetugas
            ? 'Status ini memberi tahu jemaah bahwa Anda sedang menuju lokasinya.'
            : 'Tetap berada di tempat yang aman sambil menunggu petugas tiba.';
      case HelpService.statusArrived:
        return currentIsPetugas
            ? 'Status ini memberi tahu jemaah bahwa Anda sudah berada di sekitar lokasinya.'
            : 'Petugas sudah berada di sekitar lokasi Anda.';
      case HelpService.statusRejected:
        return 'Petugas belum dapat menerima permintaan ini. Anda dapat mengirim permintaan bantuan kembali.';
      case HelpService.statusClosed:
        return 'Sesi bantuan telah diakhiri dan percakapan disimpan sebagai arsip.';
      default:
        return currentIsPetugas
            ? 'Jemaah membutuhkan bantuan. Terima permintaan jika Anda siap menindaklanjuti.'
            : 'Permintaan bantuan sudah dikirim dan sedang menunggu respons petugas.';
    }
  }

  String _safeProfileImageUrl(String? imageUrl) {
    final normalized = UserService.normalizeProfileImageUrl(imageUrl);
    if (normalized.isNotEmpty) return normalized;
    return UserService.defaultProfileImageUrl;
  }

  String _preferredProfileImageUrl(Iterable<dynamic> candidates) {
    String? fallback;

    for (final candidate in candidates) {
      final normalized = UserService.normalizeProfileImageUrl(
        candidate?.toString(),
      );
      if (normalized.isEmpty) continue;

      fallback ??= normalized;
      if (normalized != UserService.defaultProfileImageUrl) {
        return normalized;
      }
    }

    return fallback ?? UserService.defaultProfileImageUrl;
  }

  Future<ui.Image?> _loadMarkerImage(String imageUrl) async {
    if (imageUrl.trim().isEmpty) return null;

    final completer = Completer<ui.Image?>();
    final imageStream = NetworkImage(imageUrl).resolve(
      const ImageConfiguration(),
    );
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (imageInfo, _) {
        if (!completer.isCompleted) completer.complete(imageInfo.image);
        imageStream.removeListener(listener);
      },
      onError: (_, __) {
        if (!completer.isCompleted) completer.complete(null);
        imageStream.removeListener(listener);
      },
    );
    imageStream.addListener(listener);

    try {
      return await completer.future.timeout(const Duration(seconds: 8));
    } on TimeoutException {
      imageStream.removeListener(listener);
      return null;
    }
  }

  Future<Uint8List> _buildAvatarMarker({
    required String imageUrl,
    required Color borderColor,
  }) async {
    final safeUrl = _safeProfileImageUrl(imageUrl);
    final cacheKey = '$safeUrl-${borderColor.toARGB32()}';
    final cached = _avatarMarkerCache[cacheKey];
    if (cached != null) return cached;

    const size = 128.0;
    const imageSize = 88.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const center = Offset(size / 2, size / 2);

    canvas.drawCircle(
      center,
      size * 0.46,
      Paint()..color = borderColor.withValues(alpha: 0.20),
    );
    canvas.drawCircle(
      center,
      size * 0.34,
      Paint()..color = Colors.white,
    );

    final avatarImage = await _loadMarkerImage(safeUrl) ??
        await _loadMarkerImage(UserService.defaultProfileImageUrl);
    final imageRect = Rect.fromCenter(
      center: center,
      width: imageSize,
      height: imageSize,
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(imageRect));
    if (avatarImage != null) {
      final src = Rect.fromLTWH(
        0,
        0,
        avatarImage.width.toDouble(),
        avatarImage.height.toDouble(),
      );
      canvas.drawImageRect(avatarImage, src, imageRect, Paint());
    } else {
      canvas.drawCircle(
        center,
        imageSize / 2,
        Paint()..color = ColorSys.primaryTint,
      );
    }
    canvas.restore();

    canvas.drawCircle(
      center,
      imageSize / 2,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    canvas.drawCircle(
      center,
      imageSize / 2,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final pointerPath = Path()
      ..moveTo(center.dx - 10, center.dy + 42)
      ..lineTo(center.dx + 10, center.dy + 42)
      ..lineTo(center.dx, center.dy + 58)
      ..close();
    canvas.drawPath(
      pointerPath,
      Paint()..color = Colors.white,
    );
    canvas.drawPath(
      pointerPath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final markerBytes = bytes!.buffer.asUint8List();
    _avatarMarkerCache[cacheKey] = markerBytes;
    return markerBytes;
  }

  Future<Uint8List> _buildCurrentLocationMarker() async {
    final cached = _currentLocationMarker;
    if (cached != null) return cached;

    const size = 180.0;
    const center = Offset(size / 2, size / 2);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final directionPath = Path()
      ..moveTo(center.dx - 14, center.dy + 14)
      ..quadraticBezierTo(
        center.dx - 44,
        center.dy + 56,
        center.dx - 58,
        size - 14,
      )
      ..lineTo(center.dx + 58, size - 14)
      ..quadraticBezierTo(
        center.dx + 44,
        center.dy + 56,
        center.dx + 14,
        center.dy + 14,
      )
      ..close();

    canvas.drawPath(
      directionPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(center.dx, center.dy + 14),
          Offset(center.dx, size - 14),
          const <Color>[
            Color(0xCC245CFF),
            Color(0x7A245CFF),
            Color(0x10245CFF),
          ],
          const <double>[0, 0.55, 1],
        ),
    );
    canvas.drawCircle(
      center,
      34,
      Paint()..color = const Color(0x33245CFF),
    );
    canvas.drawCircle(center, 24, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      16,
      Paint()..color = const Color(0xFF245CFF),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final markerBytes = bytes!.buffer.asUint8List();
    _currentLocationMarker = markerBytes;
    return markerBytes;
  }

  Widget _buildProfileAvatar(String imageUrl) {
    final safeUrl = _safeProfileImageUrl(imageUrl);
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        safeUrl,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.network(
          UserService.defaultProfileImageUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 52,
            height: 52,
            color: ColorSys.primaryTint,
          ),
        ),
      ),
    );
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    final generation = ++_mapGeneration;
    _mapboxMap = map;
    _pointAnnotationManager = null;
    _polylineAnnotationManager = null;
    _lastRenderedRouteKey = '';

    final coordinates = _latestCoordinates;
    if (coordinates != null) {
      await map.setCamera(_initialCameraOptions(coordinates));
      if (!_isCurrentMap(map, generation)) return;
    }

    final pointAnnotationManager =
        await map.annotations.createPointAnnotationManager();
    if (!_isCurrentMap(map, generation)) return;
    final polylineAnnotationManager =
        await map.annotations.createPolylineAnnotationManager();
    if (!_isCurrentMap(map, generation)) return;

    _pointAnnotationManager = pointAnnotationManager;
    _polylineAnnotationManager = polylineAnnotationManager;
    await map.compass.updateSettings(CompassSettings(enabled: false));
    if (!_isCurrentMap(map, generation)) return;
    if (mounted) setState(() {});
    if (_latestTrackingData.isNotEmpty) {
      _scheduleRender(_latestTrackingData);
    }
  }

  bool _isCurrentMap(MapboxMap map, int generation) {
    return mounted &&
        !_isDisposed &&
        generation == _mapGeneration &&
        identical(_mapboxMap, map);
  }

  Future<void> _refreshOfficerData(String officerId) async {
    if (officerId.trim().isEmpty) return;
    try {
      final data = await _userService.fetchAnyUserDataById(officerId);
      if (!mounted || data == null) return;
      setState(() {
        _officerUserData = data;
      });
      if (_latestTrackingData.isNotEmpty) {
        _scheduleRender(_latestTrackingData);
      }
    } catch (_) {
      // Conversation data is still enough to keep the tracking screen usable.
    }
  }

  void _ensureOfficerRefresh(String officerId) {
    if (officerId.trim().isEmpty || officerId == _lastOfficerId) return;
    _lastOfficerId = officerId;
    _officerLocationSubscription?.cancel();
    unawaited(_refreshOfficerData(officerId));
    _officerLocationSubscription =
        _userService.watchAnyUserDataById(officerId).listen(
      (data) {
        if (!mounted || data == null) return;
        setState(() {
          _officerUserData = data;
        });
        if (_latestTrackingData.isNotEmpty) {
          _scheduleRender(_latestTrackingData);
        }
      },
      onError: (_) {
        // Conversation coordinates remain available if the profile stream fails.
      },
    );
  }

  Future<void> _refreshPilgrimData(String pilgrimId) async {
    if (pilgrimId.trim().isEmpty) return;
    try {
      final data = await _userService.fetchAnyUserDataById(pilgrimId);
      if (!mounted || data == null) return;
      setState(() {
        _pilgrimUserData = data;
      });
      if (_latestTrackingData.isNotEmpty) {
        _scheduleRender(_latestTrackingData);
      }
    } catch (_) {
      // Conversation data remains available if the live profile cannot load.
    }
  }

  void _ensurePilgrimRefresh(String pilgrimId) {
    if (pilgrimId.trim().isEmpty || pilgrimId == _lastPilgrimId) return;
    _lastPilgrimId = pilgrimId;
    _pilgrimLocationSubscription?.cancel();
    unawaited(_refreshPilgrimData(pilgrimId));
    _pilgrimLocationSubscription =
        _userService.watchAnyUserDataById(pilgrimId).listen(
      (data) {
        if (!mounted || data == null) return;
        setState(() {
          _pilgrimUserData = data;
        });
        if (_latestTrackingData.isNotEmpty) {
          _scheduleRender(_latestTrackingData);
        }
      },
      onError: (_) {
        // Conversation coordinates remain available if the profile stream fails.
      },
    );
  }

  Future<void> _ensureDeviceLocationTracking() async {
    if (_deviceLocationSubscription != null || _isStartingDeviceTracking) {
      return;
    }

    final data = _latestTrackingData;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final officerId = data['officerId']?.toString() ?? '';
    final pilgrimId = data['pilgrimId']?.toString() ?? '';
    if (uid.isEmpty || (uid != officerId && uid != pilgrimId)) return;

    _isStartingDeviceTracking = true;
    try {
      if (!await geo.Geolocator.isLocationServiceEnabled()) return;

      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }
      if (permission == geo.LocationPermission.denied ||
          permission == geo.LocationPermission.deniedForever) {
        return;
      }

      try {
        final initialPosition = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.bestForNavigation,
        );
        _applyDevicePosition(initialPosition);
      } catch (_) {
        // The live stream can still provide a position after a transient error.
      }

      const settings = geo.LocationSettings(
        accuracy: geo.LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      );
      _deviceLocationSubscription = geo.Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen(
        _applyDevicePosition,
        onError: (_) {
          // Keep the last valid coordinates when GPS is temporarily unavailable.
        },
      );
    } finally {
      _isStartingDeviceTracking = false;
    }
  }

  void _applyDevicePosition(geo.Position position) {
    if (!mounted ||
        !position.latitude.isFinite ||
        !position.longitude.isFinite) {
      return;
    }

    final data = _latestTrackingData;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final currentIsPetugas = uid == (data['officerId']?.toString() ?? '');
    final currentIsPilgrim = uid == (data['pilgrimId']?.toString() ?? '');
    if (!currentIsPetugas && !currentIsPilgrim) return;

    final currentData = currentIsPetugas
        ? Map<String, dynamic>.from(_officerUserData)
        : Map<String, dynamic>.from(_pilgrimUserData);
    final previousLat = _toDouble(currentData['latitude']);
    final previousLng = _toDouble(currentData['longitude']);
    if (previousLat != 0 && previousLng != 0) {
      final movement = geo.Geolocator.distanceBetween(
        previousLat,
        previousLng,
        position.latitude,
        position.longitude,
      );
      if (movement < 0.5) return;
    }

    currentData
      ..['latitude'] = position.latitude
      ..['longitude'] = position.longitude;
    setState(() {
      if (currentIsPetugas) {
        _officerUserData = currentData;
      } else {
        _pilgrimUserData = currentData;
      }
    });
    _scheduleRender(data);
    unawaited(_publishDeviceLocation(position));
  }

  Future<void> _publishDeviceLocation(geo.Position position) async {
    if (_isPublishingDeviceLocation) return;

    final previous = _lastPublishedDevicePosition;
    final lastPublishedAt = _lastPublishedDeviceLocationAt;
    final distance = previous == null
        ? double.infinity
        : geo.Geolocator.distanceBetween(
            previous.latitude,
            previous.longitude,
            position.latitude,
            position.longitude,
          );
    final elapsed = lastPublishedAt == null
        ? const Duration(days: 1)
        : DateTime.now().difference(lastPublishedAt);
    if (distance < 2 && elapsed < const Duration(seconds: 4)) return;

    _isPublishingDeviceLocation = true;
    try {
      await _userService.updateCurrentUserLocation(
        position.latitude,
        position.longitude,
      );
      _lastPublishedDevicePosition = position;
      _lastPublishedDeviceLocationAt = DateTime.now();
    } catch (_) {
      // Local movement remains visible even if a network update is delayed.
    } finally {
      _isPublishingDeviceLocation = false;
    }
  }

  Future<_TrackingRoute?> _fetchRoute({
    required double officerLat,
    required double officerLng,
    required double pilgrimLat,
    required double pilgrimLng,
  }) async {
    final token = dotenv.env['MAPBOX_SECRET_KEY']?.trim() ?? '';
    if (token.isEmpty) return null;

    try {
      final response = await http
          .get(
            Uri.parse(
              'https://api.mapbox.com/directions/v5/mapbox/walking/$officerLng,$officerLat;$pilgrimLng,$pilgrimLat?alternatives=false&continue_straight=true&geometries=geojson&overview=full&steps=false&language=id&voice_units=metric&access_token=$token',
            ),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List<dynamic>? ?? [];
      if (routes.isEmpty || routes.first is! Map<String, dynamic>) return null;
      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>? ?? {};
      final rawCoordinates = geometry['coordinates'] as List<dynamic>? ?? [];
      final coordinates = rawCoordinates
          .whereType<List<dynamic>>()
          .where((value) => value.length >= 2)
          .map(
            (value) => Position(
              (value[0] as num).toDouble(),
              (value[1] as num).toDouble(),
            ),
          )
          .toList();

      return _TrackingRoute(
        coordinates: coordinates,
        distanceMeters: (route['distance'] as num?)?.toDouble() ?? 0,
        durationSeconds: (route['duration'] as num?)?.toDouble() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _renderTrackingMap({
    required double officerLat,
    required double officerLng,
    required double pilgrimLat,
    required double pilgrimLng,
    required String officerImageUrl,
    required String pilgrimImageUrl,
    required bool currentIsPetugas,
  }) async {
    final map = _mapboxMap;
    final pointAnnotationManager = _pointAnnotationManager;
    final polylineAnnotationManager = _polylineAnnotationManager;
    final generation = _mapGeneration;
    if (map == null ||
        pointAnnotationManager == null ||
        polylineAnnotationManager == null ||
        !_isCurrentMap(map, generation)) {
      return;
    }

    bool mapIsCurrent() {
      return _isCurrentMap(map, generation) &&
          identical(pointAnnotationManager, _pointAnnotationManager) &&
          identical(polylineAnnotationManager, _polylineAnnotationManager);
    }

    final safeOfficerImageUrl = _safeProfileImageUrl(officerImageUrl);
    final safePilgrimImageUrl = _safeProfileImageUrl(pilgrimImageUrl);
    final routeKey =
        '${officerLat.toStringAsFixed(6)},${officerLng.toStringAsFixed(6)}:'
        '${pilgrimLat.toStringAsFixed(6)},${pilgrimLng.toStringAsFixed(6)}:'
        '$safeOfficerImageUrl:$safePilgrimImageUrl:$currentIsPetugas';
    if (routeKey == _lastRenderedRouteKey) return;
    if (_isRenderingRoute) {
      _renderRequested = true;
      return;
    }
    _lastRenderedRouteKey = routeKey;
    _isRenderingRoute = true;

    try {
      final directMeters = calculateHaversineDistance(
            officerLat,
            officerLng,
            pilgrimLat,
            pilgrimLng,
          ) *
          1000;

      await _fitCameraToPoints(
        <Point>[
          Point(coordinates: Position(officerLng, officerLat)),
          Point(coordinates: Position(pilgrimLng, pilgrimLat)),
        ],
        map: map,
        generation: generation,
        fallback: CameraOptions(
          center: Point(
            coordinates: Position(
              (officerLng + pilgrimLng) / 2,
              (officerLat + pilgrimLat) / 2,
            ),
          ),
          zoom: directMeters > 900 ? 14.8 : 16.5,
          bearing: 0,
          pitch: 0,
        ),
      );
      if (!mapIsCurrent()) return;

      final routeFuture = _fetchRoute(
        officerLat: officerLat,
        officerLng: officerLng,
        pilgrimLat: pilgrimLat,
        pilgrimLng: pilgrimLng,
      );
      final currentLocationMarkerFuture = _buildCurrentLocationMarker();
      final otherUserMarkerFuture = _buildAvatarMarker(
        imageUrl: currentIsPetugas ? safePilgrimImageUrl : safeOfficerImageUrl,
        borderColor: currentIsPetugas ? ColorSys.error : ColorSys.darkBlue,
      );

      final route = await routeFuture;
      if (!mapIsCurrent()) return;

      if (mounted && mapIsCurrent()) {
        setState(() {
          _routeDistanceMeters = route?.distanceMeters ?? directMeters;
          _routeDurationSeconds = route?.durationSeconds ?? 0;
          _hasRouteMetrics = true;
        });
      }

      if (!mapIsCurrent()) return;
      await polylineAnnotationManager.deleteAll();
      if (!mapIsCurrent()) return;

      final coordinates = route?.coordinates ??
          <Position>[
            Position(officerLng, officerLat),
            Position(pilgrimLng, pilgrimLat),
          ];
      if (coordinates.isNotEmpty) {
        await polylineAnnotationManager.setLineCap(LineCap.ROUND);
        if (!mapIsCurrent()) return;
        await polylineAnnotationManager.setLineJoin(LineJoin.ROUND);
        if (!mapIsCurrent()) return;
        await polylineAnnotationManager.create(
          PolylineAnnotationOptions(
            geometry: LineString(coordinates: coordinates),
            lineJoin: LineJoin.ROUND,
            lineColor: ColorSys.darkBlue.toARGB32(),
            lineWidth: 7,
            lineBlur: 0.2,
          ),
        );
        if (!mapIsCurrent()) return;
      }

      final routePoints = <Point>[
        Point(coordinates: Position(officerLng, officerLat)),
        ...coordinates.map((coordinate) => Point(coordinates: coordinate)),
        Point(coordinates: Position(pilgrimLng, pilgrimLat)),
      ];

      await _fitCameraToPoints(
        routePoints,
        map: map,
        generation: generation,
        fallback: CameraOptions(
          center: Point(
            coordinates: Position(
              (officerLng + pilgrimLng) / 2,
              (officerLat + pilgrimLat) / 2,
            ),
          ),
          zoom: directMeters > 900 ? 14.8 : 16.5,
          bearing: 0,
          pitch: 0,
        ),
      );
      if (!mapIsCurrent()) return;

      final currentLocationMarker = await currentLocationMarkerFuture;
      if (!mapIsCurrent()) return;
      final otherUserMarker = await otherUserMarkerFuture;
      if (!mapIsCurrent() || _lastRenderedRouteKey != routeKey) return;
      final markersAreClose = directMeters < 18;
      await pointAnnotationManager.deleteAll();
      if (!mapIsCurrent()) return;
      final currentPosition = currentIsPetugas
          ? Position(officerLng, officerLat)
          : Position(pilgrimLng, pilgrimLat);
      final otherPosition = currentIsPetugas
          ? Position(pilgrimLng, pilgrimLat)
          : Position(officerLng, officerLat);
      await pointAnnotationManager.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: currentPosition),
          image: currentLocationMarker,
          iconSize: 0.55,
          iconAnchor: IconAnchor.CENTER,
        ),
      );
      if (!mapIsCurrent()) return;
      await pointAnnotationManager.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: otherPosition),
          image: otherUserMarker,
          iconSize: 0.78,
          iconAnchor: IconAnchor.BOTTOM,
          iconOffset: markersAreClose
              ? <double?>[currentIsPetugas ? 38 : -38, 0]
              : null,
        ),
      );
    } finally {
      _isRenderingRoute = false;
      if (_renderRequested && mounted && !_isDisposed) {
        _renderRequested = false;
        _scheduleRender(_latestTrackingData);
      }
    }
  }

  Future<void> _fitCameraToPoints(
    List<Point> points, {
    required MapboxMap map,
    required int generation,
    required CameraOptions fallback,
  }) async {
    if (!_isCurrentMap(map, generation)) return;
    try {
      final camera = await map.cameraForCoordinatesPadding(
        points,
        CameraOptions(bearing: 0, pitch: 0),
        MbxEdgeInsets(top: 130, left: 36, bottom: 360, right: 36),
        18,
        null,
      );
      if (!_isCurrentMap(map, generation)) return;
      await map.setCamera(camera);
    } catch (_) {
      if (!_isCurrentMap(map, generation)) return;
      await map.setCamera(fallback);
    }
  }

  void _scheduleRender(Map<String, dynamic> data) {
    _latestTrackingData = Map<String, dynamic>.from(data);
    final coordinates = _resolveTrackingCoordinates(data);
    if (coordinates == null) return;
    final officerImageUrl = _preferredProfileImageUrl([
      _officerUserData['imageUrl'],
      data['officerImageUrl'],
    ]);
    final pilgrimImageUrl = _preferredProfileImageUrl([
      _pilgrimUserData['imageUrl'],
      data['pilgrimImageUrl'],
    ]);
    final currentIsPetugas = _currentIsPetugas(data);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;
      unawaited(
        _renderTrackingMap(
          officerLat: coordinates.officerLat,
          officerLng: coordinates.officerLng,
          pilgrimLat: coordinates.pilgrimLat,
          pilgrimLng: coordinates.pilgrimLng,
          officerImageUrl: officerImageUrl,
          pilgrimImageUrl: pilgrimImageUrl,
          currentIsPetugas: currentIsPetugas,
        ),
      );
    });
  }

  void _openFullRoute(Map<String, dynamic> data) {
    final currentIsPetugas = _currentIsPetugas(data);
    final officerLat = _toDouble(_officerUserData['latitude']) != 0
        ? _toDouble(_officerUserData['latitude'])
        : _toDouble(data['officerLat']);
    final officerLng = _toDouble(_officerUserData['longitude']) != 0
        ? _toDouble(_officerUserData['longitude'])
        : _toDouble(data['officerLng']);
    final pilgrimLat = _toDouble(_pilgrimUserData['latitude']) != 0
        ? _toDouble(_pilgrimUserData['latitude'])
        : _toDouble(data['pilgrimLat']);
    final pilgrimLng = _toDouble(_pilgrimUserData['longitude']) != 0
        ? _toDouble(_pilgrimUserData['longitude'])
        : _toDouble(data['pilgrimLng']);
    final targetLat = currentIsPetugas ? pilgrimLat : officerLat;
    final targetLng = currentIsPetugas ? pilgrimLng : officerLng;
    if (targetLat == 0 || targetLng == 0) return;

    final targetUser = UserModel.fromMap({
      ...data,
      if (currentIsPetugas) ..._pilgrimUserData else ..._officerUserData,
      'userId': currentIsPetugas
          ? data['pilgrimId']?.toString() ?? ''
          : data['officerId']?.toString() ?? '',
      'displayName': currentIsPetugas
          ? _pilgrimUserData['displayName']?.toString() ??
              data['pilgrimName']?.toString() ??
              'Jemaah Haji'
          : _officerUserData['displayName']?.toString() ??
              data['officerName']?.toString() ??
              'Petugas Haji',
      'roles': currentIsPetugas
          ? _pilgrimUserData['roles']?.toString() ??
              data['pilgrimRole']?.toString() ??
              'Jemaah Haji'
          : _officerUserData['roles']?.toString() ??
              data['officerRole']?.toString() ??
              'Petugas Haji',
      'imageUrl': currentIsPetugas
          ? _pilgrimUserData['imageUrl']?.toString() ??
              data['pilgrimImageUrl']?.toString() ??
              ''
          : _officerUserData['imageUrl']?.toString() ??
              data['officerImageUrl']?.toString() ??
              '',
      'latitude': targetLat,
      'longitude': targetLng,
    })
      ..distance = _formatDistance(_routeDistanceMeters)
      ..duration = _formatDuration(
        _routeDurationSeconds,
        distanceMeters: _routeDistanceMeters,
      );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DirectionMapScreen(officer: targetUser),
      ),
    );
  }

  void _openChat(Map<String, dynamic> data) {
    final currentIsPetugas = _currentIsPetugas(data);
    final peerId = currentIsPetugas
        ? data['pilgrimId']?.toString() ?? ''
        : data['officerId']?.toString() ?? '';
    final peerName = currentIsPetugas
        ? _pilgrimUserData['displayName']?.toString() ??
            data['pilgrimName']?.toString() ??
            'Jemaah Haji'
        : _officerUserData['displayName']?.toString() ??
            data['officerName']?.toString() ??
            'Petugas Haji';
    final peerImageUrl = currentIsPetugas
        ? _preferredProfileImageUrl([
            _pilgrimUserData['imageUrl'],
            data['pilgrimImageUrl'],
          ])
        : _preferredProfileImageUrl([
            _officerUserData['imageUrl'],
            data['officerImageUrl'],
          ]);
    final peerRole = currentIsPetugas
        ? _pilgrimUserData['roles']?.toString() ??
            data['pilgrimRole']?.toString() ??
            'Jemaah Haji'
        : _officerUserData['roles']?.toString() ??
            data['officerRole']?.toString() ??
            'Petugas Haji';

    Navigator.pushNamed(
      context,
      '/help_chat',
      arguments: {
        'conversationId': _conversationId,
        'readOnly': data['archived'] == true ||
            HelpService.statusIsFinal(
              data['status']?.toString() ?? HelpService.statusRequested,
            ),
        'peerId': peerId,
        'peerName': peerName,
        'peerImageUrl': peerImageUrl,
        'peerIsPetugas': !currentIsPetugas,
        'peerRole': peerRole,
      },
    );
  }

  Future<void> _updateStatus(String status) async {
    if (_isUpdatingStatus || _conversationId.trim().isEmpty) return;
    setState(() {
      _isUpdatingStatus = true;
    });
    try {
      await _helpService.updateConversationStatus(
        conversationId: _conversationId,
        status: status,
      );
      if (status == HelpService.statusRejected && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Status Gagal Diperbarui',
        message: 'Status bantuan tidak dapat diperbarui: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _requestHelpAgain(Map<String, dynamic> data) async {
    if (_isUpdatingStatus) return;

    final officerId = data['officerId']?.toString().trim() ?? '';
    if (officerId.isEmpty) return;

    setState(() => _isUpdatingStatus = true);
    try {
      final handle = await _helpService.ensureConversationWithPeer(
        peerId: officerId,
        peerName: _officerUserData['displayName']?.toString() ??
            data['officerName']?.toString() ??
            'Petugas Haji',
        peerImageUrl: _officerUserData['imageUrl']?.toString() ??
            data['officerImageUrl']?.toString() ??
            '',
        peerIsPetugas: true,
        peerRole: _officerUserData['roles']?.toString() ??
            data['officerRole']?.toString() ??
            'Petugas Haji',
        peerLatitude: _toDouble(_officerUserData['latitude']) != 0
            ? _toDouble(_officerUserData['latitude'])
            : _toDouble(data['officerLat']),
        peerLongitude: _toDouble(_officerUserData['longitude']) != 0
            ? _toDouble(_officerUserData['longitude'])
            : _toDouble(data['officerLng']),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        '/help_tracking',
        arguments: {'conversationId': handle.conversationId},
      );
    } catch (_) {
      if (!mounted) return;
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Permintaan Belum Terkirim',
        message: 'Permintaan bantuan belum dapat dikirim. Silakan coba lagi.',
      );
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _completeSession() async {
    if (_isUpdatingStatus || _conversationId.trim().isEmpty) return;
    final confirmed = await showAppConfirmPopup(
      context,
      type: AppPopupType.warning,
      title: 'Akhiri Sesi Bantuan?',
      message: 'Pastikan jemaah sudah ditemukan dan bantuan telah selesai. '
          ' Setelah sesi diakhiri, percakapan akan disimpan ke arsip.',
      cancelText: 'Kembali',
      confirmText: 'Akhiri Bantuan',
      accentOverride: ColorSys.error,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isUpdatingStatus = true);
    try {
      await _helpService.completeHelpSession(_conversationId);
      if (!mounted) return;
      await showAppPopup(
        context,
        type: AppPopupType.success,
        title: 'Bantuan Selesai',
        message: 'Sesi bantuan telah diakhiri dan disimpan sebagai arsip.',
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Sesi Belum Dapat Diakhiri',
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _confirmArrival() async {
    if (_isUpdatingStatus || _conversationId.trim().isEmpty) return;

    final confirmed = await showAppConfirmPopup(
      context,
      type: AppPopupType.info,
      title: 'Konfirmasi Kedatangan',
      message: 'Pastikan Anda sudah berada di sekitar lokasi jemaah. '
          'Jemaah akan menerima pemberitahuan bahwa Anda telah tiba.',
      cancelText: 'Batal',
      confirmText: 'Ya, Sudah Sampai',
    );
    if (!confirmed || !mounted) return;

    await _updateStatus(HelpService.statusArrived);
  }

  Widget _buildMessageButton({
    required Map<String, dynamic> data,
    required int unreadCount,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () => _openChat(data),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: ColorSys.primaryTint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Iconsax.message_text,
              color: ColorSys.darkBlue,
              size: 22,
            ),
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: ColorSys.error,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                textAlign: TextAlign.center,
                style: textStyle(
                  fontSize: 9.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildStatusActions({
    required Map<String, dynamic> data,
    required String status,
    required bool currentIsPetugas,
  }) {
    if (!currentIsPetugas) {
      if (status == HelpService.statusRejected) {
        return [
          Expanded(
            child: ElevatedButton(
              onPressed:
                  _isUpdatingStatus ? null : () => _requestHelpAgain(data),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: ColorSys.darkBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'Minta Bantuan Lagi',
                style: textStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ];
      }

      if (status == HelpService.statusClosed) {
        return [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: ColorSys.darkBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'Kembali',
                style: textStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ];
      }

      // Active journey states are presented as progress, not as fake buttons.
      return const [];
    }

    if (status == HelpService.statusRequested) {
      return [
        Expanded(
          child: OutlinedButton(
            onPressed: _isUpdatingStatus
                ? null
                : () => _updateStatus(HelpService.statusRejected),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: ColorSys.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text(
              'Tolak',
              style: textStyle(
                fontSize: 14,
                color: ColorSys.error,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _isUpdatingStatus
                ? null
                : () => _updateStatus(HelpService.statusAccepted),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: ColorSys.darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text(
              'Terima',
              style: textStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ];
    }

    if (status == HelpService.statusAccepted) {
      return [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isUpdatingStatus
                ? null
                : () => _updateStatus(HelpService.statusOnTheWay),
            icon: const Icon(Iconsax.direct_up, color: Colors.white),
            label: Text(
              'Berangkat Sekarang',
              style: textStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: ColorSys.darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ];
    }

    if (status == HelpService.statusOnTheWay) {
      return [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _openFullRoute(data),
            icon: const Icon(Iconsax.direct_up,
                size: 18, color: ColorSys.darkBlue),
            label: Text(
              'Buka Rute',
              style: textStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: ColorSys.darkBlue),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: ColorSys.lightBlue),
              backgroundColor: ColorSys.primaryTint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isUpdatingStatus ? null : _confirmArrival,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: ColorSys.darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            icon: const Icon(
              Iconsax.location_tick,
              size: 19,
              color: Colors.white,
            ),
            label: Text(
              'Sudah Sampai',
              style: textStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ];
    }

    if (status == HelpService.statusArrived) {
      return [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isUpdatingStatus ? null : _completeSession,
            icon: const Icon(Iconsax.tick_circle, color: Colors.white),
            label: Text(
              'Akhiri Sesi',
              style: textStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: ColorSys.darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ];
    }

    if (status == HelpService.statusClosed ||
        status == HelpService.statusRejected) {
      return [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: ColorSys.darkBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text(
              'Kembali',
              style: textStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ];
    }

    return [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () => _openFullRoute(data),
          icon: const Icon(Iconsax.direct_up, color: ColorSys.darkBlue),
          label: Text(
            'Buka Rute',
            style: textStyle(
              fontSize: 14,
              color: ColorSys.darkBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: ColorSys.primaryTint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    ];
  }

  int _journeyStepIndex(String status) {
    return switch (status) {
      HelpService.statusAccepted => 1,
      HelpService.statusOnTheWay => 2,
      HelpService.statusArrived => 3,
      HelpService.statusClosed => 3,
      _ => 0,
    };
  }

  Widget _buildJourneyProgress(String status) {
    const labels = ['Menunggu', 'Diterima', 'Menuju', 'Tiba'];
    final currentStep = _journeyStepIndex(status);

    return Column(
      children: [
        Row(
          children: [
            for (var index = 0; index < labels.length; index++) ...[
              if (index > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index <= currentStep
                        ? ColorSys.darkBlue
                        : Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              _JourneyStepDot(
                isCompleted: index < currentStep,
                isCurrent: index == currentStep,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var index = 0; index < labels.length; index++)
              Expanded(
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: textStyle(
                    fontSize: 9.5,
                    color: index <= currentStep
                        ? ColorSys.darkBlue
                        : ColorSys.textSecondary.withValues(alpha: 0.65),
                    fontWeight: index == currentStep
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackingPanel(Map<String, dynamic> data) {
    final status = data['status']?.toString() ?? HelpService.statusRequested;
    final currentIsPetugas = _currentIsPetugas(data);
    final unreadCount = _unreadMessageCount(data);
    final peerName = toTitleCaseName(
      currentIsPetugas
          ? _pilgrimUserData['displayName']?.toString() ??
              data['pilgrimName']?.toString() ??
              'Jemaah Haji'
          : _officerUserData['displayName']?.toString() ??
              data['officerName']?.toString() ??
              'Petugas Haji',
    );
    final peerRole = currentIsPetugas
        ? _pilgrimUserData['roles']?.toString().trim() ??
            data['pilgrimRole']?.toString().trim() ??
            'Jemaah Haji'
        : _officerUserData['roles']?.toString().trim() ??
            data['officerRole']?.toString().trim() ??
            'Petugas Haji';
    final peerKloter = currentIsPetugas
        ? _formatKloter(
            _pilgrimUserData['kloter'] ?? data['pilgrimKloter'],
          )
        : '';
    final peerRoleLabel = peerKloter.isEmpty
        ? peerRole
        : '${peerRole.isEmpty ? 'Jemaah Haji' : peerRole} ($peerKloter)';
    final peerImageUrl = currentIsPetugas
        ? _pilgrimUserData['imageUrl']?.toString() ??
            data['pilgrimImageUrl']?.toString() ??
            ''
        : _officerUserData['imageUrl']?.toString() ??
            data['officerImageUrl']?.toString() ??
            '';
    final actions = _buildStatusActions(
      data: data,
      status: status,
      currentIsPetugas: currentIsPetugas,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: ColorSys.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ColorSys.primaryTint,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildProfileAvatar(peerImageUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle(
                          fontSize: 17,
                          color: ColorSys.darkBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        peerRoleLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle(
                          fontSize: 11.5,
                          color: ColorSys.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _buildMessageButton(
                  data: data,
                  unreadCount: unreadCount,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColorSys.primaryTint.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _statusTitle(
                      status,
                      currentIsPetugas: currentIsPetugas,
                    ),
                    style: textStyle(
                      fontSize: 14,
                      color: ColorSys.darkBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _statusMessage(
                      status,
                      currentIsPetugas: currentIsPetugas,
                    ),
                    style: textStyle(
                      fontSize: 12,
                      color: ColorSys.textSecondary,
                    ),
                  ),
                  if (!currentIsPetugas &&
                      status != HelpService.statusRejected) ...[
                    const SizedBox(height: 14),
                    _buildJourneyProgress(status),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _TrackingMetric(
                        icon: Icons.directions_walk,
                        label: 'Jarak',
                        value: _formatDistance(_routeDistanceMeters),
                      ),
                      const SizedBox(width: 10),
                      _TrackingMetric(
                        icon: Iconsax.clock,
                        label: 'Estimasi',
                        value: _formatDuration(
                          _routeDurationSeconds,
                          distanceMeters: _routeDistanceMeters,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Row(children: actions),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _conversationId.isEmpty
          ? Center(
              child: Text(
                'Data bantuan tidak tersedia.',
                style: textStyle(fontSize: 14, color: ColorSys.darkBlue),
              ),
            )
          : StreamBuilder<Map<String, dynamic>?>(
              stream: _conversationStream,
              builder: (context, snapshot) {
                final data = snapshot.data ?? <String, dynamic>{};
                final officerId = data['officerId']?.toString() ?? '';
                final pilgrimId = data['pilgrimId']?.toString() ?? '';
                _ensureOfficerRefresh(officerId);
                _ensurePilgrimRefresh(pilgrimId);
                final trackingCoordinates = _resolveTrackingCoordinates(data);
                _latestCoordinates = trackingCoordinates;
                _scheduleRender(data);
                unawaited(_ensureDeviceLocationTracking());

                return Stack(
                  children: [
                    if (trackingCoordinates != null)
                      MapWidget(
                        key: const ValueKey('help-tracking-map'),
                        styleUri: MapboxStyles.MAPBOX_STREETS,
                        cameraOptions:
                            _initialCameraOptions(trackingCoordinates),
                        onMapCreated: _onMapCreated,
                      )
                    else
                      const ColoredBox(
                        color: Color(0xFFF4F8FA),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: ColorSys.darkBlue,
                          ),
                        ),
                      ),
                    Positioned(
                      top: 54,
                      left: 18,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Iconsax.arrow_left_2,
                            color: ColorSys.darkBlue,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child:
                          snapshot.connectionState == ConnectionState.waiting &&
                                  !snapshot.hasData
                              ? Container(
                                  padding: const EdgeInsets.all(24),
                                  color: Colors.white,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: ColorSys.darkBlue,
                                    ),
                                  ),
                                )
                              : _buildTrackingPanel(data),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _TrackingRoute {
  const _TrackingRoute({
    required this.coordinates,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<Position> coordinates;
  final double distanceMeters;
  final double durationSeconds;
}

class _TrackingCoordinates {
  const _TrackingCoordinates({
    required this.officerLat,
    required this.officerLng,
    required this.pilgrimLat,
    required this.pilgrimLng,
  });

  final double officerLat;
  final double officerLng;
  final double pilgrimLat;
  final double pilgrimLng;
}

class _TrackingMetric extends StatelessWidget {
  const _TrackingMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: ColorSys.darkBlue, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textStyle(
                      fontSize: 10.5,
                      color: ColorSys.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle(
                      fontSize: 13,
                      color: ColorSys.darkBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyStepDot extends StatelessWidget {
  const _JourneyStepDot({
    required this.isCompleted,
    required this.isCurrent,
  });

  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final isActive = isCompleted || isCurrent;
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isCompleted
            ? ColorSys.success
            : isCurrent
                ? ColorSys.darkBlue
                : Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? Colors.transparent
              : ColorSys.border.withValues(alpha: 0.9),
        ),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : isCurrent
              ? Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
    );
  }
}
