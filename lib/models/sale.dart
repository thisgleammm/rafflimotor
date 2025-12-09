class Sale {
  final int id;
  final String? customerName;
  final String type;
  final double serviceFee;
  final double totalPrice;
  final DateTime createdAt;

  Sale({
    required this.id,
    this.customerName,
    required this.type,
    required this.serviceFee,
    required this.totalPrice,
    required this.createdAt,
  });

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as int,
      customerName: map['customer_name'] as String?,
      type: map['type'] as String,
      serviceFee: (map['service_fee'] as num?)?.toDouble() ?? 0.0,
      totalPrice:
          (map['total_price'] as num?)?.toDouble() ??
          (map['service_fee'] as num?)?.toDouble() ??
          0.0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'type': type,
      'service_fee': serviceFee,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
