import 'dart:math' as math;

double calculateHaversineDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  // Mean Earth radius (IUGG), in kilometers.
  const double radiusOfEarth = 6371.0088;
  const double degreesToRadians = math.pi / 180.0;

  // Convert latitude and longitude from degrees to radians
  final double lat1Rad = lat1 * degreesToRadians;
  final double lat2Rad = lat2 * degreesToRadians;

  // Haversine formula
  final double dLat = lat2Rad - lat1Rad;
  final double dLon = (lon2 - lon1) * degreesToRadians;
  final double sinHalfDLat = math.sin(dLat / 2);
  final double sinHalfDLon = math.sin(dLon / 2);
  final double a = (sinHalfDLat * sinHalfDLat) +
      (math.cos(lat1Rad) *
          math.cos(lat2Rad) *
          sinHalfDLon *
          sinHalfDLon);

  // Clamp to avoid NaN from tiny floating-point drift outside [0, 1].
  final double normalizedA = a.clamp(0.0, 1.0).toDouble();
  final double c =
      2 * math.atan2(math.sqrt(normalizedA), math.sqrt(1 - normalizedA));

  // Calculate the distance
  final double distance = radiusOfEarth * c;
  return distance;
}
