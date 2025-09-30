import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _usernameKey = 'logged_in_username';
  static const String _loginTimeKey = 'login_time';
  static const int _sessionDurationDays = 7; // Session berlaku 7 hari

  // Simpan session setelah login berhasil
  static Future<void> saveSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    await prefs.setInt(_loginTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Cek apakah user sudah login dan session masih valid
  static Future<String?> getValidSession() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_usernameKey);
    final loginTime = prefs.getInt(_loginTimeKey);

    if (username == null || loginTime == null) {
      return null; // Belum pernah login
    }

    final now = DateTime.now();
    final loginDateTime = DateTime.fromMillisecondsSinceEpoch(loginTime);
    final difference = now.difference(loginDateTime).inDays;

    if (difference > _sessionDurationDays) {
      // Session expired, hapus session
      await clearSession();
      return null;
    }

    return username; // Session valid
  }

  // Hapus session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_loginTimeKey);
  }

  // Cek apakah ada session aktif (tanpa validasi waktu)
  static Future<bool> hasActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_usernameKey);
  }
}
