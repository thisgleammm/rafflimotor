import 'package:raffli_motor/services/config_service.dart';

class ProductWithStock {
  final int id;
  final String name;
  final double price;
  final String category;
  final String vehicleType;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int stock;

  ProductWithStock({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.vehicleType,
    this.image,
    this.createdAt,
    this.updatedAt,
    required this.stock,
  });

  factory ProductWithStock.fromMap(Map<String, dynamic> map) {
    String? imageUrl = map['image'];

    if (imageUrl != null) {
      // Handle file:/// prefix if present (legacy data)
      if (imageUrl.startsWith('file:///')) {
        imageUrl = imageUrl.replaceFirst('file:///', '');
      }

      // If it's just a filename (doesn't start with http and not a local path), generate public URL
      if (!imageUrl.startsWith('http') && !imageUrl.startsWith('/')) {
        // Generate storage URL using ConfigService
        final configService = ConfigService();
        imageUrl = configService.getProductImageUrl(imageUrl);
      }
    }

    return ProductWithStock(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      category: map['category_name'] ?? 'N/A',
      vehicleType: map['vehicle_type_name'] ?? 'N/A',
      image: imageUrl,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at']),
      stock: (map['stock'] as num).toInt(),
    );
  }
}
