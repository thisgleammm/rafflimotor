import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:raffli_motor/services/api_service.dart';
import 'package:raffli_motor/services/config_service.dart';

/// StorageService menggunakan REST API backend sepenuhnya
class StorageService {
  final ApiService _apiService = ApiService();
  final ConfigService _configService = ConfigService();
  final String _defaultBucket = 'productimage_bucket';

  /// Mengunggah gambar ke backend REST API
  Future<String?> uploadImage(XFile image) async {
    try {
      final fileBytes = await image.readAsBytes();
      final webpBytes = await FlutterImageCompress.compressWithList(
        fileBytes,
        format: CompressFormat.webp,
        quality: 80,
      );
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.webp';

      final response = await _apiService.uploadFile(
        '/api/upload/product-image',
        webpBytes,
        fileName,
        mediaType: 'image/webp',
      );

      if (response['success'] != true) {
        debugPrint('Error uploading image: ${response['error']}');
        return null;
      }

      final data = response['data'] as Map<String, dynamic>;
      // Return file_name saja (bukan full URL) untuk konsistensi dengan versi lama
      return data['file_name'] as String?;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Menghapus gambar melalui REST API
  Future<void> deleteImage(String fileName, {String? bucket}) async {
    try {
      final bucketParam = bucket ?? _defaultBucket;
      final response = await _apiService.delete(
        '/api/storage/$fileName?bucket=$bucketParam',
      );

      if (response['success'] != true) {
        debugPrint('Error deleting image: ${response['error']}');
      } else {
        debugPrint('Image deleted successfully: $fileName');
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  /// Mendapatkan URL publik untuk file gambar melalui REST API
  Future<String> getPublicUrl(String filePath, {String? bucket}) async {
    try {
      final bucketParam = bucket ?? _defaultBucket;
      final response = await _apiService.get(
        '/api/storage/url',
        queryParams: {'fileName': filePath, 'bucket': bucketParam},
      );

      if (response['success'] != true) {
        debugPrint('Error getting public URL: ${response['error']}');
        return 'https://via.placeholder.com/150';
      }

      final data = response['data'] as Map<String, dynamic>;
      return data['url'] as String;
    } catch (e) {
      debugPrint('Error getting public URL: $e');
      return 'https://via.placeholder.com/150';
    }
  }

  /// Synchronous version untuk backward compatibility
  /// Menggunakan ConfigService untuk generate URL
  String getPublicUrlSync(String filePath, {String? bucket}) {
    final bucketName = bucket ?? _defaultBucket;
    return _configService.getStorageUrl(bucketName, filePath);
  }
}
