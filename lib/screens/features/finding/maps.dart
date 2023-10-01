import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'dart:math' as math;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMapController? mapController;

  @override
  void initState() {
    super.initState();
  }

  double degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  double calculateHaversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers

    // Convert latitude and longitude from degrees to radians
    final double lat1Rad = degreesToRadians(lat1);
    final double lon1Rad = degreesToRadians(lon1);
    final double lat2Rad = degreesToRadians(lat2);
    final double lon2Rad = degreesToRadians(lon2);

    // Haversine formula
    final double dlon = lon2Rad - lon1Rad;
    final double dlat = lat2Rad - lat1Rad;
    final double a = math.pow(math.sin(dlat / 2), 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) * math.pow(math.sin(dlon / 2), 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance; // Distance in kilometers
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Coordinates of user 2 (you can replace these with the second user's coordinates)
      double user2Latitude = 21.421923;
      double user2Longitude = 39.826447;

      double distance = calculateHaversineDistance(
        position.latitude,
        position.longitude,
        user2Latitude,
        user2Longitude,
      );

      // Calculate a midpoint along the road between your location and user 2's location
      double midPointLatitude = (position.latitude + user2Latitude) / 2;
      double midPointLongitude = (position.longitude + user2Longitude) / 2;

      // Update the map camera to center around the midpoint and zoom in.
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(midPointLatitude,
              midPointLongitude), // Use midpoint as the target
          16.0, // Zoom level
        ),
      );

      // Add a line between your location and user 2's location
      mapController?.addLine(
        LineOptions(
          geometry: [
            LatLng(position.latitude, position.longitude),
            LatLng(user2Latitude, user2Longitude),
          ],
          lineJoin: "round",
          lineColor: "#478395", // Line color (red)
          lineWidth: 4.0, // Line width
        ),
      );

      // Add symbols for both your location and user 2's location
      mapController?.addSymbols([
        SymbolOptions(
          geometry: LatLng(position.latitude, position.longitude),
          iconImage: 'assets/images/one.png', // Your icon asset
          iconSize: 0.3, // Adjust the icon size as needed
        ),
        SymbolOptions(
          geometry: LatLng(user2Latitude, user2Longitude),
          iconImage: 'assets/images/two.png', // User 2's icon asset
          iconSize: 0.3, // Adjust the icon size as needed
        ),
      ]);

      // Display the distance between your location and user 2's location
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Distance to User 2: ${distance.toStringAsFixed(2)} km'),
        ),
      );
    } catch (e) {
      // Handle any errors that may occur when getting the location.
      print(e.toString());
    }
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
              zoom: 14.0, // Adjust the initial zoom level as needed.
            ),
          ),
          Positioned(
            top: 80.0,
            left: 16.0,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Iconsax.arrow_left_2,
                color: ColorSys.darkBlue,
                size: 30.0,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          child: const Icon(
            Iconsax.location,
            color: ColorSys.darkBlue,
          ),
          onPressed: () => _getUserLocation(),
        ),
      ),
    );
  }
}
