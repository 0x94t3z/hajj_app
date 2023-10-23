// import 'package:flutter/material.dart';
// import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:hajj_app/screens/features/finding/users.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';

// class Navigation extends StatefulWidget {
//   const Navigation({Key? key}) : super(key: key);

//   @override
//   State<Navigation> createState() => _NavigationState();
// }

// class _NavigationState extends State<Navigation> {
//   late List<User> users;
//   late Position position;
//   double? userLatitude;
//   double? userLongitude;
//   late LatLng source;
//   late LatLng destination;
//   late WayPoint sourceWaypoint, destinationWaypoint;
//   var wayPoints = <WayPoint>[];

//   // Config variables for Mapbox Navigation
//   late MapBoxNavigation directions;
//   late MapBoxOptions _options;
//   double? distanceRemaining, durationRemaining;
//   MapBoxNavigationViewController? _controller;
//   final bool isMultipleStop = false;
//   String? instruction = "";
//   bool routeBuilt = false;
//   bool isNavigating = false;

//   @override
//   void initState() {
//     super.initState();
//     loadInitialData();
//     initialize();

//     // Register the route event listener
//     MapBoxNavigation.instance.registerRouteEventListener(_onRouteEvent);
//   }

//   Future<void> loadInitialData() async {
//     users = initializeUsers();
//     position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     userLatitude = users.isNotEmpty ? users[0].latitude : 0.0;
//     userLongitude = users.isNotEmpty ? users[0].longitude : 0.0;
//     source = LatLng(position.latitude, position.longitude);
//     destination = LatLng(userLatitude ?? 0.0, userLongitude ?? 0.0);
//   }

//   Future<void> initialize() async {
//     if (!mounted) return;

//     // Setup directions and options
//     directions = MapBoxNavigation();
//     _options = MapBoxOptions(
//       zoom: 18.0,
//       voiceInstructionsEnabled: true,
//       bannerInstructionsEnabled: true,
//       mode: MapBoxNavigationMode.drivingWithTraffic,
//       isOptimized: true,
//       units: VoiceUnits.metric,
//       simulateRoute: true,
//       language: "en",
//     );

//     // Configure waypoints
//     sourceWaypoint = WayPoint(
//       name: "Source",
//       latitude: source.latitude,
//       longitude: source.longitude,
//     );
//     destinationWaypoint = WayPoint(
//       name: "Destination",
//       latitude: destination.latitude,
//       longitude: destination.longitude,
//     );
//     wayPoints.add(sourceWaypoint);
//     wayPoints.add(destinationWaypoint);

//     // Start the trip
//     await directions.startNavigation(wayPoints: wayPoints, options: _options);
//   }

//   Future<void> _onRouteEvent(RouteEvent e) async {
//     distanceRemaining = await MapBoxNavigation.instance.getDistanceRemaining();
//     durationRemaining = await MapBoxNavigation.instance.getDurationRemaining();

//     switch (e.eventType) {
//       case MapBoxEvent.progress_change:
//         var progressEvent = e.data as RouteProgressEvent;
//         if (progressEvent.currentStepInstruction != null) {
//           instruction = progressEvent.currentStepInstruction;
//         }
//         break;
//       case MapBoxEvent.route_building:
//       case MapBoxEvent.route_built:
//         setState(() {
//           routeBuilt = true;
//         });
//         break;
//       case MapBoxEvent.route_build_failed:
//         setState(() {
//           routeBuilt = false;
//         });
//         break;
//       case MapBoxEvent.navigation_running:
//         setState(() {
//           isNavigating = true;
//         });
//         break;
//       case MapBoxEvent.on_arrival:
//         if (!isMultipleStop) {
//           await Future.delayed(const Duration(seconds: 3));
//           await _controller?.finishNavigation();
//         } else {}
//         break;
//       case MapBoxEvent.navigation_finished:
//       case MapBoxEvent.navigation_cancelled:
//         setState(() {
//           routeBuilt = false;
//           isNavigating = false;
//         });
//         break;
//       default:
//         break;
//     }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     //return const RateRide();
//     return const SizedBox(
//         width: 300, height: 400, child: CircularProgressIndicator());
//   }
// }
