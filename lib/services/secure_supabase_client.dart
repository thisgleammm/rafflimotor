import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:developer' as developer;

class SecureSupabaseClient {
  static SupabaseClient get instance => Supabase.instance.client;

  static Future<T> safeQuery<T>(
    Future<T> Function() query, {
    String? operationName,
  }) async {
    try {
      final result = await query();
      return result;
    } catch (error) {
      if (operationName != null) {
        developer.log(
          'Database operation failed: $operationName',
          name: 'SecureSupabaseClient',
          error: 'Operation failed',
        );
      }
      rethrow;
    }
  }

  // Method untuk hash password
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<Map<String, dynamic>?> loginUser({
    required String username,
    required String password,
  }) async {
    return await safeQuery(() async {
      String hashedPassword = _hashPassword(password);

      final response = await instance
          .from('user')
          .select('username, created_at, updated_at')
          .eq('username', username)
          .eq('password', hashedPassword)
          .maybeSingle();
      return response;
    }, operationName: 'user_login');
  }

  // Method untuk query lainnya jika diperlukan
  static Future<List<Map<String, dynamic>>> getUsers() async {
    return await safeQuery(() async {
      final response = await instance.from('user').select('*');
      return response;
    }, operationName: 'get_users');
  }
}
