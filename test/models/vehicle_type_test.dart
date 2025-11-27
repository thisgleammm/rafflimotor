import 'package:flutter_test/flutter_test.dart';
import 'package:raffli_motor/models/vehicle_type.dart';

void main() {
  group('VehicleType', () {
    group('fromMap', () {
      test('should create VehicleType from valid map with all fields', () {
        // Arrange
        final map = {
          'id': 1,
          'name': 'Motor',
          'created_at': '2024-01-01T10:00:00.000Z',
          'updated_at': '2024-01-02T10:00:00.000Z',
        };

        // Act
        final vehicleType = VehicleType.fromMap(map);

        // Assert
        expect(vehicleType.id, 1);
        expect(vehicleType.name, 'Motor');
        expect(vehicleType.createdAt,
            DateTime.parse('2024-01-01T10:00:00.000Z'));
        expect(vehicleType.updatedAt,
            DateTime.parse('2024-01-02T10:00:00.000Z'));
      });

      test('should handle null timestamps', () {
        // Arrange
        final map = {
          'id': 2,
          'name': 'Mobil',
          'created_at': null,
          'updated_at': null,
        };

        // Act
        final vehicleType = VehicleType.fromMap(map);

        // Assert
        expect(vehicleType.id, 2);
        expect(vehicleType.name, 'Mobil');
        expect(vehicleType.createdAt, null);
        expect(vehicleType.updatedAt, null);
      });

      test('should handle missing timestamp fields', () {
        // Arrange
        final map = {
          'id': 3,
          'name': 'Truk',
        };

        // Act
        final vehicleType = VehicleType.fromMap(map);

        // Assert
        expect(vehicleType.id, 3);
        expect(vehicleType.name, 'Truk');
        expect(vehicleType.createdAt, null);
        expect(vehicleType.updatedAt, null);
      });

      test('should parse ISO 8601 date strings correctly', () {
        // Arrange
        final map = {
          'id': 4,
          'name': 'Sepeda',
          'created_at': '2024-06-15T14:30:00.000Z',
          'updated_at': '2024-06-20T09:15:30.000Z',
        };

        // Act
        final vehicleType = VehicleType.fromMap(map);

        // Assert
        expect(vehicleType.createdAt?.year, 2024);
        expect(vehicleType.createdAt?.month, 6);
        expect(vehicleType.createdAt?.day, 15);
        expect(vehicleType.updatedAt?.year, 2024);
        expect(vehicleType.updatedAt?.month, 6);
        expect(vehicleType.updatedAt?.day, 20);
      });
    });
  });
}
