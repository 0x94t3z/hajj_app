// ignore_for_file: avoid_print

import 'dart:math' as math;

const double earthRadiusKm = 6371.0088;
const double degreesToRadians = math.pi / 180.0;

double calculateHaversineDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  return calculateHaversineDetails(lat1, lon1, lat2, lon2).distanceKm;
}

HaversineCalculation calculateHaversineDetails(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  final double lat1Rad = lat1 * degreesToRadians;
  final double lat2Rad = lat2 * degreesToRadians;
  final double lon1Rad = lon1 * degreesToRadians;
  final double lon2Rad = lon2 * degreesToRadians;

  final double dLat = lat2Rad - lat1Rad;
  final double dLon = lon2Rad - lon1Rad;
  final double sinHalfDLat = math.sin(dLat / 2);
  final double sinHalfDLon = math.sin(dLon / 2);
  final double a = (sinHalfDLat * sinHalfDLat) +
      (math.cos(lat1Rad) * math.cos(lat2Rad) * sinHalfDLon * sinHalfDLon);

  final double normalizedA = a.clamp(0.0, 1.0).toDouble();
  final double c =
      2 * math.atan2(math.sqrt(normalizedA), math.sqrt(1 - normalizedA));
  final double distance = earthRadiusKm * c;

  return HaversineCalculation(
    lat1: lat1,
    lon1: lon1,
    lat2: lat2,
    lon2: lon2,
    lat1Rad: lat1Rad,
    lon1Rad: lon1Rad,
    lat2Rad: lat2Rad,
    lon2Rad: lon2Rad,
    deltaLatRad: dLat,
    deltaLonRad: dLon,
    sinHalfDeltaLat: sinHalfDLat,
    sinHalfDeltaLon: sinHalfDLon,
    a: a,
    normalizedA: normalizedA,
    c: c,
    distanceKm: distance,
  );
}

class HaversineCalculation {
  const HaversineCalculation({
    required this.lat1,
    required this.lon1,
    required this.lat2,
    required this.lon2,
    required this.lat1Rad,
    required this.lon1Rad,
    required this.lat2Rad,
    required this.lon2Rad,
    required this.deltaLatRad,
    required this.deltaLonRad,
    required this.sinHalfDeltaLat,
    required this.sinHalfDeltaLon,
    required this.a,
    required this.normalizedA,
    required this.c,
    required this.distanceKm,
  });

  final double lat1;
  final double lon1;
  final double lat2;
  final double lon2;
  final double lat1Rad;
  final double lon1Rad;
  final double lat2Rad;
  final double lon2Rad;
  final double deltaLatRad;
  final double deltaLonRad;
  final double sinHalfDeltaLat;
  final double sinHalfDeltaLon;
  final double a;
  final double normalizedA;
  final double c;
  final double distanceKm;

  double get distanceMeters => distanceKm * 1000;
}

void main(List<String> args) {
  if (args.length != 4) {
    _printUsage();
    return;
  }

  final values = args.map(double.tryParse).toList();
  if (values.any((value) => value == null)) {
    print('Input tidak valid. Pastikan semua koordinat berupa angka.');
    _printUsage();
    return;
  }

  final lat1 = values[0]!;
  final lon1 = values[1]!;
  final lat2 = values[2]!;
  final lon2 = values[3]!;

  if (!_isValidLatitude(lat1) || !_isValidLatitude(lat2)) {
    print('Latitude harus berada pada rentang -90 sampai 90.');
    return;
  }
  if (!_isValidLongitude(lon1) || !_isValidLongitude(lon2)) {
    print('Longitude harus berada pada rentang -180 sampai 180.');
    return;
  }

  final result = calculateHaversineDetails(lat1, lon1, lat2, lon2);
  _printCalculation(result);
}

bool _isValidLatitude(double value) => value >= -90 && value <= 90;

bool _isValidLongitude(double value) => value >= -180 && value <= 180;

void _printUsage() {
  print('Cara menjalankan:');
  print(
    'dart run lib/screens/features/finding/haversine_algorithm.dart '
    '<lat_jemaah> <lon_jemaah> <lat_petugas> <lon_petugas>',
  );
  print('');
  print('Contoh:');
  print(
    'dart run lib/screens/features/finding/haversine_algorithm.dart '
    '-6.935831 107.717567 -6.936215 107.718430',
  );
}

void _printCalculation(HaversineCalculation result) {
  print('=== Perhitungan Haversine Formula ===');
  print('');
  print('Input koordinat:');
  print('Jemaah  : lat=${result.lat1}, lon=${result.lon1}');
  print('Petugas : lat=${result.lat2}, lon=${result.lon2}');
  print('');
  print('Konstanta:');
  print('R = radius bumi = ${earthRadiusKm.toStringAsFixed(4)} km');
  print('');
  print('1. Konversi derajat ke radian');
  print('lat1 = ${result.lat1Rad.toStringAsFixed(10)} rad');
  print('lon1 = ${result.lon1Rad.toStringAsFixed(10)} rad');
  print('lat2 = ${result.lat2Rad.toStringAsFixed(10)} rad');
  print('lon2 = ${result.lon2Rad.toStringAsFixed(10)} rad');
  print('');
  print('2. Selisih koordinat');
  print('delta lat = ${result.deltaLatRad.toStringAsFixed(10)} rad');
  print('delta lon = ${result.deltaLonRad.toStringAsFixed(10)} rad');
  print('');
  print('3. Hitung nilai a');
  print(
    'a = sin^2(delta lat / 2) + cos(lat1) * cos(lat2) * '
    'sin^2(delta lon / 2)',
  );
  print(
    'sin(delta lat / 2) = '
    '${result.sinHalfDeltaLat.toStringAsFixed(10)}',
  );
  print(
    'sin(delta lon / 2) = '
    '${result.sinHalfDeltaLon.toStringAsFixed(10)}',
  );
  print('a = ${result.a.toStringAsFixed(12)}');
  print('a setelah clamp 0-1 = ${result.normalizedA.toStringAsFixed(12)}');
  print('');
  print('4. Hitung sudut pusat dan jarak');
  print('c = 2 * atan2(sqrt(a), sqrt(1-a))');
  print('c = ${result.c.toStringAsFixed(12)} rad');
  print('d = R * c');
  print('');
  print('Hasil:');
  print('Jarak = ${result.distanceKm.toStringAsFixed(6)} km');
  print('Jarak = ${result.distanceMeters.toStringAsFixed(2)} meter');
}
