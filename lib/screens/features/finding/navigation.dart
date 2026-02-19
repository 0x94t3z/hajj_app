import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:hajj_app/helpers/app_popup.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/models/users.dart';
import 'package:hajj_app/screens/features/finding/haversine_algorithm.dart';
import 'package:hajj_app/services/help_service.dart';
import 'package:hajj_app/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final UserService _userService = UserService();
  final HelpService _helpService = HelpService();

  bool _isLoading = true;
  String? _errorMessage;
  List<_OfficerRouteItem> _officerRoutes = [];
  bool _isSendingHelpRequest = false;
  StreamSubscription<geo.Position>? _nearestPositionSubscription;
  DateTime? _lastNearestRefresh;
  bool _isNearestRefreshInFlight = false;

  static const Duration _nearestRefreshInterval = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    _loadOfficerRoutes();
    _startNearestUpdates();
  }

  @override
  void dispose() {
    _nearestPositionSubscription?.cancel();
    super.dispose();
  }

  String _toTitleCase(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return normalized;
    return normalized.toLowerCase().split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  Widget _buildOfficerCardImage(String imageUrl) {
    final safeUrl = imageUrl.trim();
    if (safeUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(
          Iconsax.profile_circle,
          color: ColorSys.darkBlue,
          size: 42,
        ),
      );
    }
    return Image.network(
      safeUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Icon(
            Iconsax.profile_circle,
            color: ColorSys.darkBlue,
            size: 42,
          ),
        );
      },
    );
  }

  double _estimateWalkDurationMinutes(double distanceKm) {
    const walkingSpeedKmPerHour = 4.8;
    return (distanceKm / walkingSpeedKmPerHour) * 60;
  }

  String _estimateWalkDuration(double distanceKm) {
    final minutes = _estimateWalkDurationMinutes(distanceKm).ceil();
    return '$minutes Min';
  }

  Widget _buildOfficerListCard(_OfficerRouteItem item) {
    final officer = item.user;
    return Container(
      width: double.infinity,
      height: 172.0,
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 3,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: SizedBox(
              height: 100.0,
              width: 98.0,
              child: _buildOfficerCardImage(officer.imageUrl),
            ),
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _toTitleCase(officer.name).length > 20
                          ? '${_toTitleCase(officer.name).substring(0, 20)}...'
                          : _toTitleCase(officer.name),
                      style: textStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ColorSys.darkBlue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_walk,
                          size: 13.0,
                          color: ColorSys.darkBlue,
                        ),
                        const SizedBox(width: 4.0),
                        Flexible(
                          child: Text(
                            officer.distance,
                            style: textStyle(
                              fontSize: 12.5,
                              color: ColorSys.darkBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        const Icon(
                          Iconsax.clock,
                          size: 13.0,
                          color: ColorSys.darkBlue,
                        ),
                        const SizedBox(width: 4.0),
                        Flexible(
                          child: Text(
                            officer.duration,
                            style: textStyle(
                              fontSize: 12.5,
                              color: ColorSys.darkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14.0),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DirectionMapScreen(
                                  officer: officer,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Iconsax.direct_up,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Go',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorSys.darkBlue,
                            textStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            fixedSize: const Size(84, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        ElevatedButton.icon(
                          onPressed: () => _openHelpChat(officer),
                          icon: const Icon(
                            Iconsax.danger,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Help',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            textStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            fixedSize: const Size(92, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmHelpRequest(UserModel user) async {
    final officerName =
        user.name.trim().isEmpty ? 'petugas haji' : _toTitleCase(user.name);
    return showAppConfirmPopup(
      context,
      type: AppPopupType.info,
      title: 'Need Help?',
      message: 'Kamu akan meminta bantuan kepada $officerName. '
          'Lokasi kamu akan dibagikan.',
      confirmText: 'Continue',
      cancelText: 'Cancel',
    );
  }

  Future<void> _openHelpChat(UserModel user) async {
    if (_isSendingHelpRequest) return;

    final peerName =
        user.name.trim().isEmpty ? 'Petugas Haji' : _toTitleCase(user.name);
    final peerRole =
        user.roles.trim().isEmpty ? 'Petugas Haji' : user.roles.trim();

    final shouldContinue = await _confirmHelpRequest(user);
    if (!shouldContinue || !mounted) return;

    setState(() {
      _isSendingHelpRequest = true;
    });

    try {
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      await _userService.updateCurrentUserLocation(
        position.latitude,
        position.longitude,
      );

      final handle = await _helpService.ensureConversationWithPeer(
        peerId: user.userId,
        peerName: peerName,
        peerImageUrl: user.imageUrl,
        peerIsPetugas: true,
        peerRole: peerRole,
      );

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/help_chat',
        arguments: {
          'peerId': user.userId,
          'peerName': peerName,
          'peerImageUrl': user.imageUrl,
          'peerIsPetugas': true,
          'peerRole': peerRole,
          'conversationId': handle.conversationId,
        },
      );
    } catch (e) {
      if (!mounted) return;
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Gagal Mengirim Bantuan',
        message: 'Permintaan bantuan tidak dapat dikirim: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingHelpRequest = false;
        });
      }
    }
  }

  Future<void> _loadOfficerRoutes({
    geo.Position? position,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      } else {
        _errorMessage = null;
      }
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'Silakan login untuk melihat navigasi petugas.';
          _isLoading = false;
        });
        return;
      }

      final currentRole = await _userService.fetchCurrentUserRole();
      if (_userService.isPetugasHajiRole(currentRole)) {
        setState(() {
          _errorMessage =
              'Fitur ini difokuskan untuk Jemaah Haji mencari Petugas Haji.';
          _isLoading = false;
        });
        return;
      }

      final currentPosition = position ??
          await geo.Geolocator.getCurrentPosition(
            desiredAccuracy: geo.LocationAccuracy.high,
          );

      final usersMap = await fetchModelsFromFirebase();
      final petugasHaji = usersMap['petugasHaji'] ?? <UserModel>[];

      // Thesis requirement: list order is based on Haversine distance.
      final routes = petugasHaji
          .where(
        (user) =>
            user.userId != currentUser.uid &&
            user.latitude != 0.0 &&
            user.longitude != 0.0,
      )
          .map((user) {
        final distanceKm = calculateHaversineDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          user.latitude,
          user.longitude,
        );
        user.distance = '${distanceKm.toStringAsFixed(2)} Km';
        user.duration = _estimateWalkDuration(distanceKm);
        return _OfficerRouteItem(user: user, distanceKm: distanceKm);
      }).toList()
        ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      if (!mounted) return;
      setState(() {
        _officerRoutes = routes.take(10).toList();
        if (showLoading) {
          _isLoading = false;
        }
      });
    } on UserDataAccessException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        if (showLoading) {
          _isLoading = false;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data navigasi petugas.';
        if (showLoading) {
          _isLoading = false;
        }
      });
    }
  }

  void _startNearestUpdates() {
    _nearestPositionSubscription?.cancel();
    const locationSettings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.high,
      distanceFilter: 10,
    );

    _nearestPositionSubscription = geo.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (position) {
        unawaited(_refreshNearestOfficers(position));
      },
      onError: (error) {
        debugPrint('Nearest location stream error: $error');
      },
    );
  }

  Future<void> _refreshNearestOfficers(geo.Position position) async {
    if (_isNearestRefreshInFlight) return;
    final now = DateTime.now();
    if (_lastNearestRefresh != null &&
        now.difference(_lastNearestRefresh!) < _nearestRefreshInterval) {
      return;
    }

    _isNearestRefreshInFlight = true;
    _lastNearestRefresh = now;
    try {
      await _loadOfficerRoutes(position: position, showLoading: false);
    } finally {
      _isNearestRefreshInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: ColorSys.primary),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Nearest Hajj Officers',
          style: textStyle(color: ColorSys.primary),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOfficerRoutes,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        _errorMessage!,
                        style: textStyle(
                          color: ColorSys.darkBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : _officerRoutes.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Text(
                            'Belum ada petugas dengan koordinat lokasi.',
                            style: textStyle(
                              color: ColorSys.darkBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _officerRoutes.length,
                        itemBuilder: (context, index) {
                          final item = _officerRoutes[index];
                          return _buildOfficerListCard(item);
                        },
                      ),
      ),
    );
  }
}

class DirectionMapScreen extends StatefulWidget {
  final UserModel officer;

  const DirectionMapScreen({super.key, required this.officer});

  @override
  State<DirectionMapScreen> createState() => _DirectionMapScreenState();
}

class _DirectionMapScreenState extends State<DirectionMapScreen> {
  final UserService _userService = UserService();
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
  StreamSubscription<geo.Position>? _positionStream;

  Uint8List? _destinationMarker;
  Uint8List? _navigationPuckImage;
  Uint8List? _transparentPuckImage;

  bool _isLoading = true;
  String? _error;

  List<_TurnStep> _steps = [];
  int _stepIndex = 0;
  String _currentInstruction = 'Menyiapkan petunjuk...';
  String _currentModifier = 'straight';
  String _nextInstruction = '';
  String _nextModifier = 'straight';
  double _remainingMeters = 0.0;
  double _remainingSeconds = 0.0;
  DateTime? _lastNavigationUiUpdate;
  DateTime? _lastLocationUpload;

  Offset? _officerPopupOffset;
  bool _isResolvingOfficerPopup = false;
  bool _pendingOfficerPopupRefresh = false;

  static const double _arrivalThresholdMeters = 20.0;
  static const Duration _navigationUiUpdateInterval =
      Duration(milliseconds: 600);
  static const Duration _locationUploadInterval = Duration(seconds: 5);

  Future<void> _applyStandardNightStyle() async {
    try {
      await _mapboxMap?.style.setStyleImportConfigProperties(
        'basemap',
        {
          'lightPreset': 'night',
          'theme': 'default',
          'show3dObjects': true,
          'showRoadLabels': true,
        },
      );
    } catch (e) {
      debugPrint('Failed applying standard style config: $e');
    }
  }

  void _onStyleLoaded(StyleLoadedEventData _) {
    _applyStandardNightStyle();
  }

  void _onMapCameraChanged(CameraChangedEventData _) {
    if (_isLoading) return;
    unawaited(_refreshOfficerPopupAnchor());
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _mapboxMap = map;
    _navigationPuckImage ??= await _buildNavigationPuckImage();
    _transparentPuckImage ??= await _buildTransparentPuckImage();
    _pointAnnotationManager ??=
        await map.annotations.createPointAnnotationManager();
    _polylineAnnotationManager ??=
        await map.annotations.createPolylineAnnotationManager();

    _destinationMarker ??= await _buildOfficerCircleMarkerBytes();

    await map.compass.updateSettings(CompassSettings(enabled: false));

    await map.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: false,
        showAccuracyRing: false,
        puckBearingEnabled: true,
        puckBearing: PuckBearing.HEADING,
        locationPuck: LocationPuck(
          locationPuck2D: LocationPuck2D(
            topImage: _transparentPuckImage,
            bearingImage: _navigationPuckImage,
            shadowImage: _transparentPuckImage,
          ),
        ),
      ),
    );

    await _startDirectionSession();
  }

  Future<Uint8List> _buildOfficerCircleMarkerBytes() async {
    const size = 180.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const center = Offset(size / 2, size / 2);

    final outerHaloPaint = Paint()
      ..color = ColorSys.darkBlue.withValues(alpha: 0.24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.43, outerHaloPaint);

    final middleHaloPaint = Paint()
      ..color = ColorSys.darkBlue.withValues(alpha: 0.34)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.31, middleHaloPaint);

    final whiteRingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.22, whiteRingPaint);

    final coreDotPaint = Paint()
      ..color = ColorSys.darkBlue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.16, coreDotPaint);

    final innerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.06, innerDotPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return pngBytes!.buffer.asUint8List();
  }

  Future<Uint8List> _buildNavigationPuckImage() async {
    const size = 128.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final arrow = Path()
      ..moveTo(size * 0.5, size * 0.06)
      ..lineTo(size * 0.16, size * 0.86)
      ..quadraticBezierTo(size * 0.5, size * 0.70, size * 0.84, size * 0.86)
      ..close();

    canvas.drawShadow(
      arrow,
      Colors.black.withValues(alpha: 0.35),
      10,
      true,
    );

    final fill = Paint()
      ..color = const Color(0xFF4A76FF)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(arrow, fill);
    canvas.drawPath(arrow, stroke);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    return png!.buffer.asUint8List();
  }

  Future<Uint8List> _buildTransparentPuckImage() async {
    const size = 8.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, size, size),
      clearPaint,
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    return png!.buffer.asUint8List();
  }

  String _toTitleCase(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return normalized;
    return normalized.toLowerCase().split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  Widget _buildOfficerAvatar(String imageUrl) {
    final safeUrl = imageUrl.trim();
    return CircleAvatar(
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: SizedBox.expand(
          child: safeUrl.isEmpty
              ? const Icon(Iconsax.profile_circle)
              : Image.network(
                  safeUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Iconsax.profile_circle);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildOfficerCardImage(String imageUrl) {
    final safeUrl = imageUrl.trim();
    if (safeUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(
          Iconsax.profile_circle,
          color: ColorSys.darkBlue,
          size: 30,
        ),
      );
    }
    return Image.network(
      safeUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Icon(
            Iconsax.profile_circle,
            color: ColorSys.darkBlue,
            size: 30,
          ),
        );
      },
    );
  }

  String _toIndonesianInstruction(String instruction) {
    var text = instruction;
    final replacements = <String, String>{
      'Head ': 'Berjalan ke ',
      'Continue ': 'Lanjut berjalan ',
      'Turn left': 'Belok kiri',
      'Turn right': 'Belok kanan',
      'Slight left': 'Sedikit ke kiri',
      'Slight right': 'Sedikit ke kanan',
      'Sharp left': 'Belok tajam ke kiri',
      'Sharp right': 'Belok tajam ke kanan',
      'Keep left': 'Tetap di kiri',
      'Keep right': 'Tetap di kanan',
      'Make a U-turn': 'Putar balik',
      'Destination will be on the left': 'Tujuan berada di sebelah kiri',
      'Destination will be on the right': 'Tujuan berada di sebelah kanan',
      'You have arrived': 'Anda telah tiba',
      'at the roundabout': 'di bundaran',
      'toward': 'menuju',
      'onto': 'ke',
    };
    replacements.forEach((source, target) {
      text = text.replaceAll(source, target);
    });
    return text;
  }

  IconData _directionIcon(String modifier, {String? instruction}) {
    final instructionText = (instruction ?? '').toLowerCase();
    if (instructionText.contains('berjalan') ||
        instructionText.contains('mulai')) {
      return Icons.directions_walk;
    }
    final value = modifier.toLowerCase();
    if (value.contains('left')) return Icons.turn_left;
    if (value.contains('right')) return Icons.turn_right;
    if (value.contains('uturn')) return Icons.keyboard_return;
    if (value.contains('straight')) return Icons.straight;
    return Icons.navigation;
  }

  String _formatDistanceMiles(double meters) {
    final km = meters / 1000;
    return '${km.toStringAsFixed(2)} Km';
  }

  String _formatDurationCompact(double seconds) {
    final totalMinutes = (seconds / 60).ceil();
    if (totalMinutes < 60) {
      return '$totalMinutes Min';
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) {
      return '$hours h';
    }
    return '$hours h $minutes Min';
  }

  void _updateNextInstruction() {
    if (_steps.isEmpty) {
      _nextInstruction = '';
      _nextModifier = 'straight';
      return;
    }
    if (_stepIndex + 1 < _steps.length) {
      _nextInstruction = _steps[_stepIndex + 1].instruction;
      _nextModifier = _steps[_stepIndex + 1].modifier;
      return;
    }
    _nextInstruction = 'Lanjutkan hingga tujuan';
    _nextModifier = 'straight';
  }

  Future<List<_NearbyOfficer>> _fetchNearestOfficers({int limit = 10}) async {
    final position = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final usersMap = await fetchModelsFromFirebase();
    final petugas = usersMap['petugasHaji'] ?? <UserModel>[];

    final nearest = petugas
        .where(
      (user) =>
          user.userId != currentUid &&
          user.latitude != 0.0 &&
          user.longitude != 0.0,
    )
        .map((user) {
      final distanceKm = calculateHaversineDistance(
        position.latitude,
        position.longitude,
        user.latitude,
        user.longitude,
      );
      return _NearbyOfficer(user: user, distanceKm: distanceKm);
    }).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return nearest.take(limit).toList();
  }

  Future<void> _showNearestOfficersSheet() async {
    try {
      final nearest = await _fetchNearestOfficers(limit: 10);
      if (!mounted) return;

      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nearest Hajj Officers',
                    style: textStyle(
                      color: ColorSys.darkBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (nearest.isEmpty)
                    Text(
                      'Belum ada petugas dengan lokasi valid.',
                      style: textStyle(
                        color: ColorSys.darkBlue,
                        fontSize: 13,
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: nearest.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = nearest[index];
                          final officer = item.user;
                          return ListTile(
                            onTap: () {
                              Navigator.pop(context);
                              if (officer.userId == widget.officer.userId) {
                                return;
                              }
                              Navigator.pushReplacement(
                                this.context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DirectionMapScreen(officer: officer),
                                ),
                              );
                            },
                            leading: _buildOfficerAvatar(officer.imageUrl),
                            title: Text(
                              officer.name.isEmpty
                                  ? 'Tanpa Nama'
                                  : _toTitleCase(officer.name),
                              style: textStyle(
                                color: ColorSys.darkBlue,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              '${officer.roles} • ${item.distanceKm.toStringAsFixed(2)} Km',
                              style: textStyle(
                                color: ColorSys.darkBlue,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Gagal Memuat Data',
        message: 'Gagal memuat daftar petugas terdekat.',
      );
    }
  }

  double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    return calculateHaversineDistance(lat1, lon1, lat2, lon2) * 1000;
  }

  Future<_RouteData?> _fetchRoute(geo.Position origin) async {
    final token = dotenv.env['MAPBOX_SECRET_KEY']?.trim() ?? '';
    if (token.isEmpty) {
      throw Exception('MAPBOX_SECRET_KEY tidak ditemukan.');
    }

    final response = await http.get(
      Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/walking/${origin.longitude},${origin.latitude};${widget.officer.longitude},${widget.officer.latitude}?alternatives=false&continue_straight=true&geometries=geojson&overview=full&steps=true&language=id&voice_units=metric&access_token=$token',
      ),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List<dynamic>? ?? [];
    if (routes.isEmpty) return null;

    final route = routes.first as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>? ?? {};
    final rawCoordinates = geometry['coordinates'] as List<dynamic>? ?? [];

    final coordinates = rawCoordinates
        .whereType<List<dynamic>>()
        .where((v) => v.length >= 2)
        .map(
          (v) => Position(
            (v[0] as num).toDouble(),
            (v[1] as num).toDouble(),
          ),
        )
        .toList();

    final steps = <_TurnStep>[];
    final legs = route['legs'] as List<dynamic>? ?? [];
    for (final legRaw in legs) {
      if (legRaw is! Map<String, dynamic>) continue;
      final legSteps = legRaw['steps'] as List<dynamic>? ?? [];
      for (final stepRaw in legSteps) {
        if (stepRaw is! Map<String, dynamic>) continue;
        final maneuver = stepRaw['maneuver'] as Map<String, dynamic>? ?? {};
        final instruction = _toIndonesianInstruction(
          maneuver['instruction']?.toString() ?? '',
        );
        final modifier = maneuver['modifier']?.toString() ?? 'straight';
        final location = maneuver['location'] as List<dynamic>? ?? [];
        if (instruction.trim().isEmpty || location.length < 2) continue;

        steps.add(
          _TurnStep(
            instruction: instruction,
            modifier: modifier,
            latitude: (location[1] as num).toDouble(),
            longitude: (location[0] as num).toDouble(),
          ),
        );
      }
    }

    return _RouteData(
      coordinates: coordinates,
      steps: steps,
      distanceMeters: (route['distance'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: (route['duration'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<void> _startDirectionSession() async {
    try {
      final currentPosition = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.bestForNavigation,
      );

      await _userService.updateCurrentUserLocation(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      final route = await _fetchRoute(currentPosition);
      if (route == null) {
        if (!mounted) return;
        setState(() {
          _error = 'Rute tidak ditemukan.';
          _isLoading = false;
        });
        return;
      }

      _steps = route.steps;
      _stepIndex = 0;
      _currentInstruction =
          _steps.isNotEmpty ? _steps.first.instruction : 'Lanjutkan ke tujuan';
      _currentModifier = _steps.isNotEmpty ? _steps.first.modifier : 'straight';
      _remainingMeters = route.distanceMeters;
      _remainingSeconds = route.durationSeconds;
      _updateNextInstruction();

      await _polylineAnnotationManager?.deleteAll();
      await _pointAnnotationManager?.deleteAll();

      if (route.coordinates.isNotEmpty) {
        await _polylineAnnotationManager?.create(
          PolylineAnnotationOptions(
            geometry: LineString(coordinates: route.coordinates),
            lineColor: 0xFF74C1FF,
            lineWidth: 9.0,
            lineBorderColor: 0xFF2D6CFF,
            lineBorderWidth: 3.0,
            lineBlur: 0.2,
            lineEmissiveStrength: 0.5,
            lineJoin: LineJoin.ROUND,
          ),
        );
      }

      if (_destinationMarker != null) {
        await _pointAnnotationManager?.create(
          PointAnnotationOptions(
            geometry: Point(
              coordinates: Position(
                widget.officer.longitude,
                widget.officer.latitude,
              ),
            ),
            image: _destinationMarker,
            iconSize: 0.9,
            textField: null,
          ),
        );
      }

      _mapboxMap?.setCamera(
        CameraOptions(
          center: Point(
            coordinates:
                Position(currentPosition.longitude, currentPosition.latitude),
          ),
          zoom: 18,
          pitch: 70,
          bearing: currentPosition.heading > 0 ? currentPosition.heading : 0,
        ),
      );

      await _positionStream?.cancel();
      const locationSettings = geo.LocationSettings(
        accuracy: geo.LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
      );

      _positionStream = geo.Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _onPositionUpdated,
        onError: (error) {
          debugPrint('Direction stream error: $error');
        },
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      unawaited(_refreshOfficerPopupAnchor());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memulai petunjuk arah: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onPositionUpdated(geo.Position position) async {
    final now = DateTime.now();
    if (_lastLocationUpload == null ||
        now.difference(_lastLocationUpload!) >= _locationUploadInterval) {
      _lastLocationUpload = now;
      await _userService.updateCurrentUserLocation(
        position.latitude,
        position.longitude,
      );
    }

    if (_lastNavigationUiUpdate != null &&
        now.difference(_lastNavigationUiUpdate!) <
            _navigationUiUpdateInterval) {
      return;
    }
    _lastNavigationUiUpdate = now;

    final remaining = _distanceMeters(
      position.latitude,
      position.longitude,
      widget.officer.latitude,
      widget.officer.longitude,
    );

    if (remaining <= _arrivalThresholdMeters) {
      await _positionStream?.cancel();
      if (!mounted) return;
      setState(() {
        _currentInstruction = 'Anda sudah sampai di tujuan';
        _remainingMeters = 0;
        _remainingSeconds = 0;
        _nextInstruction = '';
        _nextModifier = 'straight';
      });
      return;
    }

    if (_steps.isNotEmpty && _stepIndex < _steps.length) {
      final activeStep = _steps[_stepIndex];
      final stepDistance = _distanceMeters(
        position.latitude,
        position.longitude,
        activeStep.latitude,
        activeStep.longitude,
      );

      if (stepDistance <= 15 && _stepIndex < _steps.length - 1) {
        _stepIndex++;
      }
    }

    if (!mounted) return;
    setState(() {
      _remainingMeters = remaining;
      const walkingMetersPerSecond = 1.39;
      _remainingSeconds = remaining / walkingMetersPerSecond;
      if (_steps.isNotEmpty) {
        _currentInstruction = _steps[_stepIndex].instruction;
        _currentModifier = _steps[_stepIndex].modifier;
      }
      _updateNextInstruction();
    });

    _mapboxMap?.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
        zoom: 18,
        pitch: 70,
        bearing: position.heading > 0 ? position.heading : 0,
      ),
    );
  }

  Future<void> _backToMaps() async {
    await _positionStream?.cancel();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Widget _buildTopBanner() {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF3E6EF0),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Menyiapkan rute...',
                style: textStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF7F1D1D),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          _error!,
          style: textStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final primary = _currentInstruction.isEmpty
        ? 'Ikuti rute yang ditampilkan'
        : _currentInstruction;
    final secondary =
        _nextInstruction.isEmpty ? 'Lanjutkan sampai tujuan' : _nextInstruction;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF3E6EF0),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _directionIcon(
                          _currentModifier,
                          instruction: primary,
                        ),
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_formatDurationCompact(_remainingSeconds)} • ${_formatDistanceMiles(_remainingMeters)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    primary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: const Color(0xFF2A4FB5),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Row(
                children: [
                  Icon(
                    _directionIcon(_nextModifier, instruction: secondary),
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      secondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildDockButton({
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Material(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(14.5),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.5),
          onTap: onTap,
          child: Icon(icon, color: iconColor, size: 30),
        ),
      ),
    );
  }

  Widget _buildOutlinedOfficerName(String textValue) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          textValue,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.6
              ..color = Colors.black,
          ),
        ),
        Text(
          textValue,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Future<void> _refreshOfficerPopupAnchor() async {
    final currentMap = _mapboxMap;
    if (currentMap == null || _isLoading || _error != null) return;

    if (_isResolvingOfficerPopup) {
      _pendingOfficerPopupRefresh = true;
      return;
    }

    _isResolvingOfficerPopup = true;
    try {
      final pixel = await currentMap.pixelForCoordinate(
        Point(
          coordinates: Position(
            widget.officer.longitude,
            widget.officer.latitude,
          ),
        ),
      );

      if (!mounted) return;
      setState(() {
        _officerPopupOffset = Offset(pixel.x, pixel.y);
      });
    } catch (_) {
      // Keep map stable if anchor projection fails.
    } finally {
      _isResolvingOfficerPopup = false;
      if (_pendingOfficerPopupRefresh) {
        _pendingOfficerPopupRefresh = false;
        unawaited(_refreshOfficerPopupAnchor());
      }
    }
  }

  Widget _buildOfficerPopup() {
    if (_officerPopupOffset == null || _isLoading || _error != null) {
      return const SizedBox.shrink();
    }

    final anchor = _officerPopupOffset!;
    final screenSize = MediaQuery.of(context).size;
    if (anchor.dx < 0 ||
        anchor.dy < 0 ||
        anchor.dx > screenSize.width ||
        anchor.dy > screenSize.height) {
      return const SizedBox.shrink();
    }

    if (anchor.dy < 160.0) {
      return const SizedBox.shrink();
    }
    final displayName = _toTitleCase(widget.officer.name);
    final nameStyle = textStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w700,
      color: ColorSys.darkBlue,
    );

    const cardHeight = 90.0;
    const horizontalPadding = 24.0;
    const avatarAndGapWidth = 64.0;
    const minBubbleWidth = 168.0;
    final maxBubbleWidth = math.min(320.0, screenSize.width - 24.0);

    final textPainter = TextPainter(
      text: TextSpan(text: displayName, style: nameStyle),
      maxLines: 2,
      textDirection: Directionality.of(context),
    )..layout(maxWidth: maxBubbleWidth - horizontalPadding - avatarAndGapWidth);

    final distanceDurationStyle = textStyle(
      fontSize: 11,
      color: ColorSys.darkBlue,
    );
    final distanceText = widget.officer.distance;
    final durationText = widget.officer.duration;
    final distDurPainter = TextPainter(
      text: TextSpan(
        text: '$distanceText  $durationText',
        style: distanceDurationStyle,
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();
    final distDurRowWidth = distDurPainter.width + 40.0;

    final contentWidth = math.max(textPainter.width, distDurRowWidth);
    final cardWidth =
        (horizontalPadding + avatarAndGapWidth + contentWidth + 18.0)
            .clamp(minBubbleWidth, maxBubbleWidth)
            .toDouble();

    final left = (anchor.dx - (cardWidth / 2))
        .clamp(12.0, math.max(12.0, screenSize.width - cardWidth - 12.0))
        .toDouble();
    final top = (anchor.dy - cardHeight - 22.0)
        .clamp(94.0, math.max(94.0, screenSize.height - cardHeight - 250.0))
        .toDouble();
    final pointerLeft =
        (anchor.dx - left - 6.0).clamp(20.0, cardWidth - 20.0).toDouble();

    return Positioned(
      left: left,
      top: top,
      width: cardWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: cardHeight,
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999.0),
              border: Border.all(
                color: ColorSys.darkBlue.withValues(alpha: 0.08),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16.0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.0),
                  child: SizedBox(
                    width: 54.0,
                    height: 54.0,
                    child: _buildOfficerCardImage(widget.officer.imageUrl),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: nameStyle,
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.directions_walk,
                              size: 12.0,
                              color: ColorSys.darkBlue,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              distanceText,
                              style: distanceDurationStyle,
                            ),
                            const SizedBox(width: 8.0),
                            const Icon(
                              Iconsax.clock,
                              size: 12.0,
                              color: ColorSys.darkBlue,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              durationText,
                              style: distanceDurationStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: pointerLeft - 8.0,
            bottom: -34.0,
            child: SizedBox(
              width: 16.0,
              height: 34.0,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 2.0,
                    child: ClipPath(
                      clipper: _LongTriangleTailClipper(),
                      child: Container(
                        width: 16.0,
                        height: 32.0,
                        color: Colors.black.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: _LongTriangleTailClipper(),
                    child: Container(
                      width: 14.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: ColorSys.darkBlue.withValues(alpha: 0.08),
                          width: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDock() {
    final canSearchNearestOfficer =
        _userService.isPetugasHajiRole(widget.officer.roles);
    final officerName = widget.officer.name.isEmpty
        ? (canSearchNearestOfficer ? 'Petugas Haji' : 'Jemaah Haji')
        : _toTitleCase(widget.officer.name);
    final roleText = widget.officer.roles.trim().isEmpty
        ? (canSearchNearestOfficer ? 'Petugas Haji' : 'Jemaah Haji')
        : widget.officer.roles.trim();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xCC0E131E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _buildDockButton(
            icon: Icons.search,
            iconColor: canSearchNearestOfficer
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
            onTap: canSearchNearestOfficer ? _showNearestOfficersSheet : null,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOutlinedOfficerName(
                  officerName,
                ),
                const SizedBox(height: 2),
                Text(
                  roleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildDockButton(
            icon: Icons.close_rounded,
            iconColor: const Color(0xFFFF4A57),
            onTap: _backToMaps,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            styleUri: MapboxStyles.STANDARD,
            onMapCreated: _onMapCreated,
            onStyleLoadedListener: _onStyleLoaded,
            onCameraChangeListener: _onMapCameraChanged,
          ),
          _buildOfficerPopup(),
          Positioned(
            left: 0,
            right: 0,
            top: 104,
            child: _buildTopBanner(),
          ),
          if (!_isLoading && _error == null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: _buildBottomDock(),
            ),
        ],
      ),
    );
  }
}

class _OfficerRouteItem {
  final UserModel user;
  final double distanceKm;

  _OfficerRouteItem({
    required this.user,
    required this.distanceKm,
  });
}

class _NearbyOfficer {
  final UserModel user;
  final double distanceKm;

  _NearbyOfficer({
    required this.user,
    required this.distanceKm,
  });
}

class _RouteData {
  final List<Position> coordinates;
  final List<_TurnStep> steps;
  final double distanceMeters;
  final double durationSeconds;

  _RouteData({
    required this.coordinates,
    required this.steps,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

class _TurnStep {
  final String instruction;
  final String modifier;
  final double latitude;
  final double longitude;

  _TurnStep({
    required this.instruction,
    required this.modifier,
    required this.latitude,
    required this.longitude,
  });
}

class _LongTriangleTailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.5, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
