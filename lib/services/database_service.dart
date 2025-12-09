import 'package:flutter/foundation.dart' hide Category;
import 'package:raffli_motor/models/category.dart';
import 'package:raffli_motor/models/product_with_stock.dart';
import 'package:raffli_motor/models/vehicle_type.dart';
import 'package:raffli_motor/models/sale.dart';
import 'package:raffli_motor/models/sale_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<ProductWithStock>> getProductsWithStock({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _supabaseClient
          .rpc('get_products_with_stock')
          .range(offset, offset + limit - 1);

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

  Future<void> addStock(int productId, int quantity) async {
    try {
      // Insert into stock_movements
      await _supabaseClient.from('stock_movements').insert({
        'product_id': productId,
        'quantity_change': quantity,
        'type': 'manual_add',
      });

      // Update updated_at timestamp to move product to top of list
      await _supabaseClient
          .from('products')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', productId);
    } catch (e) {
      debugPrint('Error adding stock: $e');
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
      // 2. Insert into sales table
      final saleResponse = await _supabaseClient
          .from('sales')
          .insert({
            'customer_name': customerName,
            'type': type,
            'service_fee': serviceFee
                .toInt(), // Convert to int for bigint column
          })
          .select()
          .single();

      final saleId = saleResponse['id'];

      // 3. Insert into sale_items table and update stock
      for (var item in items) {
        await _supabaseClient.from('sales_details').insert({
          'sale_id': saleId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'price': item['price'],
        });

        // 4. Update stock via stock_movements
        await _supabaseClient.from('stock_movements').insert({
          'product_id': item['product_id'],
          'quantity_change': -item['quantity'], // Negative for sales
          'type': 'sale',
        });
      }
    } catch (e) {
      debugPrint('Error creating sale: $e');
      rethrow;
    }
  }

  // Get sales history for a specific month
  Future<List<Sale>> getSalesHistory({
    required int year,
    required int month,
  }) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1);

      final response = await _supabaseClient
          .from('sales')
          .select()
          .gte('created_at', startDate.toIso8601String())
          .lt('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      return (response as List).map((item) => Sale.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error getting sales history: $e');
      return [];
    }
  }

  // Get sale items with product names for a specific sale
  Future<List<SaleItem>> getSaleItems(int saleId) async {
    try {
      final response = await _supabaseClient
          .from('sales_details')
          .select('*, products(name)')
          .eq('sale_id', saleId);

      return (response as List).map((item) {
        return SaleItem.fromMap({
          ...item,
          'product_name': item['products']['name'],
        });
      }).toList();
    } catch (e) {
      debugPrint('Error getting sale items: $e');
      return [];
    }
  }

  // Get low stock products with direct query
  Future<List<ProductWithStock>> getLowStockProducts({
    int limit = 5,
    int threshold = 3,
  }) async {
    try {
      final response = await _supabaseClient
          .rpc('get_products_with_stock')
          .lte('stock', threshold)
          .order('stock', ascending: true)
          .limit(limit);

      return (response as List)
          .map((item) => ProductWithStock.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Error getting low stock products: $e');
      return [];
    }
  }

  // Get weekly sales data (last 7 days)
  Future<List<Map<String, dynamic>>> getWeeklySales() async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 6));
      final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final response = await _supabaseClient
          .from('sales')
          .select('created_at, service_fee')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: true);

      // Group sales by date
      final Map<String, int> salesByDate = {};

      // Initialize all 7 days with 0
      for (int i = 0; i < 7; i++) {
        final date = startDate.add(Duration(days: i));
        final dateKey =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
        salesByDate[dateKey] = 0;
      }

      // Count sales per day
      for (var sale in response) {
        final createdAt = DateTime.parse(sale['created_at']);
        final dateKey =
            '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}';
        salesByDate[dateKey] = (salesByDate[dateKey] ?? 0) + 1;
      }

      // Convert to list format for chart
      return salesByDate.entries
          .map((entry) => {'date': entry.key, 'count': entry.value})
          .toList();
    } catch (e) {
      debugPrint('Error getting weekly sales: $e');
      return [];
    }
  }

  // Get today's sales transactions
  Future<List<Sale>> getTodaySales() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final response = await _supabaseClient
          .from('sales')
          .select()
          .gte('created_at', startOfDay.toIso8601String())
          .lte('created_at', endOfDay.toIso8601String())
          .order('created_at', ascending: false);

      return (response as List).map((item) => Sale.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error getting today\'s sales: $e');
      return [];
    }
  }

  // Get monthly total revenue
  Future<double> getMonthlyRevenue({
    required int year,
    required int month,
  }) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1);

      final response = await _supabaseClient
          .from('sales')
          .select('service_fee')
          .gte('created_at', startDate.toIso8601String())
          .lt('created_at', endDate.toIso8601String());

      // Get all sale items for this month to calculate total revenue
      final salesResponse = await _supabaseClient
          .from('sales')
          .select('id')
          .gte('created_at', startDate.toIso8601String())
          .lt('created_at', endDate.toIso8601String());

      double totalRevenue = 0;

      // Add service fees
      for (var sale in response) {
        totalRevenue += (sale['service_fee'] as num).toDouble();
      }

      // Add product sales
      for (var sale in salesResponse) {
        final saleItems = await _supabaseClient
            .from('sales_details')
            .select('quantity, price')
            .eq('sale_id', sale['id']);

        for (var item in saleItems) {
          totalRevenue += (item['quantity'] as num) * (item['price'] as num);
        }
      }

      return totalRevenue;
    } catch (e) {
      debugPrint('Error getting monthly revenue: $e');
      return 0;
    }
  }
}
