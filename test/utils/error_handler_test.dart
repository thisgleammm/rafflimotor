import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:raffli_motor/utils/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    group('getReadableError', () {
      test('should return network error message for SocketException', () {
        // Arrange
        final error = const SocketException('Failed host lookup');

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(
          result,
          'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
        );
      });

      test('should return format error message for FormatException', () {
        // Arrange
        final error = const FormatException('Invalid JSON');

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(
          result,
          'Terjadi kesalahan dalam memproses data. Silakan coba lagi.',
        );
      });

      test('should return timeout error message for timeout errors', () {
        // Arrange
        final error = Exception('Connection timeout');

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(
          result,
          'Koneksi timeout. Periksa koneksi internet Anda dan coba lagi.',
        );
      });

      test('should return auth error for unauthorized (401)', () {
        // Arrange
        // '401' alone is not sensitive, so it triggers the auth error check
        final error = Exception('Error 401');

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(result, 'Username atau password salah.');
      });

      test('should return invalid data error for 400 status', () {
        // Arrange
        final error = Exception('Error 400 bad request');

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(result, 'Data yang dimasukkan tidak valid.');
      });

      test('should return access denied error for 403 status', () {
        // Arrange
        final error = Exception('Error 403 forbidden');

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(result, 'Akses ditolak.');
      });

      test('should return not found error for 404 status', () {
        // Arrange
        final error = Exception('Error 404 not found');

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(result, 'Server tidak dapat ditemukan.');
      });

      test('should return server error for 500 status', () {
        // Arrange
        final error = Exception('Error 500 internal server error');

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(result, 'Server sedang bermasalah. Silakan coba lagi nanti.');
      });

      test('should return server error for 502 status', () {
        // Arrange
        final error = Exception('Error 502 bad gateway');

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(result, 'Server sedang bermasalah. Silakan coba lagi nanti.');
      });

      test('should return server error for 503 status', () {
        // Arrange
        final error = Exception('Error 503 service unavailable');

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(result, 'Server sedang bermasalah. Silakan coba lagi nanti.');
      });

      test('should mask sensitive information containing supabase', () {
        // Arrange
        final error = Exception(
          'Error connecting to supabase.co: connection refused',
        );

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(
          result,
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda dan coba lagi.',
        );
      });

      test('should mask sensitive information containing API keys', () {
        // Arrange
        final error = Exception(
          'Invalid API key: eyJhbGciOiJIUzI1NiIsInR5cCI6',
        );

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(result, 'Terjadi kesalahan sistem. Silakan coba lagi nanti.');
      });

      test('should mask sensitive information containing database terms', () {
        // Arrange
        final error = Exception('PostgreSQL database connection failed');

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        // 'postgresql' and 'database' are sensitive, but 'connection' triggers network check
        expect(
          result,
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda dan coba lagi.',
        );
      });

      test('should mask sensitive information containing URLs', () {
        // Arrange
        final error = Exception('Error at https://api.example.com/endpoint');

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(result, 'Terjadi kesalahan sistem. Silakan coba lagi nanti.');
      });

      test('should return network error for connection-related errors', () {
        // Arrange
        final error = Exception('Network connection failed');

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(
          result,
          'Masalah koneksi jaringan. Periksa koneksi internet Anda.',
        );
      });

      test('should return generic error for unknown errors', () {
        // Arrange
        final error = Exception('Some random error');

        // Act
        final result = ErrorHandler.getReadableError(error);

        // Assert
        expect(result, 'Terjadi kesalahan. Silakan coba lagi.');
      });
    });

    group('isNetworkError', () {
      test('should return true for SocketException', () {
        // Arrange
        final error = const SocketException('No internet');

        // Act
        final result = ErrorHandler.isNetworkError(error);

        // Assert
        expect(result, true);
      });

      test('should return true for network-related error strings', () {
        // Arrange
        final error = Exception('Network connection failed');

        // Act
        final result = ErrorHandler.isNetworkError(error);

        // Assert
        expect(result, true);
      });

      test('should return true for connection errors', () {
        // Arrange
        final error = Exception('Connection refused');

        // Act
        final result = ErrorHandler.isNetworkError(error);

        // Assert
        expect(result, true);
      });

      test('should return true for timeout errors', () {
        // Arrange
        final error = Exception('Request timeout');

        // Act
        final result = ErrorHandler.isNetworkError(error);

        // Assert
        expect(result, true);
      });

      test('should return true for failed host lookup', () {
        // Arrange
        final error = Exception('Failed host lookup');

        // Act
        final result = ErrorHandler.isNetworkError(error);

        // Assert
        expect(result, true);
      });

      test('should return false for non-network errors', () {
        // Arrange
        final error = Exception('Invalid data format');

        // Act
        final result = ErrorHandler.isNetworkError(error);

        // Assert
        expect(result, false);
      });

      test('should return false for authentication errors', () {
        // Arrange
        final error = Exception('Unauthorized access');

        // Act
        final result = ErrorHandler.isNetworkError(error);

        // Assert
        expect(result, false);
      });
    });
  });
}
