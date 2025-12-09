import 'package:flutter/material.dart';
import 'package:raffli_motor/models/category.dart';
import 'package:raffli_motor/widgets/searchable_dropdown.dart';

class CategoryDropdown extends StatelessWidget {
  final Future<List<Category>> categoriesFuture;
  final Category? selectedCategory;
  final Function(Category?) onSelected;
  final String? Function(Category?)? validator;

  const CategoryDropdown({
    super.key,
    required this.categoriesFuture,
    required this.selectedCategory,
    required this.onSelected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
          child: SearchableDropdown<Category>(
            future: categoriesFuture,
            hintText: "Pilih kategori",
            labelText: '',
            initialSelection: selectedCategory,
            onSelected: onSelected,
            itemAsString: (Category category) => category.name,
            validator:
                validator ??
                (value) => value == null ? 'Kategori tidak boleh kosong' : null,
          ),
        ),
      ],
    );
  }
}
