import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geocoding/geocoding.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapboxMapController? mapController;
  LatLng? currentLocation; // Current location coordinates
  LatLng?
      destinationPoint; // Destination coordinates will be obtained from geocoding

  @override
  void initState() {
    super.initState();
    _geocodeDestination(
        "Your Destination Address"); // Replace with the actual address
  }

  // Geocode the destination address to obtain coordinates
  Future<void> _geocodeDestination(String destinationAddress) async {
    try {
      List<Location> locations = await locationFromAddress(destinationAddress);
      if (locations.isNotEmpty) {
        destinationPoint =
            LatLng(locations[0].latitude, locations[0].longitude);
        // Update the widget with the destination coordinates
        setState(() {
          _getLocation();
        });
      }
    } catch (e) {
      print("Geocoding Error: $e");
    }
  }

  // Get the user's current location
  Future<void> _getLocation() async {
    try {
      // You can use a location package or other methods to get the current location
      // For this example, let's use coordinates close to the destination
      currentLocation = LatLng(21.42, 39.82);
      addRouteLine();
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken:
          "REDACTED",
      onMapCreated: (controller) {
        mapController = controller;
        // Add your route line here
        addRouteLine();
      },
      initialCameraPosition: CameraPosition(
        target: currentLocation ?? LatLng(21.42, 39.82), // Fallback coordinates
        zoom: 14.0,
      ),
    );
  }

  // Your addRouteLine function
  void addRouteLine() {
    if (mapController != null &&
        destinationPoint != null &&
        currentLocation != null) {
      mapController!.addLine(
        LineOptions(
          geometry: [currentLocation!, destinationPoint!],
          lineColor: "#478395",
          lineWidth: 4.0,
        ),
      );
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
