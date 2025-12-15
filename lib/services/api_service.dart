import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:raffli_motor/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API Service untuk komunikasi dengan REST API backend
class ApiService {
  static const String _sessionTokenKey = 'auth_session_token';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Get session token dari SharedPreferences
  Future<String?> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionTokenKey);
  }

  /// Save session token ke SharedPreferences
  Future<void> saveSessionToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionTokenKey, token);
  }

  /// Clear session token
  Future<void> clearSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionTokenKey);
  }

  /// Build headers dengan authorization
  Future<Map<String, String>> _buildHeaders({bool withAuth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (withAuth) {
      final token = await getSessionToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Generic GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool withAuth = true,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.endpoint(endpoint));
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _buildHeaders(withAuth: withAuth);
      final response = await http.get(uri, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('API GET Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.endpoint(endpoint));
      final headers = await _buildHeaders(withAuth: withAuth);

      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('API POST Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.endpoint(endpoint));
      final headers = await _buildHeaders(withAuth: withAuth);

      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('API PUT Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Generic DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool withAuth = true,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.endpoint(endpoint));
      final headers = await _buildHeaders(withAuth: withAuth);

      final response = await http.delete(uri, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('API DELETE Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    Uint8List fileBytes,
    String fileName, {
    String fieldName = 'file',
    String? mediaType, // e.g. 'application/pdf' or 'image/jpeg'
    bool withAuth = true,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.endpoint(endpoint));
      final request = http.MultipartRequest('POST', uri);

      if (withAuth) {
        final token = await getSessionToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      MediaType? contentType;
      if (mediaType != null && mediaType.contains('/')) {
        final parts = mediaType.split('/');
        if (parts.length == 2) {
          contentType = MediaType(parts[0], parts[1]);
        }
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          fileBytes,
          filename: fileName,
          contentType: contentType,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('API Upload Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Handle response dari API
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        debugPrint('API Error [${response.statusCode}]: ${body['error']}');
        return body;
      }
    } catch (e) {
      debugPrint('Response Parse Error: $e');
      return {
        'success': false,
        'error': 'Failed to parse response: ${response.body}',
      };
    }
  }
}
