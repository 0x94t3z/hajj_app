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
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          lineColor: "#478395",
          lineWidth: 4.0,
        ),
      );

      // Add symbols for both your location and user 2's location
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

  Widget buildUserList({
    required String name,
    required String distance,
    required String duration,
    required Color backgroundColor,
    required Color buttonColor,
    required String buttonText,
    required IconData buttonIcon,
    required String imageUrl,
  }) {
    return Container(
      width: 390.0,
      height: 200.0,
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
                        height: 122.0,
                        width: 120.0,
                        child: Image.network(
                          imageUrl,
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
                      children: [
                        buildUserList(
                          name: 'Muhamad Taopik',
                          distance: '1 Km',
                          duration: '10 Min',
                          backgroundColor: Colors.white,
                          buttonColor: ColorSys.darkBlue,
                          buttonText: 'Go',
                          buttonIcon: Iconsax.direct_up,
                          imageUrl:
                              'https://avatars.githubusercontent.com/u/52822242?v=4',
                        ),
                        buildUserList(
                          name: 'Imam Firdaus',
                          distance: '2 Km',
                          duration: '15 Min',
                          backgroundColor: Colors.white,
                          buttonColor: ColorSys.darkBlue,
                          buttonText: 'Go',
                          buttonIcon: Iconsax.direct_up,
                          imageUrl:
                              'https://instagram.fbdo9-1.fna.fbcdn.net/v/t51.2885-19/372516336_247370194944369_1994460987512356006_n.jpg?stp=dst-jpg_s320x320&_nc_ht=instagram.fbdo9-1.fna.fbcdn.net&_nc_cat=109&_nc_ohc=FMhK5B7lz6QAX9plV9J&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfDQML2pJ6DisAy1zPvlJsklJESbVtaGb2wpLAr5Cm9DRw&oe=65266515&_nc_sid=8b3546',
                        ),
                        buildUserList(
                          name: 'Ilham Fadhlurahman',
                          distance: '3 Km',
                          duration: '20 Min',
                          backgroundColor: Colors.white,
                          buttonColor: ColorSys.darkBlue,
                          buttonText: 'Go',
                          buttonIcon: Iconsax.direct_up,
                          imageUrl:
                              'https://instagram.fbdo9-1.fna.fbcdn.net/v/t51.2885-19/330850473_752285232911741_8289984473251204414_n.jpg?stp=dst-jpg_s320x320&_nc_ht=instagram.fbdo9-1.fna.fbcdn.net&_nc_cat=105&_nc_ohc=5ybP9VVm-cIAX_Z9zcK&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfB-JN4IJ-KJWuCHmcVtgXureVeR4oV7rDV_dqU5m1Glpg&oe=65278491&_nc_sid=8b3546',
                        ),
                        buildUserList(
                          name: 'Ikhsan Khoreul',
                          distance: '4 Km',
                          duration: '25 Min',
                          backgroundColor: Colors.white,
                          buttonColor: ColorSys.darkBlue,
                          buttonText: 'Go',
                          buttonIcon: Iconsax.direct_up,
                          imageUrl:
                              'https://scontent-cgk1-1.cdninstagram.com/v/t51.2885-19/44884218_345707102882519_2446069589734326272_n.jpg?_nc_ht=scontent-cgk1-1.cdninstagram.com&_nc_cat=1&_nc_ohc=tzrtV3LSSLgAX9s5ATd&edm=AAAAAAABAAAA&ccb=7-5&ig_cache_key=YW5vbnltb3VzX3Byb2ZpbGVfcGlj.2-ccb7-5&oh=00_AfDC0LgGAC__SAo1PYoPWVDSp9LqAGLsLQjk5VBKqtWs-Q&oe=6526050F&_nc_sid=000000',
                        ),
                        buildUserList(
                          name: 'Fauzan',
                          distance: '5 Km',
                          duration: '30 Min',
                          backgroundColor: Colors.white,
                          buttonColor: ColorSys.darkBlue,
                          buttonText: 'Go',
                          buttonIcon: Iconsax.direct_up,
                          imageUrl:
                              'https://instagram.fbdo9-1.fna.fbcdn.net/v/t51.2885-19/15625170_561345284073104_1985069073154703360_a.jpg?stp=dst-jpg_s320x320&_nc_ht=instagram.fbdo9-1.fna.fbcdn.net&_nc_cat=108&_nc_ohc=USGF8GztAHoAX-I0NpE&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AfAiegGSNwqaKYjWQAJFdbPleJZAMpAdvltnwoa7BA193A&oe=652754C6&_nc_sid=8b3546',
                        ),
                      ],
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
