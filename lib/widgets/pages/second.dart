import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';
// import 'package:permission_handler/permission_handler.dart';

class SecondWidget extends StatefulWidget {
  const SecondWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SecondWidgetState createState() => _SecondWidgetState();
}

class _SecondWidgetState extends State<SecondWidget> {
  MapboxMap? mapboxMap;
  final double _puckScale = 1.0;

  @override
  void initState() {
    super.initState();
  }

  _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
  }

  // Future<void> _getUserLocation() async {
  //   try {
  //     var position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );

  //     // Update the map camera to center around the user's location and zoom in.
  // mapboxMap?.flyTo(
  //     // CameraUpdate.newLatLngZoom(
  //     //   LatLng(position.latitude, position.longitude),
  //     //   16.0,
  //     // ),
  //     CameraOptions(
  //         anchor:
  //             ScreenCoordinate(x: position.latitude, y: position.longitude),
  //         zoom: 17,
  //         bearing: 180,
  //         pitch: 30),
  //     MapAnimationOptions(duration: 2000, startDelay: 0));
  //   } catch (e) {
  //     // Handle any errors that may occur when getting the location.
  //     print(e.toString());
  //   }
  // }

  // Widget _getPermission() {
  //   return TextButton(
  //     child: const Text('get location permission'),
  //     onPressed: () async {
  //       var status = await Permission.locationWhenInUse.request();
  //       print("Location granted : $status");
  //     },
  //   );
  // }

  Widget _switchLocationPuck3D() {
    return TextButton(
      child: const Text('switch to 3d puck'),
      onPressed: () {
        mapboxMap?.location.updateSettings(LocationComponentSettings(
            locationPuck: LocationPuck(
                locationPuck3D: LocationPuck3D(
                    modelUri:
                        "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Embedded/Duck.gltf",
                    modelScale: [_puckScale, _puckScale, _puckScale]))));
      },
    );
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
          onPressed: () => _switchLocationPuck3D(),
        ),
      ),
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        resourceOptions: ResourceOptions(
          accessToken: dotenv.env['MAPBOX_SECRET_KEY'] ?? '',
        ),

        onMapCreated: _onMapCreated,
        cameraOptions: CameraOptions(
            center: Point(coordinates: Position(21.42664, 39.82563)).toJson(),
            zoom: 12.0),

        // body: MapboxMap(
        //   styleString: MapboxStyles.MAPBOX_STREETS,
        //   accessToken: dotenv.env['MAPBOX_SECRET_KEY'],
        //   onMapCreated: _onMapCreated,
        //   myLocationRenderMode: MyLocationRenderMode.NORMAL,
        //   myLocationEnabled: true,
        //   myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
        //   initialCameraPosition: const CameraPosition(
        //     target: LatLng(21.42664, 39.82563),
        //     zoom: 14.0, // Adjust the initial zoom level as needed.
        //   ),
      ),
    );
  }
}
