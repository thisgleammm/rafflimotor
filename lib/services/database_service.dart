import 'package:flutter/foundation.dart' hide Category;
import 'package:raffli_motor/models/category.dart';
import 'package:raffli_motor/models/product_with_stock.dart';
import 'package:raffli_motor/models/vehicle_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<ProductWithStock>> getProductsWithStock({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _supabaseClient.rpc('get_products_with_stock');

      if (response.isNotEmpty) {
        final List<ProductWithStock> productList = (response as List)
            .map((item) => ProductWithStock.fromMap(item))
            .toList();
        return productList;
      }
      return [];
    } catch (e) {
      debugPrint('Error getting products with stock: $e');
      return [];
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _supabaseClient.from('category').select();
      return response.map((item) => Category.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  Future<List<VehicleType>> getVehicleTypes() async {
    try {
      final response = await _supabaseClient.from('vehicle_type').select();
      return response.map((item) => VehicleType.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error getting vehicle types: $e');
      return [];
    }
  }

  Future<void> createProduct({
    required String name,
    required int price,
    required int categoryId,
    required int vehicleTypeId,
    required String? imageUrl,
    required int stock,
  }) async {
    try {
      await _supabaseClient.rpc(
        'create_product_with_initial_stock',
        params: {
          'p_name': name,
          'p_price': price,
          'p_category_id': categoryId,
          'p_vehicle_type_id': vehicleTypeId,
          'p_image_url': imageUrl,
          'p_stock': stock,
        },
      );
    } catch (e) {
      debugPrint('Error creating product with stock: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await _supabaseClient.rpc(
        'delete_product',
        params: {'p_product_id': productId},
      );
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct({
    required int productId,
    required String name,
    required int price,
    required int categoryId,
    required int vehicleTypeId,
    String? imageUrl,
  }) async {
    try {
      await _supabaseClient.rpc(
        'update_product',
        params: {
          'p_product_id': productId,
          'p_name': name,
          'p_price': price,
          'p_category_id': categoryId,
          'p_vehicle_type_id': vehicleTypeId,
          'p_image_url': imageUrl,
        },
      );
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }
}
