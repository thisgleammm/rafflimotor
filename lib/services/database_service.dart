import 'package:flutter/foundation.dart' hide Category;
import 'package:raffli_motor/models/category.dart';
import 'package:raffli_motor/models/product_with_stock.dart';
import 'package:raffli_motor/models/vehicle_type.dart';
import 'package:raffli_motor/models/sale.dart';
import 'package:raffli_motor/models/sale_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:raffli_motor/services/auth_service.dart';

class DatabaseService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final AuthService _authService = AuthService();

  Future<void> logActivity({
    required String action,
    required String description,
  }) async {
    try {
      final userMap = await _authService.getCurrentUser();
      final username = userMap?['username'];

      if (username != null) {
        await _supabaseClient.from('activity_logs').insert({
          'username': username,
          'action': action,
          'description': description,
          // 'ip_address': ... (Optional, requires improved device info logic)
        });
      }
    } catch (e) {
      debugPrint('Error logging activity: $e');
      // Don't rethrow, logging failure shouldn't stop main flow
    }
  }

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

      await logActivity(
        action: 'DELETE_PRODUCT',
        description: 'Deleted product ID: $productId',
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

      await logActivity(
        action: 'ADD_STOCK',
        description: 'Added $quantity stock to product ID: $productId',
      );
    } catch (e) {
      debugPrint('Error adding stock: $e');
      rethrow;
    }
  }

  Future<String?> uploadReceipt(String path, Uint8List fileBytes) async {
    try {
      await _supabaseClient.storage
          .from('receipts')
          .uploadBinary(
            path,
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'application/pdf',
              upsert: true,
            ),
          );
      return _supabaseClient.storage.from('receipts').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error uploading receipt: $e');
      return null;
    }
  }

  Future<void> createSale({
    String? customerName,
    required String type,
    required double serviceFee,
    required List<Map<String, dynamic>> items,
    String? receiptUrl,
    String? paymentMethod,
  }) async {
    try {
      final authService = AuthService();
      final userMap = await authService.getCurrentUser();
      final username = userMap?['username'];

      if (username == null) {
        throw Exception('User authentication required to create sale');
      }

      // Calculate total price
      int totalItemsPrice = 0;
      for (var item in items) {
        final quantity = (item['quantity'] as num).toInt();
        final price = (item['price'] as num).toInt();
        totalItemsPrice += quantity * price;
      }

      final totalPrice = serviceFee.toInt() + totalItemsPrice;

      // 2. Insert into sales table
      final saleResponse = await _supabaseClient
          .from('sales')
          .insert({
            'customer_name': customerName,
            'type': type,
            'service_fee': serviceFee
                .toInt(), // Convert to int for bigint column
            'total_amount':
                totalPrice, // Use total_amount as per database schema
            'receipt_url': receiptUrl,
            'user': username,
            'payment_method': paymentMethod, // Add payment method
          })
          .select()
          .single();

      final saleId = saleResponse['id'];

      // 3. Insert into sale_items table and update stock
      for (var item in items) {
        final quantity = (item['quantity'] as num).toInt();
        final price = (item['price'] as num).toInt();
        final subtotal = quantity * price;

        await _supabaseClient.from('sales_details').insert({
          'sale_id': saleId,
          'product_id': item['product_id'],
          'quantity': quantity,
          'price_at_sale': price, // Correct column name
          'subtotal': subtotal, // Required column
        });

        // 4. Update stock via stock_movements
        await _supabaseClient.from('stock_movements').insert({
          'product_id': item['product_id'],
          'quantity_change': -quantity, // Negative for sales
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
          // 'price' key might still be expected if not fully refactored,
          // but we updated SaleItem to look for 'price_at_sale'.
          // To be safe, let's ensure passed map has what SaleItem needs.
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

  // Get weekly sales data (last 7 days) - Revenue
  Future<List<Map<String, dynamic>>> getWeeklySales() async {
    try {
      final response = await _supabaseClient.rpc('get_weekly_revenue_chart');

      return (response as List).map((item) {
        return {
          'date': item['date_label'],
          'count':
              item['daily_revenue'], // Using 'count' key for compatibility with chart widget logic
        };
      }).toList();
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
      final response = await _supabaseClient.rpc(
        'get_monthly_revenue_fixed',
        params: {'m_year': year, 'm_month': month},
      );
      return (response as num).toDouble();
    } catch (e) {
      debugPrint('Error getting monthly revenue: $e');
      return 0;
    }
  }
}
