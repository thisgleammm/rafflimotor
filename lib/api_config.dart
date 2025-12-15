import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL tidak ditemukan di file .env');
    }
    return url;
  }

  // Helper untuk mendapatkan full URL
  static String endpoint(String path) {
    return '$baseUrl$path';
  }
}
