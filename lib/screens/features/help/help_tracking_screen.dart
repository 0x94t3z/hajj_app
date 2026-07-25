import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  Timer? _officerRefreshTimer;

  String _conversationId = '';
  String _lastOfficerId = '';
  String _lastRenderedRouteKey = '';
  Map<String, dynamic> _officerUserData = <String, dynamic>{};
  double _routeDistanceMeters = 0;
  double _routeDurationSeconds = 0;
  bool _isRenderingRoute = false;
  bool _isUpdatingStatus = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
    final conversationId = args['conversationId']?.toString().trim() ?? '';
    if (conversationId.isNotEmpty && conversationId != _conversationId) {
      _conversationId = conversationId;
    }
  }

  @override
  void dispose() {
    _officerRefreshTimer?.cancel();
    super.dispose();
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _formatDistance(double meters) {
    if (meters <= 0) return '-';
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  String _formatDuration(double seconds) {
    if (seconds <= 0) return '-';
    final minutes = math.max(1, (seconds / 60).round());
    return '$minutes menit';
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
        return 'Silakan pilih petugas lain jika masih membutuhkan bantuan.';
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

  Future<ui.Image?> _loadMarkerImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return null;
      }
      final codec = await ui.instantiateImageCodec(
        response.bodyBytes,
        targetWidth: 92,
        targetHeight: 92,
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
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
    _mapboxMap = map;
    _pointAnnotationManager ??=
        await map.annotations.createPointAnnotationManager();
    _polylineAnnotationManager ??=
        await map.annotations.createPolylineAnnotationManager();
    await map.compass.updateSettings(CompassSettings(enabled: false));
    if (mounted) setState(() {});
  }

  Future<void> _refreshOfficerData(String officerId) async {
    if (officerId.trim().isEmpty) return;
    try {
      final data = await _userService.fetchAnyUserDataById(officerId);
      if (!mounted || data == null) return;
      setState(() {
        _officerUserData = data;
      });
    } catch (_) {
      // Conversation data is still enough to keep the tracking screen usable.
    }
  }

  void _ensureOfficerRefresh(String officerId) {
    if (officerId.trim().isEmpty || officerId == _lastOfficerId) return;
    _lastOfficerId = officerId;
    _officerRefreshTimer?.cancel();
    unawaited(_refreshOfficerData(officerId));
    _officerRefreshTimer = Timer.periodic(
      const Duration(seconds: 6),
      (_) => _refreshOfficerData(officerId),
    );
  }

  Future<_TrackingRoute?> _fetchRoute({
    required double officerLat,
    required double officerLng,
    required double pilgrimLat,
    required double pilgrimLng,
  }) async {
    final token = dotenv.env['MAPBOX_SECRET_KEY']?.trim() ?? '';
    if (token.isEmpty) return null;

    final response = await http.get(
      Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/walking/$officerLng,$officerLat;$pilgrimLng,$pilgrimLat?alternatives=false&continue_straight=true&geometries=geojson&overview=full&steps=false&language=id&voice_units=metric&access_token=$token',
      ),
    );
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
  }

  Future<void> _renderTrackingMap({
    required double officerLat,
    required double officerLng,
    required double pilgrimLat,
    required double pilgrimLng,
    required String officerImageUrl,
    required String pilgrimImageUrl,
  }) async {
    if (_mapboxMap == null || _isRenderingRoute) return;
    final safeOfficerImageUrl = _safeProfileImageUrl(officerImageUrl);
    final safePilgrimImageUrl = _safeProfileImageUrl(pilgrimImageUrl);
    final routeKey =
        '${officerLat.toStringAsFixed(6)},${officerLng.toStringAsFixed(6)}:'
        '${pilgrimLat.toStringAsFixed(6)},${pilgrimLng.toStringAsFixed(6)}:'
        '$safeOfficerImageUrl:$safePilgrimImageUrl';
    if (routeKey == _lastRenderedRouteKey) return;
    _lastRenderedRouteKey = routeKey;
    _isRenderingRoute = true;

    try {
      final route = await _fetchRoute(
        officerLat: officerLat,
        officerLng: officerLng,
        pilgrimLat: pilgrimLat,
        pilgrimLng: pilgrimLng,
      );
      final directMeters = calculateHaversineDistance(
            officerLat,
            officerLng,
            pilgrimLat,
            pilgrimLng,
          ) *
          1000;

      if (mounted) {
        setState(() {
          _routeDistanceMeters = route?.distanceMeters ?? directMeters;
          _routeDurationSeconds = route?.durationSeconds ?? 0;
        });
      }

      await _pointAnnotationManager?.deleteAll();
      await _polylineAnnotationManager?.deleteAll();
      final officerMarker = await _buildAvatarMarker(
        imageUrl: safeOfficerImageUrl,
        borderColor: ColorSys.darkBlue,
      );
      final pilgrimMarker = await _buildAvatarMarker(
        imageUrl: safePilgrimImageUrl,
        borderColor: ColorSys.error,
      );

      final coordinates = route?.coordinates ??
          <Position>[
            Position(officerLng, officerLat),
            Position(pilgrimLng, pilgrimLat),
          ];
      if (coordinates.isNotEmpty) {
        await _polylineAnnotationManager?.setLineCap(LineCap.ROUND);
        await _polylineAnnotationManager?.setLineJoin(LineJoin.ROUND);
        await _polylineAnnotationManager?.setLineDasharray([0.01, 1.8]);
        await _polylineAnnotationManager?.create(
          PolylineAnnotationOptions(
            geometry: LineString(coordinates: coordinates),
            lineJoin: LineJoin.ROUND,
            lineColor: ColorSys.navigationRouteBorder.toARGB32(),
            lineWidth: 7,
            lineBlur: 0.2,
          ),
        );
      }

      await _pointAnnotationManager?.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(officerLng, officerLat)),
          image: officerMarker,
          iconSize: 0.78,
        ),
      );
      await _pointAnnotationManager?.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(pilgrimLng, pilgrimLat)),
          image: pilgrimMarker,
          iconSize: 0.78,
        ),
      );

      final routePoints = <Point>[
        Point(coordinates: Position(officerLng, officerLat)),
        ...coordinates.map((coordinate) => Point(coordinates: coordinate)),
        Point(coordinates: Position(pilgrimLng, pilgrimLat)),
      ];

      try {
        final camera = await _mapboxMap?.cameraForCoordinatesPadding(
          routePoints,
          CameraOptions(
            bearing: 0,
            pitch: 0,
          ),
          MbxEdgeInsets(
            top: 130,
            left: 36,
            bottom: 360,
            right: 36,
          ),
          18,
          null,
        );
        if (camera != null) {
          await _mapboxMap?.easeTo(
            camera,
            MapAnimationOptions(duration: 700),
          );
        }
      } catch (_) {
        final centerLat = (officerLat + pilgrimLat) / 2;
        final centerLng = (officerLng + pilgrimLng) / 2;
        await _mapboxMap?.setCamera(
          CameraOptions(
            center: Point(coordinates: Position(centerLng, centerLat)),
            zoom: directMeters > 900 ? 15.5 : 17.2,
            bearing: 0,
            pitch: 0,
          ),
        );
      }
    } finally {
      _isRenderingRoute = false;
    }
  }

  void _scheduleRender(Map<String, dynamic> data) {
    final officerLat = _toDouble(_officerUserData['latitude']) != 0
        ? _toDouble(_officerUserData['latitude'])
        : _toDouble(data['officerLat']);
    final officerLng = _toDouble(_officerUserData['longitude']) != 0
        ? _toDouble(_officerUserData['longitude'])
        : _toDouble(data['officerLng']);
    final pilgrimLat = _toDouble(data['pilgrimLat']);
    final pilgrimLng = _toDouble(data['pilgrimLng']);
    final officerImageUrl = _officerUserData['imageUrl']?.toString() ??
        data['officerImageUrl']?.toString() ??
        '';
    final pilgrimImageUrl = data['pilgrimImageUrl']?.toString() ?? '';
    if (officerLat == 0 ||
        officerLng == 0 ||
        pilgrimLat == 0 ||
        pilgrimLng == 0) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        _renderTrackingMap(
          officerLat: officerLat,
          officerLng: officerLng,
          pilgrimLat: pilgrimLat,
          pilgrimLng: pilgrimLng,
          officerImageUrl: officerImageUrl,
          pilgrimImageUrl: pilgrimImageUrl,
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
    final pilgrimLat = _toDouble(data['pilgrimLat']);
    final pilgrimLng = _toDouble(data['pilgrimLng']);
    final targetLat = currentIsPetugas ? pilgrimLat : officerLat;
    final targetLng = currentIsPetugas ? pilgrimLng : officerLng;
    if (targetLat == 0 || targetLng == 0) return;

    final targetUser = UserModel.fromMap({
      ...data,
      if (!currentIsPetugas) ..._officerUserData,
      'userId': currentIsPetugas
          ? data['pilgrimId']?.toString() ?? ''
          : data['officerId']?.toString() ?? '',
      'displayName': currentIsPetugas
          ? data['pilgrimName']?.toString() ?? 'Jemaah Haji'
          : _officerUserData['displayName']?.toString() ??
              data['officerName']?.toString() ??
              'Petugas Haji',
      'roles': currentIsPetugas
          ? data['pilgrimRole']?.toString() ?? 'Jemaah Haji'
          : _officerUserData['roles']?.toString() ??
              data['officerRole']?.toString() ??
              'Petugas Haji',
      'imageUrl': currentIsPetugas
          ? data['pilgrimImageUrl']?.toString() ?? ''
          : _officerUserData['imageUrl']?.toString() ??
              data['officerImageUrl']?.toString() ??
              '',
      'latitude': targetLat,
      'longitude': targetLng,
    })
      ..distance = _formatDistance(_routeDistanceMeters)
      ..duration = _formatDuration(_routeDurationSeconds);

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
        ? data['pilgrimName']?.toString() ?? 'Jemaah Haji'
        : _officerUserData['displayName']?.toString() ??
            data['officerName']?.toString() ??
            'Petugas Haji';
    final peerImageUrl = currentIsPetugas
        ? data['pilgrimImageUrl']?.toString() ?? ''
        : _officerUserData['imageUrl']?.toString() ??
            data['officerImageUrl']?.toString() ??
            '';
    final peerRole = currentIsPetugas
        ? data['pilgrimRole']?.toString() ?? 'Jemaah Haji'
        : _officerUserData['roles']?.toString() ??
            data['officerRole']?.toString() ??
            'Petugas Haji';

    Navigator.pushNamed(
      context,
      '/help_chat',
      arguments: {
        'conversationId': _conversationId,
        'readOnly': data['archived'] == true ||
            data['status']?.toString() == HelpService.statusClosed,
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
      return [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _openFullRoute(data),
            icon: const Icon(Iconsax.direct_up, color: Colors.white),
            label: Text(
              'Buka Rute',
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
            ),
          ),
        ),
      ];
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
              'Mulai Menuju',
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
            icon: const Icon(Iconsax.direct_up, size: 18),
            label: Text(
              'Buka Rute',
              style: textStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: ColorSys.darkBlue),
              foregroundColor: ColorSys.darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _isUpdatingStatus
                ? null
                : () => _updateStatus(HelpService.statusArrived),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: ColorSys.darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text(
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

    return [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () => _openFullRoute(data),
          icon: const Icon(Iconsax.direct_up, color: Colors.white),
          label: Text(
            'Buka Rute',
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

  Widget _buildTrackingPanel(Map<String, dynamic> data) {
    final status = data['status']?.toString() ?? HelpService.statusRequested;
    final currentIsPetugas = _currentIsPetugas(data);
    final unreadCount = _unreadMessageCount(data);
    final peerName = toTitleCaseName(
      currentIsPetugas
          ? data['pilgrimName']?.toString() ?? 'Jemaah Haji'
          : _officerUserData['displayName']?.toString() ??
              data['officerName']?.toString() ??
              'Petugas Haji',
    );
    final peerRole = currentIsPetugas
        ? data['pilgrimRole']?.toString().trim() ?? 'Jemaah Haji'
        : _officerUserData['roles']?.toString().trim() ??
            data['officerRole']?.toString().trim() ??
            'Petugas Haji';
    final peerImageUrl = currentIsPetugas
        ? data['pilgrimImageUrl']?.toString() ?? ''
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
                        peerRole,
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
                        value: _formatDuration(_routeDurationSeconds),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Row(children: actions),
            ),
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
              stream: _helpService.watchConversation(_conversationId),
              builder: (context, snapshot) {
                final data = snapshot.data ?? <String, dynamic>{};
                final officerId = data['officerId']?.toString() ?? '';
                _ensureOfficerRefresh(officerId);
                _scheduleRender(data);

                return Stack(
                  children: [
                    MapWidget(
                      styleUri: MapboxStyles.MAPBOX_STREETS,
                      onMapCreated: _onMapCreated,
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
