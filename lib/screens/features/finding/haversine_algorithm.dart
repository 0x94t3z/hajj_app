import 'dart:math' as math;

double calculateHaversineDistance(
    double lat1, double lon1, double lat2, double lon2) {
  const double radiusOfEarth = 6371; // Earth's radius in kilometers
  const double degreesToRadians = math.pi / 180.0;

  // Convert latitude and longitude from degrees to radians
  final double lat1Rad = lat1 * degreesToRadians;
  final double lon1Rad = lon1 * degreesToRadians;
  final double lat2Rad = lat2 * degreesToRadians;
  final double lon2Rad = lon2 * degreesToRadians;

  // Haversine formula
  final double dLat = lat2Rad - lat1Rad;
  final double dLon = lon2Rad - lon1Rad;
  final double a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
      (math.cos(lat1Rad) *
          math.cos(lat2Rad) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2));
  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  // Calculate the distance
  final double distance = radiusOfEarth * c;
  return distance;
}
