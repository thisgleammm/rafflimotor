import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:raffli_motor/widgets/confirmation_dialog.dart';

class ProductCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final int stock;
  final DateTime? date;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddStock;
  final VoidCallback? onLoad;
  final bool isLoading;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.stock,
    this.date,
    required this.onEdit,
    this.onDelete,
    this.onAddStock,
    this.onLoad,
  }) : isLoading = false;

  const ProductCard.loading({super.key})
    : imageUrl = '',
      name = '',
      stock = 0,
      date = null,
      onEdit = _emptyOnEdit,
      onDelete = null,
      onAddStock = null,
      onLoad = null,
      isLoading = true;

  static void _emptyOnEdit() {}

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    final formattedDate = widget.date != null
        ? DateFormat('dd / MM / yyyy').format(widget.date!)
        : 'N/A';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ Gambar barang
          Container(
            margin: const EdgeInsets.all(12),
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child:
                  widget.imageUrl.isNotEmpty &&
                      !widget.imageUrl.contains('placeholder')
                  ? Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 140,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFDA1818),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading image: $error');
                        return const Center(
                          child: Icon(
                            LucideIcons.package,
                            color: Colors.grey,
                            size: 50,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        LucideIcons.package,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
            ),
          ),
          // 🔹 Deskripsi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    // Three-dot menu button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {}, // Handled by PopupMenuButton
                        child: PopupMenuButton<String>(
                          color: const Color(0xFFDA1818),
                          padding: EdgeInsets.zero,
                          icon: Container(
                            padding: const EdgeInsets.all(
                              8,
                            ), // Larger touch target
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.moreVertical,
                              color: Color(0xFFDA1818),
                              size: 18,
                            ),
                          ),
                          offset: const Offset(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'add_stock',
                              child: Row(
                                children: const [
                                  Icon(
                                    LucideIcons.plus,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Tambah Stok',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: const [
                                  Icon(
                                    LucideIcons.pencil,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Edit Produk',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: const [
                                  Icon(
                                    LucideIcons.trash,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Hapus Produk',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (String value) async {
                            if (value == 'add_stock') {
                              if (widget.onAddStock != null) {
                                widget.onAddStock!();
                              }
                            } else if (value == 'edit') {
                              widget.onEdit();
                            } else if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => ConfirmationDialog(
                                  title: 'Konfirmasi hapus?',
                                  content:
                                      'Apakah Anda yakin ingin menghapus produk ini?',
                                  confirmText: 'Ya',
                                  cancelText: 'Tidak',
                                ),
                              );
                              if (confirm == true && widget.onDelete != null) {
                                widget.onDelete!();
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Stok ${widget.stock}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.stock <= 3
                            ? Color(0xFFDA1818)
                            : Colors.black,
                      ),
                    ),
                    if (widget.stock <= 3)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          LucideIcons.alertCircle,
                          color: Color(0xFFDA1818),
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Terakhir input $formattedDate',
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
