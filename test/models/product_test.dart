import 'package:flutter_test/flutter_test.dart';
import 'package:raffli_motor/models/product.dart';

void main() {
  group('Product', () {
    group('fromMap', () {
      test('should create Product from valid map with all fields', () {
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
        };

        // Act
        final product = Product.fromMap(map);

        // Assert
        expect(product.id, 1);
        expect(product.name, 'Oli Mesin');
        expect(product.price, 50000.0);
        expect(product.category, 'Oli');
        expect(product.vehicleType, 'Motor');
        expect(product.image, 'https://example.com/image.jpg');
        expect(product.createdAt, DateTime.parse('2024-01-01T10:00:00.000Z'));
        expect(product.updatedAt, DateTime.parse('2024-01-02T10:00:00.000Z'));
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
        };

        // Act
        final product = Product.fromMap(map);

        // Assert
        expect(product.id, 2);
        expect(product.name, 'Ban Motor');
        expect(product.price, 150000.0);
        expect(product.image, null);
        expect(product.createdAt, null);
        expect(product.updatedAt, null);
      });

      test('should use default values when category_name is missing', () {
        // Arrange
        final map = {
          'id': 3,
          'name': 'Spare Part',
          'price': 25000,
          'vehicle_type_name': 'Motor',
        };

        // Act
        final product = Product.fromMap(map);

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
        };

        // Act
        final product = Product.fromMap(map);

        // Assert
        expect(product.vehicleType, 'N/A');
      });

      test('should convert int price to double', () {
        // Arrange
        final map = {
          'id': 5,
          'name': 'Test Product',
          'price': 100000, // int
          'category_name': 'Test',
          'vehicle_type_name': 'Motor',
        };

        // Act
        final product = Product.fromMap(map);

        // Assert
        expect(product.price, isA<double>());
        expect(product.price, 100000.0);
      });

      test('should handle double price correctly', () {
        // Arrange
        final map = {
          'id': 6,
          'name': 'Test Product',
          'price': 99999.99, // double
          'category_name': 'Test',
          'vehicle_type_name': 'Motor',
        };

        // Act
        final product = Product.fromMap(map);

        // Assert
        expect(product.price, isA<double>());
        expect(product.price, 99999.99);
      });
    });
  });
}
