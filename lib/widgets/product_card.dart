import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert'; // Import for base64Decode

class ProductCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final int stock;
  final DateTime? date;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
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
    this.onLoad,
  }) : isLoading = false;

  const ProductCard.loading({super.key})
      : imageUrl = '',
        name = '',
        stock = 0,
        date = null,
        onEdit = _emptyOnEdit,
        onDelete = null,
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

    // Base64 encoded 1x1 transparent GIF
    const String transparentGif =
        'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';

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
          ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: FadeInImage.memoryNetwork(
                  placeholder: base64Decode(transparentGif),
                  image: widget.imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error);
                  },
                ),
              ),
            ),
          ),
          // 🔹 Deskripsi
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
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
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
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
                          value: 'edit',
                          child: Row(
                            children: const [
                              Icon(
                                LucideIcons.pencil,
                                size: 18,
                                color: Color(0xFF2D3748),
                              ),
                              SizedBox(width: 12),
                              Text('Edit Produk'),
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
                                color: Color(0xFFDA1818),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Hapus Produk',
                                style: TextStyle(
                                  color: Color(0xFFDA1818),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (String value) async {
                        if (value == 'edit') {
                          widget.onEdit();
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Produk'),
                              content: const Text(
                                  'Apakah Anda yakin ingin menghapus produk ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFDA1818),
                                  ),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && widget.onDelete != null) {
                            widget.onDelete!();
                          }
                        }
                      },
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
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
