class VehicleType {
  final int id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VehicleType({required this.id, required this.name, this.createdAt, this.updatedAt});

  factory VehicleType.fromMap(Map<String, dynamic> map) {
    return VehicleType(
      id: map['id'],
      name: map['name'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}
