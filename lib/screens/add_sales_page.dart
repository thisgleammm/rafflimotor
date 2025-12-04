import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:raffli_motor/widgets/custom_snackbar.dart';
import '../models/product_with_stock.dart';
import '../services/database_service.dart';

enum SalesType { service, sparepart, serviceAndSparepart }

class AddSalesPage extends StatefulWidget {
  final SalesType type;

  const AddSalesPage({super.key, required this.type});

  @override
  State<AddSalesPage> createState() => _AddSalesPageState();
}

class _AddSalesPageState extends State<AddSalesPage> {
  final DatabaseService _databaseService = DatabaseService();
  final List<ProductWithStock> _selectedProducts = [];
  final Map<int, int> _selectedQuantities = {};

  // Form controllers
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _serviceFeeController = TextEditingController();

  // Currency formatter
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String get _title {
    switch (widget.type) {
      case SalesType.service:
        return 'Tambah Servis';
      case SalesType.sparepart:
        return 'Jual Sparepart';
      case SalesType.serviceAndSparepart:
        return 'Servis & Sparepart';
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _complaintController.dispose();
    _serviceFeeController.dispose();
    super.dispose();
  }

  Future<void> _showProductSelection() async {
    // Show loading dialog immediately
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDA1818)),
        ),
      ),
    );

    // Fetch products
    final products = await _databaseService.getProductsWithStock();

    if (!mounted) return;

    // Close loading dialog
    Navigator.pop(context);

    List<ProductWithStock> filteredProducts = List.from(products);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'Pilih Sparepart',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari sparepart...',
                        prefixIcon: const Icon(LucideIcons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        setStateModal(() {
                          filteredProducts = products
                              .where(
                                (p) => p.name.toLowerCase().contains(
                                  value.toLowerCase(),
                                ),
                              )
                              .toList();
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final isSelected = _selectedProducts.any(
                          (p) => p.id == product.id,
                        );

                        if (isSelected) return const SizedBox.shrink();

                        return ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              image: product.image != null
                                  ? DecorationImage(
                                      image: NetworkImage(product.image!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: product.image == null
                                ? const Icon(
                                    LucideIcons.package,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Stok: ${product.stock} | ${_currencyFormat.format(product.price)}',
                            style: TextStyle(
                              color: product.stock == 0
                                  ? Colors.red
                                  : Colors.grey[600],
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              LucideIcons.plusCircle,
                              color: Color(0xFFDA1818),
                            ),
                            onPressed: product.stock > 0
                                ? () {
                                    setState(() {
                                      _selectedProducts.add(product);
                                      _selectedQuantities[product.id] = 1;
                                    });
                                    setStateModal(() {});
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _updateQuantity(ProductWithStock product, int delta) {
    setState(() {
      final currentQty = _selectedQuantities[product.id] ?? 1;
      final newQty = currentQty + delta;

      if (newQty > 0 && newQty <= product.stock) {
        _selectedQuantities[product.id] = newQty;
      }
    });
  }

  void _removeProduct(ProductWithStock product) {
    setState(() {
      _selectedProducts.removeWhere((p) => p.id == product.id);
      _selectedQuantities.remove(product.id);
    });
  }

  double get _totalPrice {
    double total = 0;

    // Add service fee if applicable
    if (widget.type != SalesType.sparepart) {
      total +=
          double.tryParse(
            _serviceFeeController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0;
    }

    // Add spareparts
    for (var product in _selectedProducts) {
      total += product.price * (_selectedQuantities[product.id] ?? 1);
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Pelanggan (Opsional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(LucideIcons.user),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (widget.type != SalesType.sparepart) ...[
                    TextFormField(
                      controller: _complaintController,
                      decoration: const InputDecoration(
                        labelText: 'Keluhan / Jenis Servis',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(LucideIcons.clipboard),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serviceFeeController,
                      decoration: const InputDecoration(
                        labelText: 'Biaya Jasa',
                        border: OutlineInputBorder(),
                        prefixText: 'Rp ',
                        prefixIcon: Icon(LucideIcons.banknote),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],

                  if (widget.type != SalesType.service) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daftar Sparepart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showProductSelection,
                          icon: const Icon(LucideIcons.plus, size: 16),
                          label: const Text('Tambah'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFDA1818),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedProducts.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: const Center(
                          child: Text(
                            'Belum ada sparepart dipilih',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final product = _selectedProducts[index];
                          final quantity = _selectedQuantities[product.id] ?? 1;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        _currencyFormat.format(product.price),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        LucideIcons.minusCircle,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _updateQuantity(product, -1),
                                      color: Colors.grey,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        LucideIcons.plusCircle,
                                        size: 20,
                                      ),
                                      onPressed: quantity < product.stock
                                          ? () => _updateQuantity(product, 1)
                                          : null,
                                      color: const Color(0xFFDA1818),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(
                                        LucideIcons.trash2,
                                        size: 20,
                                      ),
                                      onPressed: () => _removeProduct(product),
                                      color: Colors.red[300],
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Summary Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Estimasi',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      _currencyFormat.format(_totalPrice),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDA1818),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        // Prepare items
                        final items = _selectedProducts.map((product) {
                          return {
                            'product_id': product.id,
                            'quantity': _selectedQuantities[product.id] ?? 1,
                            'price': product.price,
                          };
                        }).toList();

                        // Parse service fee
                        final serviceFee =
                            double.tryParse(
                              _serviceFeeController.text.replaceAll(
                                RegExp(r'[^0-9]'),
                                '',
                              ),
                            ) ??
                            0;

                        // Call database service
                        await _databaseService.createSale(
                          customerName: _customerNameController.text.isEmpty
                              ? null
                              : _customerNameController.text,
                          type:
                              widget.type.name, // 'service', 'sparepart', etc.
                          serviceFee: serviceFee,
                          items: items,
                        );

                        if (context.mounted) {
                          // Hide loading indicator
                          Navigator.pop(context);

                          // Show success message
                          CustomSnackBar.showSuccess(
                            context,
                            'Transaksi berhasil disimpan',
                          );

                          // Close AddSalesPage
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          // Hide loading indicator
                          Navigator.pop(context);

                          // Show error message
                          CustomSnackBar.showError(
                            context,
                            'Gagal menyimpan transaksi: $e',
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDA1818),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Simpan Transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
