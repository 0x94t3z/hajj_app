import 'package:hajj_app/screens/features/finding/haversine_algorithm.dart';

const double maxNearbyOfficerDistanceKm = 25.0;
const double maxNavigationDistanceKm = 30.0;
const double offroadConnectorThresholdMeters = 25.0;

const String supportedOperationAreaLabel =
    'Makkah dan UIN Sunan Gunung Djati Bandung';

class OperationZone {
  final String name;
  final double centerLatitude;
  final double centerLongitude;
  final double radiusKm;

  const OperationZone({
    required this.name,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radiusKm,
  });
}

const OperationZone makkahOperationZone = OperationZone(
  name: 'Makkah',
  centerLatitude: 21.422487,
  centerLongitude: 39.826206,
  radiusKm: 35.0,
);

const OperationZone uinSgdBandungOperationZone = OperationZone(
  name: 'UIN Sunan Gunung Djati Bandung',
  centerLatitude: -6.9318,
  centerLongitude: 107.7176,
  radiusKm: 15.0,
);

const List<OperationZone> supportedOperationZones = <OperationZone>[
  makkahOperationZone,
  uinSgdBandungOperationZone,
];

double _distanceToZoneCenterKm(
  double latitude,
  double longitude,
  OperationZone zone,
) {
  return calculateHaversineDistance(
    latitude,
    longitude,
    zone.centerLatitude,
    zone.centerLongitude,
  );
}

OperationZone? findContainingOperationZone(double latitude, double longitude) {
  for (final zone in supportedOperationZones) {
    if (_distanceToZoneCenterKm(latitude, longitude, zone) <= zone.radiusKm) {
      return zone;
    }
  }
  return null;
}

double distanceToNearestOperationZoneKm(double latitude, double longitude) {
  if (supportedOperationZones.isEmpty) {
    return double.infinity;
  }
  var nearest = double.infinity;
  for (final zone in supportedOperationZones) {
    final distance = _distanceToZoneCenterKm(latitude, longitude, zone);
    if (distance < nearest) {
      nearest = distance;
    }
  }
  return nearest;
}

bool isInsideSupportedOperationArea(double latitude, double longitude) {
  return findContainingOperationZone(latitude, longitude) != null;
}

bool isInsideMakkahOperationArea(double latitude, double longitude) {
  return isInsideSupportedOperationArea(latitude, longitude);
}
