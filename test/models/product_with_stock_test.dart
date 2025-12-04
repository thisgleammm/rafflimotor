import 'package:flutter_test/flutter_test.dart';
import 'package:raffli_motor/models/product_with_stock.dart';

void main() {
  group('ProductWithStock', () {
    group('fromMap', () {
      test('should create ProductWithStock from valid map with all fields', () {
        // Arrange
        final map = {
          'id': 1,
          'name': 'Oli Mesin',
          'price': 50000,
          'category_name': 'Oli',
          'vehicle_type_name': 'Motor',
          'image': 'https://example.com/image.jpg',
          'created_at': '2024-01-01T10:00:00.000Z',
          'updated_at': '2024-01-02T10:00:00.000Z',
          'stock': 25,
        };

        // Act
        final product = ProductWithStock.fromMap(map);

        // Assert
        expect(product.id, 1);
        expect(product.name, 'Oli Mesin');
        expect(product.price, 50000.0);
        expect(product.category, 'Oli');
        expect(product.vehicleType, 'Motor');
        expect(product.image, 'https://example.com/image.jpg');
        expect(product.createdAt, DateTime.parse('2024-01-01T10:00:00.000Z'));
        expect(product.updatedAt, DateTime.parse('2024-01-02T10:00:00.000Z'));
        expect(product.stock, 25);
      });

      test('should handle null optional fields', () {
        // Arrange
        final map = {
          'id': 2,
          'name': 'Ban Motor',
          'price': 150000,
          'category_name': 'Ban',
          'vehicle_type_name': 'Motor',
          'image': null,
          'created_at': null,
          'updated_at': null,
          'stock': 10,
        };

        // Act
        final product = ProductWithStock.fromMap(map);

        // Assert
        expect(product.id, 2);
        expect(product.name, 'Ban Motor');
        expect(product.price, 150000.0);
        expect(product.image, null);
        expect(product.createdAt, null);
        expect(product.updatedAt, null);
        expect(product.stock, 10);
      });

      test('should use default values when category_name is missing', () {
        // Arrange
        final map = {
          'id': 3,
          'name': 'Spare Part',
          'price': 25000,
          'vehicle_type_name': 'Motor',
          'stock': 5,
        };

        // Act
        final product = ProductWithStock.fromMap(map);

        // Assert
        expect(product.category, 'N/A');
      });

      test('should use default values when vehicle_type_name is missing', () {
        // Arrange
        final map = {
          'id': 4,
          'name': 'Spare Part',
          'price': 25000,
          'category_name': 'Aksesoris',
          'stock': 15,
        };

        // Act
        final product = ProductWithStock.fromMap(map);

        // Assert
        expect(product.vehicleType, 'N/A');
      });

      test('should convert int stock to int correctly', () {
        // Arrange
        final map = {
          'id': 5,
          'name': 'Test Product',
          'price': 100000,
          'category_name': 'Test',
          'vehicle_type_name': 'Motor',
          'stock': 50, // int
        };

        // Act
        final product = ProductWithStock.fromMap(map);

        // Assert
        expect(product.stock, isA<int>());
        expect(product.stock, 50);
      });

      test('should handle zero stock', () {
        // Arrange
        final map = {
          'id': 6,
          'name': 'Out of Stock Product',
          'price': 75000,
          'category_name': 'Test',
          'vehicle_type_name': 'Motor',
          'stock': 0,
        };

        // Act
        final product = ProductWithStock.fromMap(map);

        // Assert
        expect(product.stock, 0);
      });

      test('should convert double price to double', () {
        // Arrange
        final map = {
          'id': 7,
          'name': 'Test Product',
          'price': 99999.99,
          'category_name': 'Test',
          'vehicle_type_name': 'Motor',
          'stock': 20,
        };

        // Act
        final product = ProductWithStock.fromMap(map);

        // Assert
        expect(product.price, isA<double>());
        expect(product.price, 99999.99);
      });
    });

    group('Image URL Handling', () {
      test('should strip file:/// prefix from image path', () {
        // Arrange
        final map = {
          'id': 8,
          'name': 'Image Test',
          'price': 10000,
          'category_name': 'Test',
          'vehicle_type_name': 'Motor',
          'stock': 10,
          'image': 'file:///storage/emulated/0/Pictures/image.jpg',
        };

        // Act
        final product = ProductWithStock.fromMap(map);

        // Assert
        // Note: Since Supabase is not initialized in tests, it should fall back to the stripped path
        // or the original path if the try-catch block catches the error.
        // The logic strips file:/// first, then tries Supabase.
        // If Supabase fails, it keeps the stripped path (or whatever was in imageUrl variable).
        expect(product.image, 'storage/emulated/0/Pictures/image.jpg');
      });

      test('should preserve existing http/https URLs', () {
        // Arrange
        final map = {
          'id': 9,
          'name': 'URL Test',
          'price': 10000,
          'category_name': 'Test',
          'vehicle_type_name': 'Motor',
          'stock': 10,
          'image': 'https://example.com/image.jpg',
        };

        // Act
        final product = ProductWithStock.fromMap(map);

        // Assert
        expect(product.image, 'https://example.com/image.jpg');
      });

      test('should handle filename only (fallback when Supabase not init)', () {
        // Arrange
        final map = {
          'id': 10,
          'name': 'Filename Test',
          'price': 10000,
          'category_name': 'Test',
          'vehicle_type_name': 'Motor',
          'stock': 10,
          'image': 'image.jpg',
        };

        // Act
        final product = ProductWithStock.fromMap(map);

        // Assert
        // Should return the filename as is because Supabase.instance.client will throw/fail in test env
        expect(product.image, 'image.jpg');
      });
    });
  });
}
