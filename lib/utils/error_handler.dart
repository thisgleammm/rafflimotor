import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  // List kata-kata sensitif yang tidak boleh ditampilkan ke user
  static const List<String> _sensitiveWords = [
    'supabase',
    'database',
    'postgresql',
    'postgres',
    'api',
    'key',
    'token',
    'secret',
    'auth',
    'Bearer',
    'jwt',
    'https://',
    'http://',
    '.co',
    '.com',
    'eyJ', // JWT prefix
  ];

  static String getReadableError(dynamic error) {
    String errorString = error.toString().toLowerCase();

    // Cek apakah error mengandung informasi sensitif
    if (_containsSensitiveInfo(errorString)) {
      // Jika mengandung info sensitif, kembalikan error generic berdasarkan tipe
      if (_isNetworkRelated(errorString)) {
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda dan coba lagi.';
      } else {
        return 'Terjadi kesalahan sistem. Silakan coba lagi nanti.';
      }
    }

    // Cek jika error adalah SocketException (tidak ada internet)
    if (error is SocketException) {
      return 'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.';
    }

    // Cek jika error adalah FormatException (JSON parsing error)
    if (error is FormatException) {
      return 'Terjadi kesalahan dalam memproses data. Silakan coba lagi.';
    }

    // Cek jika error adalah TimeoutException
    if (errorString.contains('timeout')) {
      return 'Koneksi timeout. Periksa koneksi internet Anda dan coba lagi.';
    }

    // Cek jika error adalah Supabase error
    if (error is PostgrestException) {
      switch (error.code) {
        case 'PGRST116':
          return 'Username atau password salah.';
        case 'PGRST301':
          return 'Terjadi kesalahan pada server. Silakan coba lagi.';
        default:
          return 'Terjadi kesalahan pada sistem. Silakan coba lagi.';
      }
    }

    // Cek error network umum
    if (_isNetworkRelated(errorString)) {
      return 'Masalah koneksi jaringan. Periksa koneksi internet Anda.';
    }

    // Cek error authentication
    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Username atau password salah.';
    }

    // Cek error HTTP status codes
    if (errorString.contains('400')) {
      return 'Data yang dimasukkan tidak valid.';
    }

    if (errorString.contains('403')) {
      return 'Akses ditolak.';
    }

    if (errorString.contains('404')) {
      return 'Server tidak dapat ditemukan.';
    }

    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return 'Server sedang bermasalah. Silakan coba lagi nanti.';
    }

    // Untuk error lain yang tidak mengandung info sensitif
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  static bool isNetworkError(dynamic error) {
    String errorString = error.toString().toLowerCase();
    return error is SocketException || _isNetworkRelated(errorString);
  }

  static bool _isNetworkRelated(String errorString) {
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('no address associated') ||
        errorString.contains('unreachable') ||
        errorString.contains('refused') ||
        errorString.contains('socket');
  }

  static bool _containsSensitiveInfo(String errorString) {
    for (String sensitiveWord in _sensitiveWords) {
      if (errorString.contains(sensitiveWord.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
}
