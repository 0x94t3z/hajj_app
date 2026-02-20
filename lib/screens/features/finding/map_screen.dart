import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajj_app/core/widgets/app_popup.dart';
import 'package:hajj_app/models/user_model.dart';
import 'package:hajj_app/services/help_service.dart';
import 'package:hajj_app/services/user_service.dart';
import 'package:hajj_app/core/theme/app_style.dart';
import 'package:hajj_app/screens/features/finding/haversine_algorithm.dart';
import 'package:hajj_app/screens/features/finding/navigation_screen.dart';
import 'package:hajj_app/screens/features/finding/operation_bounds.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final UserService _userService = UserService();
  final HelpService _helpService = HelpService();
  MapboxMap? mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
  Uint8List? _destinationMarker;
  final PageController _pageController = PageController();
  bool _hideBackButton = false;
  List<UserModel> users = [];
  bool _isCurrentUserPetugas = false;
  StreamSubscription<geo.Position>? _navigationPositionSubscription;
  StreamSubscription<geo.Position>? _nearestPositionSubscription;
  DateTime? _lastNearestRefresh;
  bool _isNearestRefreshInFlight = false;

  bool _isNavigationLoading = false;
  bool _isNavigationRunning = false;
  bool _isRerouting = false;
  bool _isSendingHelpRequest = false;
  UserModel? _selectedOfficerPreview;
  Offset? _selectedOfficerPreviewOffset;
  bool _isResolvingPreviewAnchor = false;
  bool _pendingPreviewAnchorRefresh = false;
  String _navigationInstruction = '';
  String _navigationModifier = 'straight';
  String _nextNavigationInstruction = '';
  String _nextNavigationModifier = 'straight';
  double _navigationRemainingMeters = 0.0;
  double _navigationRemainingSeconds = 0.0;
  DateTime? _navigationEta;
  static const int _maxNearestOfficers = 10;
  static const Duration _nearestRefreshInterval = Duration(seconds: 20);
  static const double _defaultMapPitch = 50.0;

  Future<void> _applyStandardMapStyle() async {
    try {
      await mapboxMap?.style.setStyleImportConfigProperties(
        'basemap',
        {
          'lightPreset': 'day',
          'theme': 'default',
          'show3dObjects': true,
          'showRoadLabels': true,
        },
      );
    } catch (_) {
      // Keep map usable even if style import config is unavailable.
    }
  }

  void _onMapStyleLoaded(StyleLoadedEventData _) {
    unawaited(_applyStandardMapStyle());
  }

  void _onMapCameraChanged(CameraChangedEventData _) {
    if (_selectedOfficerPreview == null) return;
    unawaited(_refreshSelectedOfficerPreviewAnchor());
  }

  @override
  void initState() {
    super.initState();

    // Get the current user's role
    _getCurrentUserRole();
    // Start a timer to update user distances periodically
    _getCurrentPosition();
    _startNearestUpdates();
    // Call a method to fetch or initialize users when the screen loads
    fetchData();
  }

  void _showDataAccessError(Object error) {
    if (!mounted) return;
    final text = error is UserDataAccessException
        ? error.message
        : 'Unable to load users from Firebase.';
    unawaited(
      showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Gagal Memuat Data',
        message: text,
      ),
    );
  }

  Future<void> _showPopupMessage(
    String message, {
    AppPopupType type = AppPopupType.info,
    String? title,
  }) async {
    if (!mounted) return;
    await showAppPopup(
      context,
      type: type,
      title: title,
      message: message,
    );
  }

  @override
  void dispose() {
    _navigationPositionSubscription?.cancel();
    _nearestPositionSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    mapboxMap = map;
    unawaited(_applyStandardMapStyle());
    mapboxMap?.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(39.826115, 21.422627),
        ),
        zoom: 14.0,
        pitch: _defaultMapPitch,
      ),
    );
    await mapboxMap?.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: false,
        showAccuracyRing: false,
        puckBearingEnabled: true,
        puckBearing: PuckBearing.HEADING,
        locationPuck: LocationPuck(locationPuck2D: DefaultLocationPuck2D()),
      ),
    );
    _pointAnnotationManager ??=
        await mapboxMap?.annotations.createPointAnnotationManager();
    _polylineAnnotationManager ??=
        await mapboxMap?.annotations.createPolylineAnnotationManager();
    _destinationMarker ??= await _buildOfficerCircleMarkerBytes();

    // Auto zoom to current user location when map is ready (same behavior as second.dart).
    await _getUserLocation();
  }

  Future<Uint8List> _buildOfficerCircleMarkerBytes() async {
    const size = 180.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = const Offset(size / 2, size / 2);

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

  Future<void> _clearMapOverlays() async {
    await _polylineAnnotationManager?.deleteAll();
    await _pointAnnotationManager?.deleteAll();
  }

  Future<void> _addPointMarker({
    required double latitude,
    required double longitude,
    String? label,
    required Uint8List? imageBytes,
    List<double>? textOffset,
  }) async {
    if (imageBytes == null || _pointAnnotationManager == null) {
      return;
    }
    final trimmedLabel = label?.trim() ?? '';
    await _pointAnnotationManager!.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(longitude, latitude),
        ),
        image: imageBytes,
        iconSize: 0.9,
        textField: trimmedLabel.isEmpty ? null : trimmedLabel,
        textSize: trimmedLabel.isEmpty ? null : 12.5,
        textColor: trimmedLabel.isEmpty ? null : Colors.black.toARGB32(),
        textHaloColor: trimmedLabel.isEmpty ? null : Colors.white.toARGB32(),
        textHaloWidth: trimmedLabel.isEmpty ? null : 0.8,
        textOffset: trimmedLabel.isEmpty ? null : (textOffset ?? [0.0, 0.8]),
      ),
    );
  }

  // Helper method to check if the location is valid
  bool isValidLocation(UserModel user) {
    return (user.latitude != 0.0) && (user.longitude != 0.0);
  }

  bool _isPetugasHajiRole(String role) {
    return _userService.isPetugasHajiRole(role);
  }

  String _estimateWalkDuration(double distanceKm) {
    const walkingSpeedKmPerHour = 4.8;
    final minutes = ((distanceKm / walkingSpeedKmPerHour) * 60).ceil();
    return '$minutes Min';
  }

  Future<List<UserModel>> _buildNearestPetugasList({
    required geo.Position currentPosition,
    required List<UserModel> petugasHaji,
  }) async {
    if (!isInsideMakkahOperationArea(
      currentPosition.latitude,
      currentPosition.longitude,
    )) {
      return <UserModel>[];
    }

    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    // Thesis requirement: nearest officers are ranked by Haversine distance.
    final rankedUsers = petugasHaji
        .where(
          (user) =>
              user.latitude != 0.0 &&
              user.longitude != 0.0 &&
              user.userId != currentUid &&
              isInsideMakkahOperationArea(user.latitude, user.longitude),
        )
        .map(
          (user) {
            final distanceKm = calculateHaversineDistance(
              currentPosition.latitude,
              currentPosition.longitude,
              user.latitude,
              user.longitude,
            );
            return MapEntry(user, distanceKm);
          },
        )
        .where((entry) => entry.value <= maxNearbyOfficerDistanceKm)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final nearestRanked = rankedUsers.take(_maxNearestOfficers).toList();
    final nearestUsers = <UserModel>[];

    for (final rankedUser in nearestRanked) {
      final user = rankedUser.key;
      final distanceKm = rankedUser.value;
      user.distance = '${distanceKm.toStringAsFixed(2)} Km';
      user.duration = _estimateWalkDuration(distanceKm);
      nearestUsers.add(user);
    }

    return nearestUsers;
  }

  // Fetch current user's role
  Future<String> _getCurrentUserRole() async {
    if (FirebaseAuth.instance.currentUser == null) {
      return 'Jemaah Haji';
    }
    return _userService.fetchCurrentUserRole();
  }

  // Fetch and filter users based on role
  Future<void> fetchData() async {
    try {
      String currentUserRole = await _getCurrentUserRole();

      Map<String, List<UserModel>> usersMap =
          await fetchModelsFromFirebase(); // Fetch users
      List<UserModel> petugasHaji = usersMap['petugasHaji'] ?? [];
      if (_isPetugasHajiRole(currentUserRole)) {
        setState(() {
          _isCurrentUserPetugas = true;
          users = [];
        });
        return;
      }
      _isCurrentUserPetugas = false;

      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      final nearestUsers = await _buildNearestPetugasList(
        currentPosition: position,
        petugasHaji: petugasHaji,
      );

      setState(() {
        users = nearestUsers;
      });
    } on UserDataAccessException catch (e) {
      _showDataAccessError(e);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        _showDataAccessError(
          UserDataAccessException(
            'Permission denied by Firebase rules when reading users.',
          ),
        );
        return;
      }
      debugPrint('Error fetching data: $e');
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  Future<void> _updateUserLocation(double latitude, double longitude) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _userService.updateCurrentUserLocation(latitude, longitude);
      }
    } catch (e) {
      debugPrint('Error updating user location: $e');
    }
  }

  Future<void> _updateUserDistancesForPosition(
    geo.Position position,
  ) async {
    try {
      // Get the current user's role
      String currentUserRole = await _getCurrentUserRole();

      // Fetch users from Firebase
      Map<String, List<UserModel>> usersMap = await fetchModelsFromFirebase();
      List<UserModel> petugasHaji = usersMap['petugasHaji'] ?? [];

      if (_isPetugasHajiRole(currentUserRole)) {
        setState(() {
          _isCurrentUserPetugas = true;
          users = [];
        });
        return;
      }
      _isCurrentUserPetugas = false;

      final finalFilteredUsers = await _buildNearestPetugasList(
        currentPosition: position,
        petugasHaji: petugasHaji,
      );

      // Update the state with the filtered, sorted, and updated users
      setState(() {
        users = finalFilteredUsers;
      });
    } on UserDataAccessException catch (e) {
      _showDataAccessError(e);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        _showDataAccessError(
          UserDataAccessException(
            'Permission denied by Firebase rules when reading users.',
          ),
        );
        return;
      }
      debugPrint('Error updating user distances: $e');
    } catch (e) {
      debugPrint('Error updating user distances: $e');
    }
  }

  Future<void> _refreshNearestOfficers(
    geo.Position position, {
    bool force = false,
  }) async {
    if (_isNearestRefreshInFlight) return;
    final now = DateTime.now();
    if (!force &&
        _lastNearestRefresh != null &&
        now.difference(_lastNearestRefresh!) < _nearestRefreshInterval) {
      return;
    }

    _isNearestRefreshInFlight = true;
    _lastNearestRefresh = now;
    try {
      await _updateUserLocation(position.latitude, position.longitude);
      await _updateUserDistancesForPosition(position);
    } finally {
      _isNearestRefreshInFlight = false;
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

  Future<void> _getCurrentPosition() async {
    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      // Update current user's location in Firebase Realtime Database
      await _updateUserLocation(position.latitude, position.longitude);

      // Refresh nearest officer list (max 10)
      await _refreshNearestOfficers(position, force: true);
    } catch (e) {
      debugPrint('Failed getting current position: $e');
    }
  }

  Future<void> _getUserLocation() async {
    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      // Update current user's location in Firebase Realtime Database
      await _updateUserLocation(position.latitude, position.longitude);

      if (_isNavigationRunning) {
        mapboxMap?.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(position.longitude, position.latitude),
            ),
            zoom: 16.0,
            pitch: _defaultMapPitch,
            bearing: 0.0,
          ),
          MapAnimationOptions(duration: 800),
        );
        return;
      }

      await _clearMapOverlays();

      mapboxMap?.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: 16.0,
          pitch: _defaultMapPitch,
        ),
        MapAnimationOptions(duration: 1200),
      );
    } catch (e) {
      // Handle any errors that may occur when getting the location.
      debugPrint('Failed getting user location: $e');
    }
  }

  String? _getMapboxToken() {
    final token = dotenv.env['MAPBOX_SECRET_KEY']?.trim();
    if (token == null || token.isEmpty) {
      return null;
    }
    return token;
  }

  String _toTitleCase(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return normalized;
    return normalized.toLowerCase().split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  String _formatDistanceSmart(String rawDistance) {
    final cleaned = rawDistance.trim();
    if (cleaned.isEmpty) return cleaned;

    final kmMatch =
        RegExp(r'([\d.,]+)\s*km', caseSensitive: false).firstMatch(cleaned);
    if (kmMatch == null) {
      return cleaned;
    }

    final kmValue = double.tryParse(kmMatch.group(1)!.replaceAll(',', '.'));
    if (kmValue == null) return cleaned;

    return '${kmValue.toStringAsFixed(2)} Km';
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

  String _formatEta(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $suffix';
  }

  double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    return calculateHaversineDistance(lat1, lon1, lat2, lon2) * 1000;
  }

  Future<_NavigationRouteData?> _fetchNavigationRoute({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    final mapboxToken = _getMapboxToken();
    if (mapboxToken == null) {
      if (!mounted) return null;
      await _showPopupMessage(
        'MAPBOX_SECRET_KEY tidak ditemukan.',
        type: AppPopupType.error,
        title: 'Konfigurasi Mapbox',
      );
      return null;
    }

    final directMeters = _distanceMeters(
      originLatitude,
      originLongitude,
      destinationLatitude,
      destinationLongitude,
    );

    final response = await http.get(
      Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/walking/$originLongitude,$originLatitude;$destinationLongitude,$destinationLatitude?alternatives=false&continue_straight=true&geometries=geojson&overview=full&steps=true&language=id&voice_units=metric&access_token=$mapboxToken',
      ),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List<dynamic>? ?? [];
    if (routes.isEmpty) {
      return null;
    }

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

    final steps = <_RouteStep>[];
    final legs = route['legs'] as List<dynamic>? ?? [];
    for (final legRaw in legs) {
      if (legRaw is! Map<String, dynamic>) continue;
      final legSteps = legRaw['steps'] as List<dynamic>? ?? [];
      for (final stepRaw in legSteps) {
        if (stepRaw is! Map<String, dynamic>) continue;
        final maneuver = stepRaw['maneuver'] as Map<String, dynamic>? ?? {};
        final location = maneuver['location'] as List<dynamic>? ?? [];
        if (location.length < 2) continue;
        final instruction = _toIndonesianInstruction(
          maneuver['instruction']?.toString() ?? '',
        );
        final modifier = maneuver['modifier']?.toString() ?? 'straight';
        if (instruction.trim().isEmpty) continue;
        steps.add(
          _RouteStep(
            instruction: instruction,
            modifier: modifier,
            latitude: (location[1] as num).toDouble(),
            longitude: (location[0] as num).toDouble(),
          ),
        );
      }
    }

    if (coordinates.isEmpty) {
      return null;
    }

    final routeDistanceMeters =
        (route['distance'] as num?)?.toDouble() ?? directMeters;

    var finalDistanceMeters = routeDistanceMeters;
    var finalDurationSeconds = (route['duration'] as num?)?.toDouble() ?? 0.0;
    if (coordinates.isNotEmpty) {
      final routeEnd = coordinates.last;
      final offroadConnectorMeters = _distanceMeters(
        routeEnd.lat.toDouble(),
        routeEnd.lng.toDouble(),
        destinationLatitude,
        destinationLongitude,
      );
      if (offroadConnectorMeters > offroadConnectorThresholdMeters) {
        coordinates.add(Position(destinationLongitude, destinationLatitude));
        steps.add(
          _RouteStep(
            instruction: 'Lanjutkan ke titik tujuan (area bangunan/ruangan).',
            modifier: 'straight',
            latitude: destinationLatitude,
            longitude: destinationLongitude,
          ),
        );
        finalDistanceMeters += offroadConnectorMeters;
        finalDurationSeconds += (offroadConnectorMeters / 1.39);
      }
    }

    return _NavigationRouteData(
      coordinates: coordinates,
      steps: steps,
      distanceMeters: finalDistanceMeters,
      durationSeconds: finalDurationSeconds,
    );
  }

  Future<void> _renderNavigationRoute({
    required geo.Position origin,
    required UserModel destinationUser,
    required _NavigationRouteData route,
  }) async {
    await _clearMapOverlays();

    if (route.coordinates.isNotEmpty) {
      try {
        await _polylineAnnotationManager?.setLineCap(LineCap.ROUND);
        await _polylineAnnotationManager?.setLineJoin(LineJoin.ROUND);
        await _polylineAnnotationManager?.setLineDasharray([0.01, 1.8]);
        await _polylineAnnotationManager
            ?.setLineElevationReference(LineElevationReference.GROUND);
        await _polylineAnnotationManager?.setLineZOffset(2.2);
        await _polylineAnnotationManager?.setLineDepthOcclusionFactor(0.0);
      } catch (_) {
        // Fallback: some devices/styles may not support elevated polyline settings.
      }

      await _polylineAnnotationManager?.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: route.coordinates),
          lineJoin: LineJoin.ROUND,
          lineColor: ColorSys.navigationRouteBorder.toARGB32(),
          lineWidth: 8.0,
          lineBorderColor: ColorSys.navigationRouteBorder.toARGB32(),
          lineBorderWidth: 0.0,
          lineZOffset: 2.2,
          lineBlur: 0.2,
          lineEmissiveStrength: 0.9,
        ),
      );
    }

    await _addPointMarker(
      latitude: destinationUser.latitude,
      longitude: destinationUser.longitude,
      label: '',
      imageBytes: _destinationMarker,
    );
    await _showRouteOverviewCamera(
      origin: origin,
      destinationUser: destinationUser,
      route: route,
    );
  }

  Future<void> _showRouteOverviewCamera({
    required geo.Position origin,
    required UserModel destinationUser,
    required _NavigationRouteData route,
  }) async {
    final currentMap = mapboxMap;
    if (currentMap == null) return;

    final points = <Point>[
      Point(coordinates: Position(origin.longitude, origin.latitude)),
      ...route.coordinates.map((coordinate) => Point(coordinates: coordinate)),
      Point(
        coordinates:
            Position(destinationUser.longitude, destinationUser.latitude),
      ),
    ];

    try {
      final camera = await currentMap.cameraForCoordinatesPadding(
        points,
        CameraOptions(
          pitch: _defaultMapPitch,
          bearing: 0.0,
        ),
        MbxEdgeInsets(
          top: 120.0,
          left: 40.0,
          bottom: 300.0,
          right: 40.0,
        ),
        17.0,
        null,
      );
      await currentMap.easeTo(
        camera,
        MapAnimationOptions(duration: 900),
      );
    } catch (_) {
      final centerLatitude = (origin.latitude + destinationUser.latitude) / 2;
      final centerLongitude =
          (origin.longitude + destinationUser.longitude) / 2;
      await currentMap.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(centerLongitude, centerLatitude)),
          zoom: 15.2,
          pitch: _defaultMapPitch,
          bearing: 0.0,
        ),
        MapAnimationOptions(duration: 900),
      );
    }

    if (_selectedOfficerPreview?.userId == destinationUser.userId) {
      await _refreshSelectedOfficerPreviewAnchor();
    }
  }

  Future<void> _stopNavigation({
    bool clearMapRoute = false,
    bool showStoppedMessage = false,
  }) async {
    await _navigationPositionSubscription?.cancel();
    _navigationPositionSubscription = null;
    if (clearMapRoute) {
      await _clearMapOverlays();
    }

    if (!mounted) return;
    setState(() {
      _isNavigationRunning = false;
      _isNavigationLoading = false;
      _isRerouting = false;
      _navigationInstruction = '';
      _navigationModifier = 'straight';
      _nextNavigationInstruction = '';
      _nextNavigationModifier = 'straight';
      _navigationRemainingMeters = 0.0;
      _navigationRemainingSeconds = 0.0;
      _navigationEta = null;
    });

    if (showStoppedMessage && mounted) {
      await _showPopupMessage(
        'Navigasi dihentikan.',
        type: AppPopupType.info,
        title: 'Navigasi',
      );
    }
  }

  Future<void> _getRouteDirection(UserModel user) async {
    if (mapboxMap == null) {
      if (!mounted) return;
      await _showPopupMessage(
        'Map belum siap. Coba lagi.',
        type: AppPopupType.warning,
        title: 'Map Belum Siap',
      );
      return;
    }

    try {
      final currentPosition = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.bestForNavigation,
      );

      if (!isInsideMakkahOperationArea(
        currentPosition.latitude,
        currentPosition.longitude,
      )) {
        if (!mounted) return;
        await _showPopupMessage(
          'Lokasi Anda di luar area operasional $supportedOperationAreaLabel.',
          type: AppPopupType.warning,
          title: 'Area Operasional',
        );
        return;
      }

      if (!isInsideMakkahOperationArea(user.latitude, user.longitude)) {
        if (!mounted) return;
        await _showPopupMessage(
          'Lokasi tujuan di luar area operasional $supportedOperationAreaLabel.',
          type: AppPopupType.warning,
          title: 'Area Operasional',
        );
        return;
      }

      final directDistanceKm = calculateHaversineDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        user.latitude,
        user.longitude,
      );
      if (directDistanceKm > maxNavigationDistanceKm) {
        if (!mounted) return;
        await _showPopupMessage(
          'Tujuan terlalu jauh (${directDistanceKm.toStringAsFixed(2)} Km). Batas navigasi ${maxNavigationDistanceKm.toStringAsFixed(0)} Km.',
          type: AppPopupType.warning,
          title: 'Tujuan Terlalu Jauh',
        );
        return;
      }

      await _updateUserLocation(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      final route = await _fetchNavigationRoute(
        originLatitude: currentPosition.latitude,
        originLongitude: currentPosition.longitude,
        destinationLatitude: user.latitude,
        destinationLongitude: user.longitude,
      );

      if (route == null) {
        if (!mounted) return;
        await _showPopupMessage(
          'Rute tidak ditemukan.',
          type: AppPopupType.warning,
          title: 'Rute Tidak Ditemukan',
        );
        return;
      }

      await _renderNavigationRoute(
        origin: currentPosition,
        destinationUser: user,
        route: route,
      );
    } catch (e) {
      debugPrint('Failed to start navigation: $e');
      if (!mounted) return;
      await _showPopupMessage(
        'Gagal memulai navigasi.',
        type: AppPopupType.error,
        title: 'Navigasi Gagal',
      );
    }
  }

  Future<void> _openDirectionNavigation(UserModel user) async {
    if (!mounted) return;
    setState(() {
      _hideBackButton = true;
      _selectedOfficerPreview = null;
      _selectedOfficerPreviewOffset = null;
    });
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DirectionMapScreen(officer: user),
      ),
    );
    if (!mounted) return;
    setState(() {
      _hideBackButton = false;
    });
  }

  Future<void> _onOfficerCardTap(UserModel user) async {
    if (!mounted) return;
    setState(() {
      _selectedOfficerPreview = user;
      _selectedOfficerPreviewOffset = null;
    });
    await _getRouteDirection(user);
    await _refreshSelectedOfficerPreviewAnchor();
  }

  Future<void> _refreshSelectedOfficerPreviewAnchor() async {
    final selectedUser = _selectedOfficerPreview;
    final currentMap = mapboxMap;
    if (selectedUser == null || currentMap == null) return;
    if (_isNavigationRunning || _isNavigationLoading) return;

    if (_isResolvingPreviewAnchor) {
      _pendingPreviewAnchorRefresh = true;
      return;
    }

    _isResolvingPreviewAnchor = true;
    try {
      final pixel = await currentMap.pixelForCoordinate(
        Point(
          coordinates: Position(selectedUser.longitude, selectedUser.latitude),
        ),
      );

      if (!mounted) return;
      setState(() {
        _selectedOfficerPreviewOffset = Offset(pixel.x, pixel.y);
      });
    } catch (_) {
      // Keep map stable even if anchor projection fails.
    } finally {
      _isResolvingPreviewAnchor = false;
      if (_pendingPreviewAnchorRefresh) {
        _pendingPreviewAnchorRefresh = false;
        unawaited(_refreshSelectedOfficerPreviewAnchor());
      }
    }
  }

  Widget _buildOfficerPreviewPopup() {
    final user = _selectedOfficerPreview;
    final anchor = _selectedOfficerPreviewOffset;
    if (user == null ||
        anchor == null ||
        _isNavigationRunning ||
        _isNavigationLoading) {
      return const SizedBox.shrink();
    }

    const cardHeight = 90.0;
    final screenSize = MediaQuery.of(context).size;
    final displayName = _toTitleCase(user.name);
    final nameStyle = textStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w700,
      color: ColorSys.darkBlue,
    );
    const horizontalPadding = 24.0; // 12 left + 12 right
    const avatarAndGapWidth = 64.0; // 54 avatar + 10 gap
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
    final distanceText = _formatDistanceSmart(user.distance);
    final durationText = user.duration;
    final distDurPainter = TextPainter(
      text: TextSpan(
          text: '$distanceText  $durationText', style: distanceDurationStyle),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();
    // icons (12+4 + 12+4) + gap (8) = 40
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
                    child: user.imageUrl.trim().isEmpty
                        ? Container(
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(
                              Iconsax.profile_circle,
                              color: ColorSys.darkBlue,
                              size: 30,
                            ),
                          )
                        : Image.network(
                            user.imageUrl.trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
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
                          ),
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
                              _formatDistanceSmart(user.distance),
                              style: textStyle(
                                fontSize: 11,
                                color: ColorSys.darkBlue,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            const Icon(
                              Iconsax.clock,
                              size: 12.0,
                              color: ColorSys.darkBlue,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              user.duration,
                              style: textStyle(
                                fontSize: 11,
                                color: ColorSys.darkBlue,
                              ),
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

  Widget buildUserList(UserModel user) {
    return Container(
      width: 390.0,
      height: 200.0,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(25.0),
      child: Row(
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: SizedBox(
                        height: 122.0,
                        width: 120.0,
                        child: user.imageUrl.trim().isEmpty
                            ? Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Iconsax.profile_circle,
                                  color: ColorSys.darkBlue,
                                  size: 42,
                                ),
                              )
                            : Image.network(
                                user.imageUrl.trim(),
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
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Make the second column flexible to prevent overflow
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: SingleChildScrollView(
                // Allow scrolling if content exceeds
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _toTitleCase(user.name).length > 20
                          ? '${_toTitleCase(user.name).substring(0, 20)}...'
                          : _toTitleCase(user.name),
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
                        Flexible(
                          child: Text(
                            user.distance,
                            style: textStyle(
                              fontSize: 14,
                              color: ColorSys.darkBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        const Icon(
                          Iconsax.clock,
                          size: 14.0,
                          color: ColorSys.darkBlue,
                        ),
                        const SizedBox(width: 4.0),
                        Flexible(
                          child: Text(
                            user.duration,
                            style: textStyle(
                              fontSize: 14,
                              color: ColorSys.darkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _openDirectionNavigation(user),
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
                          onPressed: () => _openHelpChat(user),
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

  Widget _buildNavigationTopPanel() {
    if (_isNavigationLoading && !_isNavigationRunning) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: ColorSys.navigationPanelPrimary,
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

    final currentInstruction = _navigationInstruction.isEmpty
        ? 'Ikuti rute yang ditampilkan'
        : _navigationInstruction;
    final nextInstruction = _nextNavigationInstruction.isEmpty
        ? 'Lanjutkan sampai tujuan'
        : _nextNavigationInstruction;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: ColorSys.navigationPanelPrimary,
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
                          _navigationModifier,
                          instruction: currentInstruction,
                        ),
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDistanceMiles(_navigationRemainingMeters),
                        style: textStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentInstruction,
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
              color: ColorSys.navigationPanelSecondary,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Row(
                children: [
                  Icon(
                    _directionIcon(
                      _nextNavigationModifier,
                      instruction: nextInstruction,
                    ),
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      nextInstruction,
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
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Material(
        color: ColorSys.navigationDockButton,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Icon(icon, color: iconColor, size: 30),
        ),
      ),
    );
  }

  Widget _buildNavigationBottomDock() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorSys.navigationDockBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _buildDockButton(
            icon: Icons.search,
            iconColor: Colors.white,
            onTap: () {},
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatEta(_navigationEta),
                  style: textStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${_formatDurationCompact(_navigationRemainingSeconds)} • ${_formatDistanceMiles(_navigationRemainingMeters)}',
                  style: textStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_isRerouting)
                  Text(
                    'Menghitung ulang rute...',
                    style: textStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          _buildDockButton(
            icon: Icons.close_rounded,
            iconColor: ColorSys.navigationDanger,
            onTap: () {
              _stopNavigation(
                clearMapRoute: true,
                showStoppedMessage: true,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter and get the 10 nearest users
    List<UserModel> nearestUsers = users.take(10).toList();
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            styleUri: MapboxStyles.STANDARD,
            onMapCreated: _onMapCreated,
            onStyleLoadedListener: _onMapStyleLoaded,
            onCameraChangeListener: _onMapCameraChanged,
          ),
          if (!_hideBackButton)
            Positioned(
              top: 60.0,
              left: 25.0,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Iconsax.arrow_left_2,
                    color: ColorSys.darkBlue,
                    size: 30.0,
                  ),
                ),
              ),
            ),
          if (!_isCurrentUserPetugas &&
              !(_isNavigationRunning || _isNavigationLoading))
            Positioned(
              top: 60.0,
              right: 25.0,
              child: InkWell(
                onTap: () async {
                  if (_isNavigationRunning || _isNavigationLoading) {
                    await _stopNavigation(clearMapRoute: true);
                  }
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NavigationScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Iconsax.routing,
                    color: ColorSys.darkBlue,
                    size: 28.0,
                  ),
                ),
              ),
            ),
          if (!_isCurrentUserPetugas &&
              (_isNavigationRunning || _isNavigationLoading))
            Positioned(
              top: 104.0,
              left: 0,
              right: 0,
              child: _buildNavigationTopPanel(),
            ),
          if (!_isCurrentUserPetugas && _isNavigationRunning)
            Positioned(
              bottom: 18.0,
              left: 0,
              right: 0,
              child: _buildNavigationBottomDock(),
            ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: _isCurrentUserPetugas
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Text(
                      'Mode Petugas Haji belum difokuskan di versi ini. Fitur saat ini untuk Jemaah mencari Petugas terdekat.',
                      style: textStyle(
                        fontSize: 13,
                        color: ColorSys.darkBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : (_isNavigationRunning || _isNavigationLoading)
                    ? const SizedBox.shrink()
                    : SizedBox(
                        width: 390.0,
                        height: 212.0,
                        child: PageView(
                          controller: _pageController,
                          scrollDirection: Axis.horizontal,
                          children: [
                            SizedBox(
                              height: 212.0,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: nearestUsers.map((user) {
                                  return InkWell(
                                    onTap: () => _onOfficerCardTap(user),
                                    child: buildUserList(user),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
          if (!_isCurrentUserPetugas &&
              !(_isNavigationRunning || _isNavigationLoading) &&
              _selectedOfficerPreview != null)
            _buildOfficerPreviewPopup(),
          if (!_isNavigationRunning && !_isNavigationLoading)
            Positioned(
              bottom: 225.0,
              right: 25.0,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                child: const Icon(
                  Iconsax.location,
                  color: ColorSys.darkBlue,
                ),
                onPressed: () => _getUserLocation(),
              ),
            ),
          if (_isNavigationLoading && !_isNavigationRunning)
            Container(
              color: Colors.black.withOpacity(0.1),
            ),
        ],
      ),
    );
  }
}

class _NavigationRouteData {
  final List<Position> coordinates;
  final List<_RouteStep> steps;
  final double distanceMeters;
  final double durationSeconds;

  _NavigationRouteData({
    required this.coordinates,
    required this.steps,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

class _RouteStep {
  final String instruction;
  final String modifier;
  final double latitude;
  final double longitude;

  _RouteStep({
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
