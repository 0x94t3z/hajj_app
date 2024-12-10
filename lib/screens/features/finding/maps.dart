import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajj_app/models/users.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/screens/features/finding/haversine_algorithm.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMapController? mapController;
  final PageController _pageController = PageController();
  List<UserModel> users = [];
  // late MapBoxOptions _navigationOption;
  // double? distanceRemaining, durationRemaining;
  // MapBoxNavigationViewController? _controller;
  // final bool isMultipleStop = false;
  // String? instruction = "";
  // bool routeBuilt = false;
  // bool isNavigating = false;

  @override
  void initState() {
    super.initState();

    // Start a timer to update user distances periodically
    _getCurrentPosition();
    // Call a method to fetch or initialize users when the screen loads
    fetchData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  Future<void> fetchData() async {
    // Fetch or initialize users here, such as from Firebase or any other source
    Map<String, List<UserModel>> usersMap =
        await fetchModelsFromFirebase(); // Use fetchModelsFromFirebase

    List<UserModel> petugasHaji =
        usersMap['petugasHaji'] ?? []; // Extract the list of users
    List<UserModel> filteredUsers = [];

    // Assuming you have the current user's role stored in a variable
    String currentUserRole =
        'Jemaah Haji'; // Replace this with actual logic to get current user role

    // Check if current user is 'Jemaah Haji'
    if (currentUserRole == 'Jemaah Haji') {
      // Filter out users in 'petugasHaji' where latitude and longitude are not valid (i.e., not 0.0 or null)
      filteredUsers = petugasHaji.where((user) {
        // Ensure that latitude and longitude are valid (non-zero and non-null)
        return (user.latitude != 0.0) && (user.longitude != 0.0);
      }).toList();
    }

    // Update the state with the filtered data
    setState(() {
      users = filteredUsers;
    });
  }

  Future<void> _updateUserLocation(double latitude, double longitude) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child('users/${currentUser.uid}');
        await userRef.update({
          'latitude': latitude,
          'longitude': longitude,
        });
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
          'https://api.mapbox.com/directions/v5/mapbox/walking/$originLongitude,$originLatitude;$destinationLongitude,$destinationLatitude?geometries=geojson&access_token=$mapboxApiToken',
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
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Fetch users from Firebase
      Map<String, List<UserModel>> usersMap = await fetchModelsFromFirebase();
      List<UserModel> allUsers = usersMap['petugasHaji'] ?? [];

      List<UserModel> validUsers = allUsers.where((user) {
        // Ensure latitude and longitude are valid
        return user.latitude != 0.0 && user.longitude != 0.0;
      }).toList();

      // Update distances and durations for valid users
      for (var user in validUsers) {
        double distance = calculateHaversineDistance(
          position.latitude,
          position.longitude,
          user.latitude,
          user.longitude,
        );
        user.distance = '${distance.toStringAsFixed(2)} Km';

        String duration = await getRouteDuration(
          position.latitude,
          position.longitude,
          user.latitude,
          user.longitude,
        );
        user.duration = '$duration Min';
      }

      // Sort users by distance
      validUsers.sort((a, b) {
        double distanceA = double.parse(a.distance.split(' ')[0]);
        double distanceB = double.parse(b.distance.split(' ')[0]);
        return distanceA.compareTo(distanceB);
      });

      // Update the state with sorted and updated users
      setState(() {
        users = validUsers;
      });
    } catch (e) {
      print('Error updating user distances: ${e.toString()}');
    }
  }

  Future<void> _getCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update current user's location in Firebase Realtime Database
      await _updateUserLocation(position.latitude, position.longitude);

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

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update current user's location in Firebase Realtime Database
      await _updateUserLocation(position.latitude, position.longitude);

      // Clear existing route lines
      mapController?.clearLines();

      // Clear existing symbols
      mapController?.clearSymbols();

      // Update the map camera to center around the user's location.
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        16.0,
      ));

      // Add markers [IMAGE] at the starting points
      mapController?.addSymbol(
        SymbolOptions(
          geometry: LatLng(position.latitude, position.longitude),
          iconImage: ('assets/images/location_pin.png'),
          fontNames: ['DIN Offc Pro Bold', 'Arial Unicode MS Regular'],
          textField: 'My Location',
          textSize: 12.5,
          textOffset: const Offset(0, 0.8),
          textAnchor: 'top',
          textColor: '#000000',
          textHaloBlur: 1,
          textHaloColor: '#ffffff',
          textHaloWidth: 0.8,
          iconSize: 0.8,
        ),
      );
    } catch (e) {
      // Handle any errors that may occur when getting the location.
      print(e.toString());
    }
  }

  Future<void> _getRouteDirection(UserModel user) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update current user's location in Firebase Realtime Database
      await _updateUserLocation(position.latitude, position.longitude);

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

          // Clear existing symbols
          mapController?.clearSymbols();

          // Add markers at the starting and destination points
          mapController?.addSymbol(
            SymbolOptions(
              geometry: LatLng(position.latitude, position.longitude),
              iconImage: ('assets/images/pilgrim.png'),
              fontNames: ['DIN Offc Pro Bold', 'Arial Unicode MS Regular'],
              textField: 'My Location',
              textSize: 12.5,
              textOffset: const Offset(0, 0.8),
              textAnchor: 'top',
              textColor: '#000000',
              textHaloBlur: 1,
              textHaloColor: '#ffffff',
              textHaloWidth: 0.8,
              iconSize: 0.8,
            ),
          );

          mapController?.addSymbol(
            SymbolOptions(
              geometry: LatLng(userLatitude, userLongitude),
              iconImage: ('assets/images/officer.png'),
              fontNames: ['DIN Offc Pro Bold', 'Arial Unicode MS Regular'],
              textField: 'Officer',
              textSize: 12.5,
              textOffset: const Offset(0, -2.0),
              textAnchor: 'top',
              textColor: '#000000',
              textHaloBlur: 1,
              textHaloColor: '#ffffff',
              textHaloWidth: 0.8,
              iconSize: 0.8,
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
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Distance to Destination: ${distance.toStringAsFixed(2)} Km'),
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

  Future<void> _getUserDirection(UserModel user) async {
    try {
      // Coordinates of the destination (user's location)
      double userLatitude = user.latitude;
      double userLongitude = user.longitude;

      final String query =
          "$userLatitude,$userLongitude"; // Destination coordinates

      // Use Apple Maps on iOS and Google Maps on Android
      final String appleMapsUrl = "https://maps.apple.com/?daddr=$query";
      final String googleMapsUrl =
          "https://www.google.com/maps/dir/?api=1&destination=$query";

      if (await canLaunch(appleMapsUrl)) {
        await launch(appleMapsUrl);
      } else if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        throw 'Could not launch maps.';
      }
    } catch (e) {
      print(e.toString());
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
                      user.name.length > 20
                          ? '${user.name.substring(0, 20)}...'
                          : user.name,
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
                          onPressed: () {
                            _getUserDirection(user);
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
                          onPressed: () {},
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

  @override
  Widget build(BuildContext context) {
    // Filter and get the five nearest users
    List<UserModel> nearestUsers = users.take(5).toList();
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
        ],
      ),
    );
  }
}
