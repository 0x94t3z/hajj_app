import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class SecondWidget extends StatefulWidget {
  const SecondWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SecondWidgetState createState() => _SecondWidgetState();
}

class _SecondWidgetState extends State<SecondWidget> {
  MapboxMapController? mapController;
  var isLight = true;

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update the map camera to center around the user's location.
      mapController?.animateCamera(CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ));
    } catch (e) {
      // Handle any errors that may occur when getting the location.
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(32.0),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          child: const Icon(
            Iconsax.location,
            color: ColorSys.darkBlue,
          ),
          onPressed: () => _getUserLocation(),
        ),
      ),
      body: MapboxMap(
        styleString: MapboxStyles.MAPBOX_STREETS,
        accessToken: dotenv.env['MAPBOX_SECRET_KEY'],
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(21.42664, 39.82563),
          zoom: 14.0, // Adjust the initial zoom level as needed.
        ),
      ),
    );
  }
}
