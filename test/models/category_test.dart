import 'package:flutter_test/flutter_test.dart';
import 'package:raffli_motor/models/category.dart';

void main() {
  group('Category', () {
    group('fromMap', () {
      test('should create Category from valid map with all fields', () {
        // Arrange
        final map = {
          'id': 1,
          'name': 'Oli',
          'created_at': '2024-01-01T10:00:00.000Z',
          'updated_at': '2024-01-02T10:00:00.000Z',
        };

        // Act
        final category = Category.fromMap(map);

        // Assert
        expect(category.id, 1);
        expect(category.name, 'Oli');
        expect(category.createdAt, DateTime.parse('2024-01-01T10:00:00.000Z'));
        expect(category.updatedAt, DateTime.parse('2024-01-02T10:00:00.000Z'));
      });

      test('should handle null timestamps', () {
        // Arrange
        final map = {
          'id': 2,
          'name': 'Ban',
          'created_at': null,
          'updated_at': null,
        };

        // Act
        final category = Category.fromMap(map);

        // Assert
        expect(category.id, 2);
        expect(category.name, 'Ban');
        expect(category.createdAt, null);
        expect(category.updatedAt, null);
      });

      test('should handle missing timestamp fields', () {
        // Arrange
        final map = {
          'id': 3,
          'name': 'Aksesoris',
        };

        // Act
        final category = Category.fromMap(map);

        // Assert
        expect(category.id, 3);
        expect(category.name, 'Aksesoris');
        expect(category.createdAt, null);
        expect(category.updatedAt, null);
      });

      test('should parse ISO 8601 date strings correctly', () {
        // Arrange
        final map = {
          'id': 4,
          'name': 'Spare Part',
          'created_at': '2024-06-15T14:30:00.000Z',
          'updated_at': '2024-06-20T09:15:30.000Z',
        };

        // Act
        final category = Category.fromMap(map);

        // Assert
        expect(category.createdAt?.year, 2024);
        expect(category.createdAt?.month, 6);
        expect(category.createdAt?.day, 15);
        expect(category.updatedAt?.year, 2024);
        expect(category.updatedAt?.month, 6);
        expect(category.updatedAt?.day, 20);
      });
    });
  });
}
