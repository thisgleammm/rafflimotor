import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SearchableDropdown<T> extends StatelessWidget {
  final Future<List<T>> future;
  final String hintText;
  final String labelText;
  final T? initialSelection;
  final Function(T?) onSelected;
  final String Function(T) itemAsString;
  final FormFieldValidator<T>? validator;

  const SearchableDropdown({
    super.key,
    required this.future,
    required this.hintText,
    required this.labelText,
    this.initialSelection,
    required this.onSelected,
    required this.itemAsString,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 60,
              width: double.infinity,
              color: Colors.white,
            ),
          );
        }
        if (snapshot.hasError) {
          return Text('Error loading $labelText');
        }
        final items = snapshot.data ?? [];
        return DropdownButtonFormField<T>(
          items: items.map<DropdownMenuItem<T>>((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemAsString(item)),
            );
          }).toList(),
          onChanged: onSelected,
          initialValue: initialSelection,
          hint: Text(hintText),
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
          ),
          validator: validator,
        );
      },
    );
  }
}
