import 'package:flutter/material.dart';
import 'package:raffli_motor/models/product_with_stock.dart';
import 'package:raffli_motor/services/storage_service.dart';
import 'package:raffli_motor/widgets/product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductWithStock> items;
  final Function(int, String?) onDelete;

  const ProductGrid({
    super.key,
    required this.items,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final StorageService storageService = StorageService();
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.63,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            final imageUrl = item.image != null
                ? storageService.getPublicUrl(item.image!)
                : 'https://via.placeholder.com/150';

            return ProductCard(
              imageUrl: imageUrl,
              name: item.name,
              stock: item.stock,
              date: item.updatedAt,
              onEdit: () {
                // TODO: Tambahkan logika edit di sini
              },
              onDelete: () => onDelete(item.id, item.image),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}
