import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// AuthService dengan session token untuk keamanan lebih tinggi
/// Session token disimpan di client dan server untuk validasi
class AuthService {
  static const String _usernameKey = 'auth_username';
  static const String _sessionTokenKey = 'auth_session_token';
  static const String _loginTimeKey = 'auth_login_time';
  static const int _sessionDurationDays = 7;

  final SupabaseClient _supabase = Supabase.instance.client;

  // Generate secure random session token
  static String _generateSessionToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  // Hash password dengan SHA-256
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Get device info untuk tracking
  Future<String> _getDeviceInfo() async {
    if (kIsWeb) {
      return 'Web Browser';
    } else if (Platform.isAndroid) {
      return 'Android Device';
    } else if (Platform.isIOS) {
      return 'iOS Device';
    } else if (Platform.isMacOS) {
      return 'macOS Device';
    } else if (Platform.isWindows) {
      return 'Windows Device';
    } else {
      return 'Unknown Device';
    }
  }

  /// Login user dengan validasi dan generate session token
  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    try {
      // Hash password
      final hashedPassword = _hashPassword(password);

      // Validasi credentials dengan database
      final userResponse = await _supabase
          .from('user')
          .select('username, fullname, role_id')
          .eq('username', username)
          .eq('password', hashedPassword)
          .maybeSingle();

      if (userResponse == null) {
        return null; // Invalid credentials
      }

      // Generate session token
      final sessionToken = _generateSessionToken();
      final loginTime = DateTime.now();
      final deviceInfo = await _getDeviceInfo();

      // Simpan session ke database untuk validasi server-side
      await _supabase.from('user_sessions').insert({
        'username': username,
        'session_token': sessionToken,
        'login_time': loginTime.toIso8601String(),
        'expires_at': loginTime
            .add(Duration(days: _sessionDurationDays))
            .toIso8601String(),
        'device_info': deviceInfo,
      });

      // Simpan session token ke local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);
      await prefs.setString(_sessionTokenKey, sessionToken);
      await prefs.setInt(_loginTimeKey, loginTime.millisecondsSinceEpoch);

      debugPrint('✅ Login successful for: $username');
      return {
        'username': userResponse['username'],
        'fullname': userResponse['fullname'],
        'role_id': userResponse['role_id'],
      };
    } catch (e) {
      debugPrint('❌ Login error: $e');
      rethrow;
    }
  }

  /// Validasi session dengan server (middleware-like validation)
  Future<bool> validateSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString(_usernameKey);
      final sessionToken = prefs.getString(_sessionTokenKey);
      final loginTime = prefs.getInt(_loginTimeKey);

      if (username == null || sessionToken == null || loginTime == null) {
        debugPrint('⚠️ No session found');
        return false;
      }

      // Cek expiry di client-side terlebih dahulu
      final now = DateTime.now();
      final loginDateTime = DateTime.fromMillisecondsSinceEpoch(loginTime);
      final difference = now.difference(loginDateTime).inDays;

      if (difference > _sessionDurationDays) {
        debugPrint('⚠️ Session expired (client-side check)');
        await clearSession();
        return false;
      }

      // Validasi session token dengan database (server-side validation)
      final sessionResponse = await _supabase
          .from('user_sessions')
          .select('expires_at, is_active')
          .eq('username', username)
          .eq('session_token', sessionToken)
          .eq('is_active', true)
          .maybeSingle();

      if (sessionResponse == null) {
        debugPrint('⚠️ Invalid session token');
        await clearSession();
        return false;
      }

      // Cek apakah session sudah expired di server
      final expiresAt = DateTime.parse(sessionResponse['expires_at']);
      if (now.isAfter(expiresAt)) {
        debugPrint('⚠️ Session expired (server-side check)');
        await invalidateSession(username, sessionToken);
        await clearSession();
        return false;
      }

      // Update last activity
      await _supabase
          .from('user_sessions')
          .update({'last_activity': now.toIso8601String()})
          .eq('username', username)
          .eq('session_token', sessionToken);

      debugPrint('✅ Session valid for: $username');
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

  /// Logout dan invalidate session di server
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString(_usernameKey);
      final sessionToken = prefs.getString(_sessionTokenKey);

      if (username != null && sessionToken != null) {
        // Invalidate session di server
        await invalidateSession(username, sessionToken);
      }

      // Clear local session
      await clearSession();
      debugPrint('✅ Logout successful');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      await clearSession(); // Clear local anyway
    }
  }

  /// Invalidate session di database
  Future<void> invalidateSession(String username, String sessionToken) async {
    try {
      await _supabase
          .from('user_sessions')
          .update({
            'is_active': false,
            'invalidated_at': DateTime.now().toIso8601String(),
          })
          .eq('username', username)
          .eq('session_token', sessionToken);
    } catch (e) {
      debugPrint('❌ Error invalidating session: $e');
    }
  }

  /// Clear local session data
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_loginTimeKey);
  }

  /// Invalidate all sessions for a user (logout from all devices)
  Future<void> logoutAllDevices(String username) async {
    try {
      await _supabase
          .from('user_sessions')
          .update({
            'is_active': false,
            'invalidated_at': DateTime.now().toIso8601String(),
          })
          .eq('username', username)
          .eq('is_active', true);
      debugPrint('✅ All sessions invalidated for: $username');
    } catch (e) {
      debugPrint('❌ Error invalidating all sessions: $e');
    }
  }

  /// Get current user ID
}
