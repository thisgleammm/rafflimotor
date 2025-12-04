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

  Future<void> createSale({
    String? customerName,
    required String type,
    required double serviceFee,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      // 1. Calculate total price
      double totalPrice = serviceFee;
      for (var item in items) {
        totalPrice += (item['price'] as num) * (item['quantity'] as num);
      }

      // 2. Insert into sales table
      final saleResponse = await _supabaseClient
          .from('sales')
          .insert({
            'customer_name': customerName,
            'type': type,
            'service_fee': serviceFee,
            'total_price': totalPrice,
          })
          .select()
          .single();

      final saleId = saleResponse['id'];

      // 3. Insert into sale_items table and update stock
      for (var item in items) {
        await _supabaseClient.from('sale_items').insert({
          'sale_id': saleId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'price': item['price'],
        });

        // 4. Update stock (decrement)
        // We can use a stored procedure if available, or just update directly.
        // Since we don't have a specific 'decrement_stock' RPC visible,
        // we'll try to use a custom RPC if it existed, but here we might need to
        // fetch current stock and update it, OR assume there's a trigger.
        // Given the previous 'create_product_with_initial_stock' RPC, maybe there is one.
        // But for now, let's try to update the product directly by fetching first?
        // Actually, to be safe and atomic, let's assume we can just call an RPC or
        // if we must do it client side:

        // Fetch current product to get stock
        final productResponse = await _supabaseClient
            .from('products')
            .select('stock')
            .eq('id', item['product_id'])
            .single();

        final currentStock = productResponse['stock'] as int;
        final newStock = currentStock - (item['quantity'] as int);

        await _supabaseClient
            .from('products')
            .update({'stock': newStock})
            .eq('id', item['product_id']);
      }
    } catch (e) {
      debugPrint('Error creating sale: $e');
      rethrow;
    }
  }
}
