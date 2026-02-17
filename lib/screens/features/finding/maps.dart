import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajj_app/helpers/app_popup.dart';
import 'package:hajj_app/models/users.dart';
import 'package:hajj_app/services/user_service.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/screens/features/finding/haversine_algorithm.dart';
import 'package:hajj_app/screens/features/finding/navigation.dart';
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
  MapboxMap? mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
  Uint8List? _destinationMarker;
  final PageController _pageController = PageController();
  bool _hideBackButton = false;
  List<UserModel> users = [];
  bool _isCurrentUserPetugas = false;
  StreamSubscription<geo.Position>? _navigationPositionSubscription;

  bool _isNavigationLoading = false;
  bool _isNavigationRunning = false;
  bool _isRerouting = false;
  UserModel? _activeNavigationTarget;
  List<Position> _activeRouteCoordinates = [];
  List<_RouteStep> _activeRouteSteps = [];
  int _activeStepIndex = 0;
  String _navigationInstruction = '';
  String _navigationModifier = 'straight';
  String _nextNavigationInstruction = '';
  String _nextNavigationModifier = 'straight';
  double _navigationRemainingMeters = 0.0;
  double _navigationRemainingSeconds = 0.0;
  DateTime? _navigationEta;
  DateTime? _lastRerouteTime;

  static const double _arrivalThresholdMeters = 20.0;
  static const double _offRouteThresholdMeters = 35.0;
  static const Duration _minimumRerouteGap = Duration(seconds: 8);
  static const int _maxNearestOfficers = 10;

  @override
  void initState() {
    super.initState();

    // Get the current user's role
    _getCurrentUserRole();
    // Start a timer to update user distances periodically
    _getCurrentPosition();
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
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    mapboxMap = map;
    mapboxMap?.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(39.826115, 21.422627),
        ),
        zoom: 14.0,
        pitch: 0,
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
    _destinationMarker ??= await _loadMarkerBytes('assets/images/pin_3.png');

    // Auto zoom to current user location when map is ready (same behavior as second.dart).
    await _getUserLocation();
  }

  Future<Uint8List> _loadMarkerBytes(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    return bytes.buffer.asUint8List();
  }

  Future<void> _clearMapOverlays() async {
    await _polylineAnnotationManager?.deleteAll();
    await _pointAnnotationManager?.deleteAll();
  }

  Future<void> _addPointMarker({
    required double latitude,
    required double longitude,
    required String label,
    required Uint8List? imageBytes,
    List<double>? textOffset,
  }) async {
    if (imageBytes == null || _pointAnnotationManager == null) {
      return;
    }
    await _pointAnnotationManager!.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(longitude, latitude),
        ),
        image: imageBytes,
        iconSize: 0.8,
        textField: label,
        textSize: 12.5,
        textColor: Colors.black.value,
        textHaloColor: Colors.white.value,
        textHaloWidth: 0.8,
        textOffset: textOffset ?? [0.0, 0.8],
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

  Future<List<UserModel>> _buildNearestPetugasList({
    required geo.Position currentPosition,
    required List<UserModel> petugasHaji,
  }) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    final rankedUsers = petugasHaji
        .where(
          (user) =>
              user.latitude != 0.0 &&
              user.longitude != 0.0 &&
              user.userId != currentUid,
        )
        .map(
          (user) => MapEntry(
            user,
            calculateHaversineDistance(
              currentPosition.latitude,
              currentPosition.longitude,
              user.latitude,
              user.longitude,
            ),
          ),
        )
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final nearestRanked = rankedUsers.take(_maxNearestOfficers).toList();
    final nearestUsers = <UserModel>[];

    for (final rankedUser in nearestRanked) {
      final user = rankedUser.key;
      final distanceKm = rankedUser.value;
      user.distance = '${distanceKm.toStringAsFixed(2)} Km';

      final duration = await getRouteDuration(
        currentPosition.latitude,
        currentPosition.longitude,
        user.latitude,
        user.longitude,
      );
      user.duration = '$duration Min';
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
      print('Current user role: $currentUserRole');

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
      print('Error fetching data: $e');
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _updateUserLocation(double latitude, double longitude) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _userService.updateCurrentUserLocation(latitude, longitude);
        print('User location updated successfully.');
      } else {
        print('User is not authenticated.');
      }
    } catch (e) {
      print('Error updating user location: $e');
    }
  }

  Future<String> getRouteDuration(double originLatitude, double originLongitude,
      double destinationLatitude, double destinationLongitude) async {
    try {
      // Your Mapbox API token
      String mapboxApiToken = dotenv.env['MAPBOX_SECRET_KEY']!;

      final response = await http.get(
        Uri.parse(
          'https://api.mapbox.com/directions/v5/mapbox/walking/$originLongitude,$originLatitude;$destinationLongitude,$destinationLatitude?geometries=geojson&language=id&voice_units=metric&access_token=$mapboxApiToken',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> routes = data['routes'];

        if (routes.isNotEmpty) {
          // Extracting duration from the API response
          double durationInSeconds = routes[0]['duration'].toDouble();

          // Converting duration from seconds to minutes as a double
          double durationInMinutes = durationInSeconds / 60;

          // Convert durationInMinutes to an int before converting to a string
          int durationInMinutesInt = durationInMinutes.toInt();

          // Returning duration as a string rounded to 2 decimal places
          return durationInMinutesInt.toString();
        } else {
          print('No routes found');
          return 'N/A';
        }
      } else {
        // print('Request failed with status: ${response.statusCode}');
        return 'N/A';
      }
    } catch (e) {
      print('Error fetching route duration: $e');
      return 'N/A';
    }
  }

  Future<void> _updateUserDistances() async {
    try {
      // Get the current position of the device
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      // Get the current user's role
      String currentUserRole = await _getCurrentUserRole();
      print('Current user role: $currentUserRole');

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
      print('Error updating user distances: $e');
    } catch (e) {
      print('Error updating user distances: ${e.toString()}');
    }
  }

  Future<void> _getCurrentPosition() async {
    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      // Update current user's location in Firebase Realtime Database
      await _updateUserLocation(position.latitude, position.longitude);

      // Refresh nearest officer list (max 10)
      _updateUserDistances();
    } catch (e) {
      print(e.toString());
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
            zoom: 18.0,
            pitch: 70,
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
        ),
        MapAnimationOptions(duration: 1200),
      );
    } catch (e) {
      // Handle any errors that may occur when getting the location.
      print(e.toString());
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

  void _updateNextInstruction() {
    if (_activeRouteSteps.isEmpty) {
      _nextNavigationInstruction = '';
      _nextNavigationModifier = 'straight';
      return;
    }
    if (_activeStepIndex + 1 < _activeRouteSteps.length) {
      _nextNavigationInstruction =
          _activeRouteSteps[_activeStepIndex + 1].instruction;
      _nextNavigationModifier =
          _activeRouteSteps[_activeStepIndex + 1].modifier;
      return;
    }
    _nextNavigationInstruction = 'Lanjutkan hingga tujuan';
    _nextNavigationModifier = 'straight';
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

    return _NavigationRouteData(
      coordinates: coordinates,
      steps: steps,
      distanceMeters: (route['distance'] as num?)?.toDouble() ?? 0,
      durationSeconds: (route['duration'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<void> _renderNavigationRoute({
    required geo.Position origin,
    required UserModel destinationUser,
    required _NavigationRouteData route,
  }) async {
    await _clearMapOverlays();

    if (route.coordinates.isNotEmpty) {
      await _polylineAnnotationManager?.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: route.coordinates),
          lineJoin: LineJoin.ROUND,
          lineColor: 0xFF74C1FF,
          lineWidth: 9.0,
          lineBorderColor: 0xFF2D6CFF,
          lineBorderWidth: 3.0,
          lineBlur: 0.2,
          lineEmissiveStrength: 0.5,
        ),
      );
    }

    await _addPointMarker(
      latitude: destinationUser.latitude,
      longitude: destinationUser.longitude,
      label: _toTitleCase(destinationUser.name),
      imageBytes: _destinationMarker,
      textOffset: [0.0, -2.0],
    );

    final centerLatitude = (origin.latitude + destinationUser.latitude) / 2;
    final centerLongitude = (origin.longitude + destinationUser.longitude) / 2;

    mapboxMap?.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(centerLongitude, centerLatitude),
        ),
        zoom: 18.0,
        pitch: 70,
        bearing: origin.heading > 0 ? origin.heading : 0,
      ),
      MapAnimationOptions(duration: 1200),
    );
  }

  // ignore: unused_element
  Future<void> _startNavigationTracking() async {
    await _navigationPositionSubscription?.cancel();
    const locationSettings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.bestForNavigation,
      distanceFilter: 3,
    );

    _navigationPositionSubscription = geo.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (position) async {
        if (!_isNavigationRunning) return;
        await _updateUserLocation(position.latitude, position.longitude);
        await _handleNavigationPositionUpdate(position);
      },
      onError: (error) {
        print('Navigation location stream error: $error');
      },
    );
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
      _activeNavigationTarget = null;
      _activeRouteCoordinates = [];
      _activeRouteSteps = [];
      _activeStepIndex = 0;
      _navigationInstruction = '';
      _navigationModifier = 'straight';
      _nextNavigationInstruction = '';
      _nextNavigationModifier = 'straight';
      _navigationRemainingMeters = 0.0;
      _navigationRemainingSeconds = 0.0;
      _navigationEta = null;
      _lastRerouteTime = null;
    });

    if (showStoppedMessage && mounted) {
      await _showPopupMessage(
        'Navigasi dihentikan.',
        type: AppPopupType.info,
        title: 'Navigasi',
      );
    }
  }

  double _distanceBetweenMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return calculateHaversineDistance(lat1, lon1, lat2, lon2) * 1000;
  }

  double _distanceFromRouteMeters(geo.Position position) {
    if (_activeRouteCoordinates.isEmpty) return 0;
    var minDistance = double.infinity;
    for (final coordinate in _activeRouteCoordinates) {
      final distance = _distanceBetweenMeters(
        position.latitude,
        position.longitude,
        coordinate.lat.toDouble(),
        coordinate.lng.toDouble(),
      );
      if (distance < minDistance) {
        minDistance = distance;
      }
    }
    return minDistance;
  }

  Future<void> _tryReroute(geo.Position position) async {
    if (_isRerouting || !_isNavigationRunning) return;
    final target = _activeNavigationTarget;
    if (target == null) return;

    final now = DateTime.now();
    if (_lastRerouteTime != null &&
        now.difference(_lastRerouteTime!) < _minimumRerouteGap) {
      return;
    }

    if (mounted) {
      setState(() {
        _isRerouting = true;
      });
    } else {
      _isRerouting = true;
    }
    _lastRerouteTime = now;
    try {
      final route = await _fetchNavigationRoute(
        originLatitude: position.latitude,
        originLongitude: position.longitude,
        destinationLatitude: target.latitude,
        destinationLongitude: target.longitude,
      );
      if (route == null) return;

      await _renderNavigationRoute(
        origin: position,
        destinationUser: target,
        route: route,
      );

      if (!mounted) return;
      setState(() {
        _activeRouteCoordinates = route.coordinates;
        _activeRouteSteps = route.steps;
        _activeStepIndex = 0;
        _navigationInstruction = route.steps.isNotEmpty
            ? route.steps.first.instruction
            : 'Lanjutkan ke tujuan';
        _navigationModifier =
            route.steps.isNotEmpty ? route.steps.first.modifier : 'straight';
        _navigationRemainingMeters = route.distanceMeters;
        _navigationRemainingSeconds = route.durationSeconds;
        _navigationEta = DateTime.now().add(
          Duration(seconds: route.durationSeconds.ceil()),
        );
        _updateNextInstruction();
      });
    } catch (e) {
      print('Reroute failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRerouting = false;
        });
      } else {
        _isRerouting = false;
      }
    }
  }

  Future<void> _handleNavigationPositionUpdate(geo.Position position) async {
    final target = _activeNavigationTarget;
    if (target == null || !_isNavigationRunning) return;

    final remainingDistance = _distanceBetweenMeters(
      position.latitude,
      position.longitude,
      target.latitude,
      target.longitude,
    );

    if (remainingDistance <= _arrivalThresholdMeters) {
      await _stopNavigation(clearMapRoute: false);
      if (!mounted) return;
      await _showPopupMessage(
        'Anda sudah sampai di ${_toTitleCase(target.name)}.',
        type: AppPopupType.success,
        title: 'Tujuan Tercapai',
      );
      return;
    }

    if (_activeStepIndex < _activeRouteSteps.length) {
      final currentStep = _activeRouteSteps[_activeStepIndex];
      final stepDistance = _distanceBetweenMeters(
        position.latitude,
        position.longitude,
        currentStep.latitude,
        currentStep.longitude,
      );
      if (stepDistance <= 15 &&
          _activeStepIndex < _activeRouteSteps.length - 1) {
        _activeStepIndex++;
      }
    }

    final offRouteDistance = _distanceFromRouteMeters(position);
    if (offRouteDistance > _offRouteThresholdMeters) {
      await _tryReroute(position);
    }

    if (!mounted) return;
    setState(() {
      _navigationInstruction = _activeRouteSteps.isNotEmpty
          ? _activeRouteSteps[_activeStepIndex].instruction
          : 'Lanjutkan ke tujuan';
      _navigationModifier = _activeRouteSteps.isNotEmpty
          ? _activeRouteSteps[_activeStepIndex].modifier
          : 'straight';
      _navigationRemainingMeters = remainingDistance;
      const walkingMetersPerSecond = 1.39;
      _navigationRemainingSeconds = remainingDistance / walkingMetersPerSecond;
      _navigationEta = DateTime.now().add(
        Duration(seconds: _navigationRemainingSeconds.ceil()),
      );
      _updateNextInstruction();
    });

    mapboxMap?.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
        zoom: 18.0,
        bearing: position.heading > 0 ? position.heading : 0,
        pitch: 70,
      ),
    );
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
      print('Failed to start navigation: $e');
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
                        Text(
                          user.distance,
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
                          user.duration,
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

    final currentInstruction = _navigationInstruction.isEmpty
        ? 'Ikuti rute yang ditampilkan'
        : _navigationInstruction;
    final nextInstruction = _nextNavigationInstruction.isEmpty
        ? 'Lanjutkan sampai tujuan'
        : _nextNavigationInstruction;

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
              color: const Color(0xFF2A4FB5),
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

  Widget _buildNavigationBottomDock() {
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
            iconColor: const Color(0xFFFF4A57),
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
            styleUri: MapboxStyles.MAPBOX_STREETS,
            onMapCreated: _onMapCreated,
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
                                    onTap: () => _getRouteDirection(user),
                                    child: buildUserList(user),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
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
