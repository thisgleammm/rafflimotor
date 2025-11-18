class Product {
  final int id;
  final String name;
  final double price;
  final String category; // Assuming this is the category name, or will be joined later
  final String vehicleType;
  final String? image; // Assuming this is the image URL
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.vehicleType,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      category: map['category']?['name'] ?? 'N/A',
      vehicleType: map['vehicle_type']?['name'] ?? 'N/A',
      image: map['image'],
      createdAt:
          map['created_at'] == null ? null : DateTime.parse(map['created_at']),
      updatedAt:
          map['updated_at'] == null ? null : DateTime.parse(map['updated_at']),
    );
  }
}
