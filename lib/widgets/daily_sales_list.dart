import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';

class DailySalesList extends StatelessWidget {
  final List<Sale> sales;

  const DailySalesList({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Histori Penjualan Harian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 15),
          if (sales.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Belum ada penjualan hari ini',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
            )
          else
            ...sales.take(6).map((sale) => _buildSaleItem(sale)),
        ],
      ),
    );
  }

  Widget _buildSaleItem(Sale sale) {
    final localTime = sale.createdAt.toLocal();
    final time = DateFormat('HH:mm').format(localTime);
    final customerName = sale.customerName ?? 'CUSTOMER ${sale.id}';

    // Format service fee as currency
    final formattedPrice = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.',
      decimalDigits: 0,
    ).format(sale.totalPrice);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 50,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Customer name
          Expanded(
            child: Text(
              customerName.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          // Price
          Text(
            formattedPrice,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
