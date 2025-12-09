import 'package:flutter/material.dart';
import 'package:raffli_motor/widgets/stock_counter.dart';

class StockSection extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int minValue;
  final int maxValue;
  final String? Function(String?)? validator;

  const StockSection({
    super.key,
    required this.controller,
    this.label = 'Stok',
    this.minValue = 0,
    this.maxValue = 999999,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        StockCounter(
          controller: controller,
          labelText: '',
          minValue: minValue,
          maxValue: maxValue,
          validator: validator,
        ),
      ],
    );
  }
}
