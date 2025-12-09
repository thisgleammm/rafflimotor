import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StockCounter extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final int minValue;
  final int maxValue;
  final FormFieldValidator<String>? validator;

  const StockCounter({
    super.key,
    required this.controller,
    this.labelText = 'Stok',
    this.minValue = 0,
    this.maxValue = 999999,
    this.validator,
  });

  @override
  State<StockCounter> createState() => _StockCounterState();
}

class _StockCounterState extends State<StockCounter> {
  late int _currentStock;

  @override
  void initState() {
    super.initState();
    _currentStock = int.tryParse(widget.controller.text) ?? widget.minValue;
    widget.controller.text = _currentStock.toString();
  }

  void _increment() {
    setState(() {
      if (_currentStock < widget.maxValue) {
        _currentStock++;
        widget.controller.text = _currentStock.toString();
      }
    });
  }

  void _decrement() {
    setState(() {
      if (_currentStock > widget.minValue) {
        _currentStock--;
        widget.controller.text = _currentStock.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Minus button
          IconButton(
            onPressed: _decrement,
            icon: const Icon(LucideIcons.minus, size: 20),
            color: _currentStock > widget.minValue
                ? const Color(0xFFDA1818)
                : Colors.grey[400],
            padding: const EdgeInsets.all(16),
          ),
          // Text field
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                contentPadding: EdgeInsets.zero,
              ),
              validator: widget.validator,
              onChanged: (value) {
                int? newStock = int.tryParse(value);
                if (newStock != null) {
                  if (newStock >= widget.minValue &&
                      newStock <= widget.maxValue) {
                    setState(() {
                      _currentStock = newStock;
                    });
                  } else if (newStock < widget.minValue) {
                    setState(() {
                      _currentStock = widget.minValue;
                      widget.controller.text = _currentStock.toString();
                    });
                  } else if (newStock > widget.maxValue) {
                    setState(() {
                      _currentStock = widget.maxValue;
                      widget.controller.text = _currentStock.toString();
                    });
                  }
                }
              },
            ),
          ),
          // Plus button
          IconButton(
            onPressed: _increment,
            icon: const Icon(LucideIcons.plus, size: 20),
            color: _currentStock < widget.maxValue
                ? const Color(0xFFDA1818)
                : Colors.grey[400],
            padding: const EdgeInsets.all(16),
          ),
        ],
      ),
    );
  }
}
