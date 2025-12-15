import 'package:flutter/foundation.dart' hide Category;
import 'package:raffli_motor/models/category.dart';
import 'package:raffli_motor/models/product_with_stock.dart';
import 'package:raffli_motor/models/vehicle_type.dart';
import 'package:raffli_motor/models/sale.dart';
import 'package:raffli_motor/models/sale_item.dart';
import 'package:raffli_motor/services/api_service.dart';

/// DatabaseService menggunakan REST API backend
class DatabaseService {
  final ApiService _apiService = ApiService();

  // ==================== PRODUCTS ====================

  Future<List<ProductWithStock>> getProductsWithStock({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/products',
        queryParams: {'limit': limit.toString(), 'offset': offset.toString()},
      );

      if (response['success'] != true) {
        debugPrint('Error getting products: ${response['error']}');
        return [];
      }

      final data = response['data'] as List;
      return data.map((item) => ProductWithStock.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error getting products with stock: $e');
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
      final response = await _apiService.post(
        '/api/products',
        body: {
          'name': name,
          'price': price,
          'category_id': categoryId,
          'vehicle_type_id': vehicleTypeId,
          'image_url': imageUrl,
          'stock': stock,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Failed to create product');
      }
    } catch (e) {
      debugPrint('Error creating product: $e');
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
      final response = await _apiService.put(
        '/api/products/$productId',
        body: {
          'name': name,
          'price': price,
          'category_id': categoryId,
          'vehicle_type_id': vehicleTypeId,
          'image_url': imageUrl,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Failed to update product');
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      final response = await _apiService.delete('/api/products/$productId');

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Failed to delete product');
      }
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  Future<void> addStock(int productId, int quantity) async {
    try {
      final response = await _apiService.post(
        '/api/products/stock',
        body: {
          'product_id': productId,
          'quantity': quantity,
          'type': 'manual_add',
        },
      );

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Failed to add stock');
      }
    } catch (e) {
      debugPrint('Error adding stock: $e');
      rethrow;
    }
  }

  // ==================== CATEGORIES & VEHICLE TYPES ====================

  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.get('/api/categories');

      if (response['success'] != true) {
        debugPrint('Error getting categories: ${response['error']}');
        return [];
      }

      final data = response['data'] as List;
      return data.map((item) => Category.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  Future<List<VehicleType>> getVehicleTypes() async {
    try {
      final response = await _apiService.get('/api/vehicle-types');

      if (response['success'] != true) {
        debugPrint('Error getting vehicle types: ${response['error']}');
        return [];
      }

      final data = response['data'] as List;
      return data.map((item) => VehicleType.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error getting vehicle types: $e');
      return [];
    }
  }

  // ==================== SALES ====================

  Future<void> createSale({
    String? customerName,
    required String type,
    required double serviceFee,
    required List<Map<String, dynamic>> items,
    String? receiptUrl,
    String? paymentMethod,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/sales',
        body: {
          'customer_name': customerName,
          'type': type,
          'service_fee': serviceFee,
          'items': items,
          'receipt_url': receiptUrl,
          'payment_method': paymentMethod,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Failed to create sale');
      }

      // Invalidate cache for current month so history updates immediately
      final now = DateTime.now();
      invalidateSalesCache(now.year, now.month);
    } catch (e) {
      debugPrint('Error creating sale: $e');
      rethrow;
    }
  }

  // Cache for sales history: "year-month" -> List<Sale>
  final Map<String, List<Sale>> _salesHistoryCache = {};
  final Map<String, DateTime> _salesHistoryCacheTime = {};
  static const Duration _cacheDuration = Duration(
    minutes: 5,
  ); // Cache for 5 mins

  Future<List<Sale>> getSalesHistory({
    required int year,
    required int month,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '$year-$month';

    // Check cache validity
    if (!forceRefresh &&
        _salesHistoryCache.containsKey(cacheKey) &&
        _salesHistoryCacheTime.containsKey(cacheKey)) {
      final cacheTime = _salesHistoryCacheTime[cacheKey]!;
      if (DateTime.now().difference(cacheTime) < _cacheDuration) {
        debugPrint('Returning cached sales history for $year-$month');
        return _salesHistoryCache[cacheKey]!;
      }
    }

    try {
      final response = await _apiService.get(
        '/api/sales',
        queryParams: {'year': year.toString(), 'month': month.toString()},
      );

      if (response['success'] != true) {
        debugPrint('Error getting sales history: ${response['error']}');
        return [];
      }

      final data = response['data'] as List;
      final sales = data.map((item) => Sale.fromMap(item)).toList();

      // Update cache
      _salesHistoryCache[cacheKey] = sales;
      _salesHistoryCacheTime[cacheKey] = DateTime.now();

      return sales;
    } catch (e) {
      debugPrint('Error getting sales history: $e');
      // If error occurs but we have old cache, return it as fallback
      if (_salesHistoryCache.containsKey(cacheKey)) {
        debugPrint('Returning stale cache due to error');
        return _salesHistoryCache[cacheKey]!;
      }
      return [];
    }
  }

  /// Clear specific month cache, e.g. when creating a new sale
  void invalidateSalesCache(int year, int month) {
    final cacheKey = '$year-$month';
    _salesHistoryCache.remove(cacheKey);
    _salesHistoryCacheTime.remove(cacheKey);
  }

  Future<List<Sale>> getTodaySales() async {
    try {
      final response = await _apiService.get('/api/sales/today');

      if (response['success'] != true) {
        debugPrint('Error getting today\'s sales: ${response['error']}');
        return [];
      }

      final data = response['data'] as List;
      return data.map((item) => Sale.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error getting today\'s sales: $e');
      return [];
    }
  }

  Future<List<SaleItem>> getSaleItems(int saleId) async {
    try {
      final response = await _apiService.get('/api/sales/$saleId/items');

      if (response['success'] != true) {
        debugPrint('Error getting sale items: ${response['error']}');
        return [];
      }

      final data = response['data'] as List;
      return data.map((item) => SaleItem.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error getting sale items: $e');
      return [];
    }
  }

  // ==================== DASHBOARD ====================

  Future<List<Map<String, dynamic>>> getWeeklySales() async {
    try {
      final response = await _apiService.get('/api/dashboard/weekly');

      if (response['success'] != true) {
        debugPrint('Error getting weekly sales: ${response['error']}');
        return [];
      }

      final data = response['data'] as List;
      return data.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error getting weekly sales: $e');
      return [];
    }
  }

  Future<double> getMonthlyRevenue({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/dashboard/monthly',
        queryParams: {'year': year.toString(), 'month': month.toString()},
      );

      if (response['success'] != true) {
        debugPrint('Error getting monthly revenue: ${response['error']}');
        return 0;
      }

      final data = response['data'] as Map<String, dynamic>;
      return (data['revenue'] as num).toDouble();
    } catch (e) {
      debugPrint('Error getting monthly revenue: $e');
      return 0;
    }
  }

  Future<List<ProductWithStock>> getLowStockProducts({
    int limit = 5,
    int threshold = 3,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/dashboard/low-stock',
        queryParams: {
          'limit': limit.toString(),
          'threshold': threshold.toString(),
        },
      );

      if (response['success'] != true) {
        debugPrint('Error getting low stock products: ${response['error']}');
        return [];
      }

      final data = response['data'] as List;
      return data.map((item) => ProductWithStock.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error getting low stock products: $e');
      return [];
    }
  }

  // ==================== UPLOAD (via REST API) ====================

  Future<String?> uploadReceipt(String path, Uint8List fileBytes) async {
    try {
      final response = await _apiService.uploadFile(
        '/api/upload/receipt',
        fileBytes,
        path,
        mediaType: 'application/pdf',
      );

      if (response['success'] != true) {
        debugPrint('Error uploading receipt: ${response['error']}');
        return null;
      }

      final data = response['data'] as Map<String, dynamic>;
      return data['url'] as String?;
    } catch (e) {
      debugPrint('Error uploading receipt: $e');
      return null;
    }
  }
}
