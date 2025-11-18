import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style:
              Theme.of(context).inputDecorationTheme.labelStyle ??
              const TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: _decrement),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.minValue.toString(),
                  ),
                  validator: widget.validator,
                  onChanged: (value) {
                    int? newStock = int.tryParse(value);
                    if (newStock != null) {
                      if (newStock >= widget.minValue &&
                          newStock <= widget.maxValue) {
                        _currentStock = newStock;
                      } else if (newStock < widget.minValue) {
                        _currentStock = widget.minValue;
                        widget.controller.text = _currentStock.toString();
                      } else if (newStock > widget.maxValue) {
                        _currentStock = widget.maxValue;
                        widget.controller.text = _currentStock.toString();
                      }
                    }
                  },
                ),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: _increment),
            ],
          ),
        ),
      ],
    );
  }
}
