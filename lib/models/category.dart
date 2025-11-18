class Category {
  final int id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({required this.id, required this.name, this.createdAt, this.updatedAt});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}
