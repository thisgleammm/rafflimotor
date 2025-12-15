import 'package:flutter/foundation.dart';
import 'package:raffli_motor/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ConfigService untuk mengambil konfigurasi dari backend API
class ConfigService {
  final ApiService _apiService = ApiService();

  // Cache keys
  static const String _storageBaseUrlKey = 'config_storage_base_url';
  static const String _productBucketKey = 'config_product_bucket';
  static const String _itemsBucketKey = 'config_items_bucket';

  // Default values (fallback)
  static const String _defaultStorageBaseUrl =
      'https://fojhpsdiojcgpbqflrrx.supabase.co/storage/v1/object/public';
  static const String _defaultProductBucket = 'productimage_bucket';
  static const String _defaultItemsBucket = 'items';

  // Singleton pattern
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  // Cached values
  String? _storageBaseUrl;
  String? _productBucket;
  String? _itemsBucket;

  /// Initialize config dari API atau cache
  Future<void> initialize() async {
    try {
      // Try to load from cache first
      final prefs = await SharedPreferences.getInstance();
      _storageBaseUrl = prefs.getString(_storageBaseUrlKey);
      _productBucket = prefs.getString(_productBucketKey);
      _itemsBucket = prefs.getString(_itemsBucketKey);

      // Fetch from API and update cache
      await _fetchConfigFromApi();
    } catch (e) {
      debugPrint('Error initializing config: $e');
      // Use defaults if initialization fails
      _storageBaseUrl ??= _defaultStorageBaseUrl;
      _productBucket ??= _defaultProductBucket;
      _itemsBucket ??= _defaultItemsBucket;
    }
  }

  /// Fetch config from API and save to cache
  Future<void> _fetchConfigFromApi() async {
    try {
      final response = await _apiService.get('/api/config', withAuth: false);

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        _storageBaseUrl = data['storageBaseUrl'] as String?;

        final buckets = data['buckets'] as Map<String, dynamic>?;
        if (buckets != null) {
          _productBucket = buckets['productImage'] as String?;
          _itemsBucket = buckets['items'] as String?;
        }

        // Save to cache
        final prefs = await SharedPreferences.getInstance();
        if (_storageBaseUrl != null) {
          await prefs.setString(_storageBaseUrlKey, _storageBaseUrl!);
        }
        if (_productBucket != null) {
          await prefs.setString(_productBucketKey, _productBucket!);
        }
        if (_itemsBucket != null) {
          await prefs.setString(_itemsBucketKey, _itemsBucket!);
        }

        debugPrint('Config loaded from API: storageBaseUrl=$_storageBaseUrl');
      }
    } catch (e) {
      debugPrint('Error fetching config from API: $e');
    }
  }

  /// Get storage base URL
  String get storageBaseUrl => _storageBaseUrl ?? _defaultStorageBaseUrl;

  /// Get product image bucket name
  String get productBucket => _productBucket ?? _defaultProductBucket;

  /// Get items bucket name
  String get itemsBucket => _itemsBucket ?? _defaultItemsBucket;

  /// Generate public URL for product image
  String getProductImageUrl(String fileName) {
    return '$storageBaseUrl/$productBucket/$fileName';
  }

  /// Generate public URL for item image
  String getItemImageUrl(String fileName) {
    return '$storageBaseUrl/$itemsBucket/$fileName';
  }

  /// Generic method to generate storage URL
  String getStorageUrl(String bucket, String fileName) {
    return '$storageBaseUrl/$bucket/$fileName';
  }
}
