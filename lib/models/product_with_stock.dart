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
    return ProductWithStock(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      category: map['category_name'] ?? 'N/A',
      vehicleType: map['vehicle_type_name'] ?? 'N/A',
      image: map['image'],
      createdAt:
          map['created_at'] == null ? null : DateTime.parse(map['created_at']),
      updatedAt:
          map['updated_at'] == null ? null : DateTime.parse(map['updated_at']),
      stock: (map['stock'] as num).toInt(),
    );
  }
}
