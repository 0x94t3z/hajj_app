import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/screens/features/finding/haversine_algorithm.dart';
import 'package:hajj_app/screens/features/finding/users.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMapController? mapController;
  final PageController _pageController = PageController();
  List<User> users = [];

  @override
  void initState() {
    super.initState();

    // Initialize the list of users with their initial data
    users = [
      User(
        name: 'Muhamad Taopik',
        distance: '0 Km',
        duration: '10 Min',
        backgroundColor: Colors.white,
        buttonColor: ColorSys.darkBlue,
        buttonText: 'Go',
        buttonIcon: Iconsax.direct_up,
        imageUrl: 'https://avatars.githubusercontent.com/u/52822242?v=4',
        latitude: 21.422627,
        longitude: 39.826115,
      ),
      User(
        name: 'Imam Firdaus',
        distance: '0 Km',
        duration: '15 Min',
        backgroundColor: Colors.white,
        buttonColor: ColorSys.darkBlue,
        buttonText: 'Go',
        buttonIcon: Iconsax.direct_up,
        imageUrl: 'https://avatars.githubusercontent.com/u/65115314?v=4',
        latitude: 21.423797,
        longitude: 39.825303,
      ),
      User(
        name: 'Ilham Fadhlurahman',
        distance: '0 Km',
        duration: '20 Min',
        backgroundColor: Colors.white,
        buttonColor: ColorSys.darkBlue,
        buttonText: 'Go',
        buttonIcon: Iconsax.direct_up,
        imageUrl:
            'https://ugc.production.linktr.ee/17BkMbInQs600WGFE5cv_ml7ui23Oxne18rwt?io=true&size=avatar',
        latitude: 21.421034,
        longitude: 39.825859,
      ),
      User(
        name: 'Ikhsan Khoreul',
        distance: '0 Km',
        duration: '25 Min',
        backgroundColor: Colors.white,
        buttonColor: ColorSys.darkBlue,
        buttonText: 'Go',
        buttonIcon: Iconsax.direct_up,
        imageUrl: 'https://avatars.githubusercontent.com/u/64008898?v=4',
        latitude: 21.421835,
        longitude: 39.826029,
      ),
      User(
        name: 'Fauzan',
        distance: '0 Km',
        duration: '30 Min',
        backgroundColor: Colors.white,
        buttonColor: ColorSys.darkBlue,
        buttonText: 'Go',
        buttonIcon: Iconsax.direct_up,
        imageUrl:
            'https://i.pinimg.com/564x/c6/3f/72/c63f724ff95d6d869cac725215559fff.jpg',
        latitude: 21.421515,
        longitude: 39.827269,
      ),
    ];

    // Start a timer to update user distances periodically
    _getCurrentPosition();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  // List<User> users = [
  //   User(
  //     name: 'Muhamad Taopik',
  //     distance: user.distance,
  //     duration: '10 Min',
  //     backgroundColor: Colors.white,
  //     buttonColor: ColorSys.darkBlue,
  //     buttonText: 'Go',
  //     buttonIcon: Iconsax.direct_up,
  //     imageUrl: 'https://avatars.githubusercontent.com/u/52822242?v=4',
  //     latitude: 21.422627,
  //     longitude: 39.826115,
  //   ),
  //   User(
  //     name: 'Imam Firdaus',
  //     distance: user.distance,
  //     duration: '15 Min',
  //     backgroundColor: Colors.white,
  //     buttonColor: ColorSys.darkBlue,
  //     buttonText: 'Go',
  //     buttonIcon: Iconsax.direct_up,
  //     imageUrl: 'https://avatars.githubusercontent.com/u/65115314?v=4',
  //     latitude: 21.423797,
  //     longitude: 39.825303,
  //   ),
  //   User(
  //     name: 'Ilham Fadhlurahman',
  //     distance: user.distance,
  //     duration: '20 Min',
  //     backgroundColor: Colors.white,
  //     buttonColor: ColorSys.darkBlue,
  //     buttonText: 'Go',
  //     buttonIcon: Iconsax.direct_up,
  //     imageUrl:
  //         'https://ugc.production.linktr.ee/17BkMbInQs600WGFE5cv_ml7ui23Oxne18rwt?io=true&size=avatar',
  //     latitude: 21.421034,
  //     longitude: 39.825859,
  //   ),
  //   User(
  //     name: 'Ikhsan Khoreul',
  //     distance: user.distance,
  //     duration: '25 Min',
  //     backgroundColor: Colors.white,
  //     buttonColor: ColorSys.darkBlue,
  //     buttonText: 'Go',
  //     buttonIcon: Iconsax.direct_up,
  //     imageUrl: 'https://avatars.githubusercontent.com/u/64008898?v=4',
  //     latitude: 21.421835,
  //     longitude: 39.826029,
  //   ),
  //   User(
  //     name: 'Fauzan',
  //     distance: user.distance,
  //     duration: '30 Min',
  //     backgroundColor: Colors.white,
  //     buttonColor: ColorSys.darkBlue,
  //     buttonText: 'Go',
  //     buttonIcon: Iconsax.direct_up,
  //     imageUrl:
  //         'https://i.pinimg.com/564x/c6/3f/72/c63f724ff95d6d869cac725215559fff.jpg',
  //     latitude: 21.421515,
  //     longitude: 39.827269,
  //   ),
  // ];

  Future<void> _updateUserDistances() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      for (var user in users) {
        double distance = calculateHaversineDistance(
          position.latitude,
          position.longitude,
          user.latitude,
          user.longitude,
        );
        user.distance = '${distance.toStringAsFixed(2)} Km';
      }

      // Trigger a rebuild of the UI to reflect the updated distances
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _getCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Calculate distances for all users and update the list
      for (var user in users) {
        double distance = calculateHaversineDistance(
          position.latitude,
          position.longitude,
          user.latitude,
          user.longitude,
        );
        user.distance = '${distance.toStringAsFixed(2)} Km';
      }

      // Sort the users list by distance, with the closest user first
      users.sort((a, b) {
        double distanceA = double.parse(a.distance.split(' ')[0]);
        double distanceB = double.parse(b.distance.split(' ')[0]);
        return distanceA.compareTo(distanceB);
      });

      // Start a timer to update user distances periodically
      _updateUserDistances();

      // Trigger a rebuild of the UI to reflect the updated distances and sorting
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _getUserLocation(User user) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Clear existing route lines
      mapController?.clearLines();

      // Coordinates of the destination (user's location)
      double userLatitude = user.latitude;
      double userLongitude = user.longitude;

      // Your Mapbox API token
      String mapboxApiToken = dotenv.env['MAPBOX_SECRET_KEY']!;

      // Make a request to the Mapbox Directions API
      final response = await http.get(
        Uri.parse(
          'https://api.mapbox.com/directions/v5/mapbox/walking/${position.longitude},${position.latitude};$userLongitude,$userLatitude?geometries=geojson&access_token=$mapboxApiToken',
        ),
      );

      if (response.statusCode == 200) {
        // Parse the response JSON to get the route coordinates
        final Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> routes = data['routes'];
        if (routes.isNotEmpty) {
          List<dynamic> coordinates = routes[0]['geometry']['coordinates'];

          // Extract and draw the route coordinates on the map
          List<LatLng> routeCoordinates = coordinates.map((coord) {
            return LatLng(coord[1], coord[0]);
          }).toList();

          mapController?.addLine(
            LineOptions(
              geometry: routeCoordinates,
              lineJoin: "round",
              lineColor: "#478395",
              lineWidth: 4.0,
            ),
          );

          // Add markers at the starting and destination points
          mapController?.addSymbol(
            SymbolOptions(
              geometry: LatLng(position.latitude, position.longitude),
              iconSize: 0.3,
              textField: "You",
            ),
          );

          mapController?.addSymbol(
            SymbolOptions(
              geometry: LatLng(userLatitude, userLongitude),
              iconSize: 0.3,
              textField: "Officer",
            ),
          );

          // Update the map camera to fit the route
          mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  routeCoordinates
                      .reduce((min, current) =>
                          min.latitude < current.latitude ? min : current)
                      .latitude,
                  routeCoordinates
                      .reduce((min, current) =>
                          min.longitude < current.longitude ? min : current)
                      .longitude,
                ),
                northeast: LatLng(
                  routeCoordinates
                      .reduce((max, current) =>
                          max.latitude > current.latitude ? max : current)
                      .latitude,
                  routeCoordinates
                      .reduce((max, current) =>
                          max.longitude > current.longitude ? max : current)
                      .longitude,
                ),
              ),
              left: 50.0,
              right: 50.0,
              top: 50.0,
              bottom: 50.0,
            ),
          );

          double distance = calculateHaversineDistance(
            position.latitude,
            position.longitude,
            user.latitude,
            user.longitude,
          );

          // Display the distance to the destination
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Distance to Destination: ${distance.toStringAsFixed(2)} km'),
            ),
          );
        } else {
          print('No route found');
        }
      } else {
        print('Failed to load route');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Widget buildUserList(User user) {
    return Container(
      width: 390.0,
      height: 200.0,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: user.backgroundColor,
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
                        child: Image.network(
                          user.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: textStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorSys.darkBlue,
                    ),
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
                  const SizedBox(height: 30.0),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _getUserLocation(user),
                        icon: const Center(
                          child: Icon(Iconsax.direct_up),
                        ),
                        label: Text(user.buttonText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: user.buttonColor,
                          textStyle: const TextStyle(
                            fontSize: 14,
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
                        onPressed: () {},
                        icon: const Icon(Iconsax.danger),
                        label: const Text('Help'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          textStyle: const TextStyle(
                            fontSize: 14,
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapboxMap(
            styleString: MapboxStyles.MAPBOX_STREETS,
            accessToken: dotenv.env['MAPBOX_SECRET_KEY']!,
            onMapCreated: _onMapCreated,
            myLocationRenderMode: MyLocationRenderMode.NORMAL,
            myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
            initialCameraPosition: const CameraPosition(
              target: LatLng(21.422627, 39.826115),
              zoom: 14.0,
            ),
          ),
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
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: SizedBox(
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
                      children: users.map((user) {
                        return InkWell(
                          onTap: () => _getUserLocation(user),
                          child: buildUserList(user),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 225.0,
            right: 25.0,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: const Icon(
                Iconsax.location,
                color: ColorSys.darkBlue,
              ),
              onPressed: () => _getUserLocation(
                  users[0]), // Set an initial user to load directions
            ),
          ),
        ],
      ),
    );
  }
}
