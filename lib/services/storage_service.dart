import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<String?> uploadImage(XFile image) async {
    try {
      final file = File(image.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.${image.path.split('.').last}';
      final response = await _supabaseClient.storage.from('products').upload(fileName, file);

      if (response.isNotEmpty) {
        final publicUrl = _supabaseClient.storage.from('products').getPublicUrl(fileName);
        return publicUrl;
      }
    } catch (e) {
      // Handle error
      print('Error uploading image: $e');
    }
    return null;
  }
}
