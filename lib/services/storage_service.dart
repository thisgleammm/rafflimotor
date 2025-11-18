import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final String _bucketName = 'productimage_bucket';

  /// Mengunggah gambar ke Supabase Storage dan mengembalikan nama file.
  Future<String?> uploadImage(XFile image) async {
    try {
      final fileBytes = await image.readAsBytes();
      final webpBytes = await FlutterImageCompress.compressWithList(
        fileBytes,
        format: CompressFormat.webp,
        quality: 80,
      );
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.webp';

      await _supabaseClient.storage.from(_bucketName).uploadBinary(
            fileName,
            webpBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              contentType: 'image/webp',
            ),
          );

      // Mengembalikan nama file yang diunggah
      return fileName;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Menghapus gambar dari Supabase Storage.
  Future<void> deleteImage(String fileName) async {
    try {
      final result = await _supabaseClient.storage.from(_bucketName).remove([fileName]);
      debugPrint('Image deletion result: $result');
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  /// Mendapatkan URL publik untuk file gambar dari path-nya.
  String getPublicUrl(String filePath) {
    try {
      return _supabaseClient.storage
          .from(_bucketName)
          .getPublicUrl(filePath);
    }
    catch (e) {
      debugPrint('Error getting public URL: $e');
      // Kembalikan URL placeholder jika terjadi kesalahan
      return 'https://via.placeholder.com/150';
    }
  }
}

