import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MapboxRouteMetrics {
  const MapboxRouteMetrics({
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final double distanceMeters;
  final double durationSeconds;
}

class MapboxDirectionsService {
  const MapboxDirectionsService();

  Future<MapboxRouteMetrics?> fetchWalkingMetrics({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    if (!_isValidCoordinate(originLatitude, originLongitude) ||
        !_isValidCoordinate(destinationLatitude, destinationLongitude)) {
      return null;
    }

    final token = dotenv.env['MAPBOX_SECRET_KEY']?.trim() ?? '';
    if (token.isEmpty) return null;

    final uri = Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/walking/'
      '$originLongitude,$originLatitude;'
      '$destinationLongitude,$destinationLatitude',
    ).replace(
      queryParameters: {
        'alternatives': 'false',
        'continue_straight': 'true',
        'geometries': 'geojson',
        'overview': 'simplified',
        'steps': 'false',
        'language': 'id',
        'voice_units': 'metric',
        'access_token': token,
      },
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final routes = decoded['routes'];
      if (routes is! List || routes.isEmpty || routes.first is! Map) {
        return null;
      }

      final route = Map<String, dynamic>.from(routes.first as Map);
      final distance = (route['distance'] as num?)?.toDouble() ?? 0;
      final duration = (route['duration'] as num?)?.toDouble() ?? 0;
      if (distance <= 0 || duration <= 0) return null;

      return MapboxRouteMetrics(
        distanceMeters: distance,
        durationSeconds: duration,
      );
    } catch (_) {
      return null;
    }
  }

  bool _isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        (latitude != 0 || longitude != 0);
  }
}
