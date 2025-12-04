import 'sales_item.dart';

class SalesTransaction {
  final int? id;
  final String? customerName;
  final String type;
  final double totalPrice;
  final double serviceFee;
  final DateTime? createdAt;
  final List<SalesItem> items;

  SalesTransaction({
    this.id,
    this.customerName,
    required this.type,
    required this.totalPrice,
    required this.serviceFee,
    this.createdAt,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'customer_name': customerName,
      'type': type,
      'total_price': totalPrice,
      'service_fee': serviceFee,
    };
  }

  factory SalesTransaction.fromMap(Map<String, dynamic> map) {
    return SalesTransaction(
      id: map['id'],
      customerName: map['customer_name'],
      type: map['type'],
      totalPrice: (map['total_price'] as num).toDouble(),
      serviceFee: (map['service_fee'] as num).toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      items: [], // Items are usually loaded separately or joined
    );
  }
}
