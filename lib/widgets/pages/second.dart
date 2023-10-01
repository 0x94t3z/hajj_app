import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SecondWidget extends StatefulWidget {
  const SecondWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SecondWidgetState createState() => _SecondWidgetState();
}

class _SecondWidgetState extends State<SecondWidget> {
  MapboxMapController? mapController;
  Position? currentPosition;

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
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          16.0,
        ),
      );

      setState(() {
        currentPosition = position;
      });
    } catch (e) {
      // Handle any errors that may occur when getting the location.
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildMapWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapWidget() {
    return Container(
      height: 180.0,
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      borderRadius: BorderRadius.circular(20.0),
                      child: SizedBox(
                        height: 130.0,
                        width: 120.0,
                        child: MapboxMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(21.422627, 39.826115),
                            zoom: 14.0,
                          ),
                          accessToken: dotenv.env['MAPBOX_SECRET_KEY']!,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 8.0,
                right: 8.0,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  mini: true,
                  child: const Icon(
                    Iconsax.location,
                    color: ColorSys.darkBlue,
                  ),
                  onPressed: () => _getUserLocation(),
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
                    'Your Location',
                    style: textStyle(fontSize: 14, color: ColorSys.darkBlue),
                  ),
                  Text(
                    'Meca, Saudi Arabia',
                    style: textStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorSys.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      _getUserLocation();
                    },
                    icon: const Icon(Iconsax.radar_2),
                    label: const Text('Find Officers'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorSys.darkBlue,
                      textStyle: const TextStyle(fontSize: 14),
                      fixedSize: const Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
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
}
