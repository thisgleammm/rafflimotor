import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raffli_motor/services/api_service.dart';

/// AuthService menggunakan REST API backend
class AuthService {
  static const String _usernameKey = 'auth_username';
  static const String _sessionTokenKey = 'auth_session_token';
  static const String _loginTimeKey = 'auth_login_time';

  final ApiService _apiService = ApiService();

  /// Login user via REST API
  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/auth/login',
        body: {'username': username, 'password': password},
        withAuth: false, // Login tidak perlu auth header
      );

      if (response['success'] != true) {
        debugPrint('❌ Login failed: ${response['error']}');
        return null;
      }

      final data = response['data'] as Map<String, dynamic>;
      final sessionToken = data['session_token'] as String;
      final loginTime = DateTime.now();

      // Simpan session token ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, data['username']);
      await prefs.setString(_sessionTokenKey, sessionToken);
      await prefs.setInt(_loginTimeKey, loginTime.millisecondsSinceEpoch);

      // Simpan juga di ApiService untuk requests berikutnya
      await _apiService.saveSessionToken(sessionToken);

      debugPrint('✅ Login successful for: ${data['username']}');
      return {
        'username': data['username'],
        'fullname': data['fullname'],
        'role_id': data['role_id'],
      };
    } catch (e) {
      debugPrint('❌ Login error: $e');
      rethrow;
    }
  }

  /// Validasi session dengan REST API
  Future<bool> validateSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString(_sessionTokenKey);

      if (sessionToken == null) {
        debugPrint('⚠️ No session found');
        return false;
      }

      // Pastikan ApiService punya token
      await _apiService.saveSessionToken(sessionToken);

      final response = await _apiService.get('/api/auth/validate');

      if (response['success'] != true) {
        debugPrint('⚠️ Session invalid: ${response['error']}');
        await clearSession();
        return false;
      }

      debugPrint('✅ Session valid');
      return true;
    } catch (e) {
      debugPrint('❌ Session validation error: $e');
      return false;
    }
  }

  /// Get current user info from valid session
  Future<Map<String, String>?> getCurrentUser() async {
    final isValid = await validateSession();
    if (!isValid) return null;

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_usernameKey);
    if (username == null) return null;

    return {'username': username};
  }

  /// Logout via REST API
  Future<void> logout() async {
    try {
      // Call logout API
      await _apiService.post('/api/auth/logout');

      // Clear local session
      await clearSession();
      debugPrint('✅ Logout successful');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      await clearSession(); // Clear local anyway
    }
  }

  /// Clear local session data
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_loginTimeKey);
    await _apiService.clearSessionToken();
  }

  /// Get current username without validation
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }
}
