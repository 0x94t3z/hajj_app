import 'package:flutter_dotenv/flutter_dotenv.dart';

class DotEnvConfig {
  static Future<void> configure() async {
    await dotenv.load();
  }

  static String get mapboxPublicKey => dotenv.env['MAPBOX_PUBLIC_KEY'] ?? '';
  static String get mapboxSecretKey => dotenv.env['MAPBOX_SECRET_KEY'] ?? '';
}
