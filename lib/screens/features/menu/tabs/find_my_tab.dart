import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/core/widgets/app_popup.dart';
import 'package:hajj_app/widgets/radar/finding.dart';
import 'package:hajj_app/core/theme/app_style.dart';
import 'package:hajj_app/services/user_service.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoding/geocoding.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FindMyTab extends StatefulWidget {
  final int refreshTick;
  final bool isActive;

  const FindMyTab({
    Key? key,
    this.refreshTick = 0,
    this.isActive = false,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FindMyTabState createState() => _FindMyTabState();
}

class _FindMyTabState extends State<FindMyTab> {
  final UserService _userService = UserService();
  MapboxMap? mapboxMap;
  geo.Position? currentPosition;
  String locationName = 'Meca, Saudi Arabia';
  String buttonLabel = 'Find Officers';
  bool _locationPermissionDeniedLogged = false;
  bool _mapReady = false;
  bool _enableMap = false;
  bool _pendingRefreshOnActivate = false;

  final animationsMap = {
    'containerOnPageLoadAnimation5': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 600.ms),
        ScaleEffect(
          curve: Curves.easeOut,
          delay: 600.ms,
          duration: 400.ms,
          begin: const Offset(2.0, 2.0),
          end: const Offset(1.0, 1.0),
        ),
        FadeEffect(
          curve: Curves.easeOut,
          delay: 600.ms,
          duration: 400.ms,
          begin: 0.0,
          end: 1.0,
        ),
        BlurEffect(
          curve: Curves.easeOut,
          delay: 600.ms,
          duration: 400.ms,
          begin: const Offset(10.0, 10.0),
          end: const Offset(0.0, 0.0),
        ),
        MoveEffect(
          curve: Curves.easeOut,
          delay: 600.ms,
          duration: 400.ms,
          begin: const Offset(0.0, 70.0),
          end: const Offset(0.0, 0.0),
        ),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _enableMap = widget.isActive;
    _setButtonLabel();
  }

  @override
  void didUpdateWidget(covariant FindMyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_enableMap) {
      setState(() {
        _enableMap = true;
      });
    }

    if (widget.isActive && _pendingRefreshOnActivate && _mapReady) {
      _pendingRefreshOnActivate = false;
      unawaited(_getUserLocation());
    }

    if (widget.refreshTick != oldWidget.refreshTick) {
      if (widget.isActive && _mapReady) {
        _getUserLocation();
      } else {
        _pendingRefreshOnActivate = true;
      }
    }
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    mapboxMap = map;
    _mapReady = true;
    mapboxMap?.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(39.826115, 21.422627),
        ),
        zoom: 14.0,
      ),
    );
    await map.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: false,
        showAccuracyRing: false,
        puckBearingEnabled: true,
        puckBearing: PuckBearing.HEADING,
        locationPuck: LocationPuck(locationPuck2D: DefaultLocationPuck2D()),
      ),
    );

    // Auto refresh when entering this menu and map is ready.
    await _getUserLocation();
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!_locationPermissionDeniedLogged) {
        _locationPermissionDeniedLogged = true;
        debugPrint('Location service is disabled.');
      }
      return false;
    }

    var permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }

    final granted = permission == geo.LocationPermission.always ||
        permission == geo.LocationPermission.whileInUse;

    if (!granted && !_locationPermissionDeniedLogged) {
      _locationPermissionDeniedLogged = true;
      debugPrint('Location permission denied: $permission');
    }

    if (granted) {
      _locationPermissionDeniedLogged = false;
    }
    return granted;
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

  String _buildReadableLocation(Placemark placemark) {
    final parts = <String>[
      if ((placemark.subLocality ?? '').trim().isNotEmpty)
        placemark.subLocality!.trim(),
      if ((placemark.locality ?? '').trim().isNotEmpty)
        placemark.locality!.trim(),
      if ((placemark.country ?? '').trim().isNotEmpty)
        placemark.country!.trim(),
    ];
    if (parts.isEmpty) {
      return placemark.name?.trim().isNotEmpty == true
          ? placemark.name!.trim()
          : 'Unknown Location';
    }
    return parts.join(', ');
  }

  Future<void> _getUserLocation() async {
    if (!_mapReady) return;
    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) return;

      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      // Update current user's location in Firebase Realtime Database
      await _updateUserLocation(position.latitude, position.longitude);

      // Get the location name based on the coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Extract the location name
      if (placemarks.isNotEmpty) {
        String retrievedLocationName = _buildReadableLocation(placemarks.first);
        if (!mounted) return;
        setState(() {
          locationName = retrievedLocationName;
        });
      }

      // Update the map camera to center around the user's location.
      mapboxMap?.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: 16.0,
        ),
        MapAnimationOptions(duration: 1200),
      );

      if (!mounted) return;
      setState(() {
        currentPosition = position;
      });
    } catch (e) {
      // Handle any errors that may occur when getting the location.
      debugPrint('Failed getting user location: $e');
    }
  }

  Future<void> _setButtonLabel() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final role = await _userService.fetchCurrentUserRole(defaultRole: '');
        final isPetugas = _userService.isPetugasHajiRole(role);

        if (!mounted) return;
        setState(() {
          buttonLabel = isPetugas ? 'Find Pilgrims' : 'Find Officers';
        });
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Gagal Memuat Peran',
        message: e.message ?? 'Failed to read user role.',
      );
    } catch (e) {
      debugPrint('Error fetching user role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30.0),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardHeight = constraints.maxHeight < 450.0
                      ? constraints.maxHeight
                      : 450.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: cardHeight,
                        child: Container(
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
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: _enableMap
                                            ? MapWidget(
                                                onMapCreated: _onMapCreated,
                                                styleUri:
                                                    MapboxStyles.MAPBOX_STREETS,
                                              )
                                            : Container(
                                                color: Colors.grey.shade100,
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Iconsax.map_1,
                                                      color: ColorSys.darkBlue,
                                                      size: 34,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Map will load when this tab is opened',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: textStyle(
                                                        fontSize: 12,
                                                        color:
                                                            ColorSys.darkBlue,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10.0,
                                      right: 8.0,
                                      child: FloatingActionButton(
                                        backgroundColor: Colors.white,
                                        mini: true,
                                        child: const Icon(
                                          Iconsax.gps,
                                          color: ColorSys.darkBlue,
                                        ),
                                        onPressed: () => _getUserLocation(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14.0),
                              Text(
                                'Your location',
                                style: textStyle(
                                    fontSize: 14, color: ColorSys.darkBlue),
                              ),
                              Text(
                                locationName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: ColorSys.darkBlue,
                                ),
                              ),
                              const SizedBox(height: 18.0),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Padding(
                                          padding:
                                              MediaQuery.of(context).viewInsets,
                                          child: const SizedBox(
                                            height: double.infinity,
                                            child: FindingWidget(),
                                          ),
                                        ).animateOnPageLoad(
                                          animationsMap[
                                              'containerOnPageLoadAnimation5']!,
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Iconsax.radar_2,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    buttonLabel,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorSys.darkBlue,
                                    textStyle: const TextStyle(fontSize: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
  }
}
