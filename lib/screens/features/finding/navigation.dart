import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:hajj_app/helpers/app_popup.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/models/users.dart';
import 'package:hajj_app/screens/features/finding/haversine_algorithm.dart';
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

  bool _isLoading = true;
  String? _errorMessage;
  List<_OfficerRouteItem> _officerRoutes = [];

  @override
  void initState() {
    super.initState();
    _loadOfficerRoutes();
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

  String _estimateWalkDuration(double distanceKm) {
    const walkingSpeedKmPerHour = 4.8;
    final minutes = ((distanceKm / walkingSpeedKmPerHour) * 60).ceil();
    return '$minutes Min';
  }

  Widget _buildOfficerListCard(_OfficerRouteItem item) {
    final officer = item.user;
    final distanceText = '${item.distanceKm.toStringAsFixed(2)} Km';
    final durationText = _estimateWalkDuration(item.distanceKm);
    return Container(
      width: double.infinity,
      height: 200.0,
      margin: const EdgeInsets.only(bottom: 16.0),
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
      padding: const EdgeInsets.all(25.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: SizedBox(
              height: 122.0,
              width: 120.0,
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ColorSys.darkBlue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_walk,
                          size: 14.0,
                          color: ColorSys.darkBlue,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          distanceText,
                          style: textStyle(
                            fontSize: 14,
                            color: ColorSys.darkBlue,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        const Icon(
                          Iconsax.clock,
                          size: 14.0,
                          color: ColorSys.darkBlue,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          durationText,
                          style: textStyle(
                            fontSize: 14,
                            color: ColorSys.darkBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
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
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            fixedSize: const Size(90, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
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
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            fixedSize: const Size(100, 50),
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

  void _openHelpChat(UserModel user) {
    Navigator.pushNamed(
      context,
      '/help_chat',
      arguments: {
        'peerId': user.userId,
        'peerName':
            user.name.trim().isEmpty ? 'Petugas Haji' : _toTitleCase(user.name),
        'peerImageUrl': user.imageUrl,
        'peerIsPetugas': true,
        'peerRole': user.roles,
      },
    );
  }

  Future<void> _loadOfficerRoutes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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

      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      final usersMap = await fetchModelsFromFirebase();
      final petugasHaji = usersMap['petugasHaji'] ?? <UserModel>[];

      final routes = petugasHaji
          .where(
        (user) =>
            user.userId != currentUser.uid &&
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
        return _OfficerRouteItem(user: user, distanceKm: distanceKm);
      }).toList()
        ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      if (!mounted) return;
      setState(() {
        _officerRoutes = routes.take(10).toList();
        _isLoading = false;
      });
    } on UserDataAccessException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data navigasi petugas.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: ColorSys.darkBlue),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Petugas Terdekat',
          style: textStyle(
            color: ColorSys.darkBlue,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
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
  final bool _showBackButton = false;

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

  static const double _arrivalThresholdMeters = 20.0;

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

    _destinationMarker ??= await _loadMarkerBytes('assets/images/pin_3.png');

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

  Future<Uint8List> _loadMarkerBytes(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    return bytes.buffer.asUint8List();
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
    final miles = meters / 1609.344;
    return '${miles.toStringAsFixed(1)} mi';
  }

  String _formatDurationCompact(double seconds) {
    final totalMinutes = (seconds / 60).ceil();
    if (totalMinutes < 60) {
      return '$totalMinutes min';
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) {
      return '$hours h';
    }
    return '$hours h $minutes min';
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
                    'Petugas Terdekat',
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
            iconSize: 0.85,
            textField: _toTitleCase(widget.officer.name),
            textSize: 12,
            textColor: Colors.black.value,
            textHaloColor: Colors.white.value,
            textHaloWidth: 0.8,
            textOffset: [0.0, -2.0],
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memulai petunjuk arah: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onPositionUpdated(geo.Position position) async {
    await _userService.updateCurrentUserLocation(
      position.latitude,
      position.longitude,
    );

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
    return SizedBox(
      width: 58,
      height: 58,
      child: Material(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
            viewport: const FollowPuckViewportState(
              zoom: 18,
              bearing: FollowPuckViewportStateBearingHeading(),
              pitch: 70,
            ),
          ),
          if (_showBackButton)
            Positioned(
              top: 58,
              left: 18,
              child: SafeArea(
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
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
            ),
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
