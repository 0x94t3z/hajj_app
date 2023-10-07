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

    final double lat1Rad = degreesToRadians(lat1);
    final double lon1Rad = degreesToRadians(lon1);
    final double lat2Rad = degreesToRadians(lat2);
    final double lon2Rad = degreesToRadians(lon2);

    final double dlon = lon2Rad - lon1Rad;
    final double dlat = lat2Rad - lat1Rad;
    final double a = math.pow(math.sin(dlat / 2), 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) * math.pow(math.sin(dlon / 2), 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double user2Latitude = 21.421923;
      double user2Longitude = 39.826447;

      double distance = calculateHaversineDistance(
        position.latitude,
        position.longitude,
        user2Latitude,
        user2Longitude,
      );

      double midPointLatitude = (position.latitude + user2Latitude) / 2;
      double midPointLongitude = (position.longitude + user2Longitude) / 2;

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(midPointLatitude, midPointLongitude),
          16.0,
        ),
      );

      mapController?.addLine(
        LineOptions(
          geometry: [
            LatLng(position.latitude, position.longitude),
            LatLng(user2Latitude, user2Longitude),
          ],
          lineJoin: "round",
          lineColor: "#478395",
          lineWidth: 4.0,
        ),
      );

      mapController?.addSymbols([
        SymbolOptions(
          geometry: LatLng(position.latitude, position.longitude),
          iconImage: 'assets/images/one.png',
          iconSize: 0.3,
        ),
        SymbolOptions(
          geometry: LatLng(user2Latitude, user2Longitude),
          iconImage: 'assets/images/two.png',
          iconSize: 0.3,
        ),
      ]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Distance to User 2: ${distance.toStringAsFixed(2)} km'),
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Widget buildUserList({
    required String name,
    required String distance,
    required String duration,
    required Color backgroundColor,
    required Color buttonColor,
    required String buttonText,
    required IconData buttonIcon,
  }) {
    return Container(
      width: 390.0,
      height: 180.0,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: backgroundColor,
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
                        height: 130.0,
                        width: 120.0,
                        child: Image.network(
                          'https://avatars.githubusercontent.com/u/52822242?v=4',
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
                    name,
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
                        distance,
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
                        duration,
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
                        onPressed: () {},
                        icon: const Center(
                          child: Icon(Iconsax.direct_up),
                        ),
                        label: Text(buttonText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
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
      body: Column(
        children: [
          Expanded(
            child: Stack(
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
                  top: 80.0,
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
              ],
            ),
          ),
          // Wrap the Positioned widget and its child in a Stack
          Stack(
            children: [
              Container(
                height: 220.0,
                color: Colors.transparent,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    buildUserList(
                      name: 'Muhamad Taopik',
                      distance: '1 Km',
                      duration: '10 Min',
                      backgroundColor: Colors.white,
                      buttonColor: ColorSys.darkBlue,
                      buttonText: 'Go',
                      buttonIcon: Iconsax.direct_up,
                    ),
                    const SizedBox(width: 20.0),
                    buildUserList(
                      name: 'Imam Firdaus',
                      distance: '2 Km',
                      duration: '15 Min',
                      backgroundColor: Colors.white,
                      buttonColor: ColorSys.darkBlue,
                      buttonText: 'Go',
                      buttonIcon: Iconsax.direct_up,
                    ),
                    const SizedBox(width: 20.0),
                    buildUserList(
                      name: 'Ilham Fadlulrohman',
                      distance: '3 Km',
                      duration: '20 Min',
                      backgroundColor: Colors.white,
                      buttonColor: ColorSys.darkBlue,
                      buttonText: 'Go',
                      buttonIcon: Iconsax.direct_up,
                    ),
                  ],
                ),
              ),
            ],
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
