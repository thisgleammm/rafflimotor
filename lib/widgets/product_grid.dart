import 'package:flutter/material.dart';
import 'package:raffli_motor/models/product_with_stock.dart';
import 'package:raffli_motor/widgets/product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductWithStock> items;
  final Function(int, String?) onDelete;
  final Function(ProductWithStock) onEdit;
  final Function(ProductWithStock)? onAddStock;

  const ProductGrid({
    super.key,
    required this.items,
    required this.onDelete,
    required this.onEdit,
    this.onAddStock,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate aspect ratio dynamically based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    // Assuming 2 columns with 16px padding on sides and 12px spacing
    final cardWidth = (screenWidth - 32 - 12) / 2;
    // Estimated height components: Image(140) + Text/Padding(approx 90)
    // Adjust 280 based on actual content height (was 230 causing overflow)
    const estimatedCardHeight = 280.0;
    final childAspectRatio = cardWidth / estimatedCardHeight;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];
          // item.image already contains the full URL from ProductWithStock.fromMap
          // No need to call getPublicUrl again
          final imageUrl = item.image ?? '';

          return ProductCard(
            imageUrl: imageUrl,
            name: item.name,
            stock: item.stock,
            date: item.updatedAt,
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item.id, item.image),
            onAddStock: onAddStock != null ? () => onAddStock!(item) : null,
          );
        }, childCount: items.length),
      ),
    );
  }
}
