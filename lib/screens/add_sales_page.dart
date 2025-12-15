import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:raffli_motor/widgets/custom_app_bar_content.dart';
import 'package:raffli_motor/widgets/custom_snackbar.dart';
import '../models/product_with_stock.dart';
import '../services/database_service.dart';
import '../utils/pdf_generator.dart';

enum SalesType { service, sparepart, serviceAndSparepart }

enum PaymentMethod { cash, qris }

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
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  // Form controllers
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _serviceFeeController = TextEditingController();

  // Currency formatter
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  bool _isLoading = false;

  String get _title {
    switch (widget.type) {
      case SalesType.service:
        return 'Input Penjualan'; // Unified title based on design
      case SalesType.sparepart:
        return 'Input Penjualan';
      case SalesType.serviceAndSparepart:
        return 'Input Penjualan';
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _serviceFeeController.dispose();
    super.dispose();
  }

  Future<void> _showProductSelection() async {
    setState(() => _isLoading = true);

    // Fetch products
    final products = await _databaseService.getProductsWithStock();

    setState(() => _isLoading = false);

    if (!mounted) return;

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
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                              image:
                                  product.image != null &&
                                      product.image!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(product.image!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child:
                                product.image == null || product.image!.isEmpty
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

      if (newQty <= 0) {
        // Hapus item jika qty menjadi 0 atau kurang
        _selectedProducts.removeWhere((p) => p.id == product.id);
        _selectedQuantities.remove(product.id);
      } else if (newQty <= product.stock) {
        _selectedQuantities[product.id] = newQty;
      }
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

  Future<void> _handleCreateNote() async {
    if (_selectedProducts.isEmpty && widget.type == SalesType.sparepart) {
      CustomSnackBar.showError(context, 'Pilih minimal satu sparepart');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final serviceFee =
          double.tryParse(
            _serviceFeeController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0;

      final items = _selectedProducts.map((product) {
        return {
          'product_id': product.id,
          'product_name': product.name,
          'quantity': _selectedQuantities[product.id] ?? 1,
          'price': product.price,
        };
      }).toList();

      final transactionId = DateTime.now().millisecondsSinceEpoch.toString();
      final date = DateTime.now();
      final customerName = _customerNameController.text.isNotEmpty
          ? _customerNameController.text
          : 'Umum';

      // 1. Generate PDF
      final pdfBytes = await PdfGenerator.generateReceipt(
        transactionId: transactionId,
        date: date,
        customerName: customerName,
        items: items,
        serviceFee: serviceFee,
        totalPrice: _totalPrice,
        paymentMethod: _paymentMethod == PaymentMethod.cash ? 'Cash' : 'QRIS',
      );

      // 2. Upload PDF
      final fileName = 'receipt_$transactionId.pdf';
      final receiptUrl = await _databaseService.uploadReceipt(
        fileName,
        pdfBytes,
      );

      if (receiptUrl == null) {
        throw Exception(
          'Gagal mengupload struk. Pastikan bucket "receipts" tersedia dan publik.',
        );
      }

      // 3. Create Sale Record
      await _databaseService.createSale(
        customerName: customerName,
        type: widget.type.name,
        serviceFee: serviceFee,
        items: items,
        receiptUrl: receiptUrl,
        paymentMethod: _paymentMethod.name,
      );

      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Transaksi berhasil disimpan');
        Navigator.pop(context, true); // Return true untuk trigger refresh
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Gagal menyimpan transaksi: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: Stack(
        children: [
          Column(
            children: [
              CustomAppBarContent(title: _title),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    200,
                  ), // Bottom padding for footer - increased for better UX
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Pelanggan
                      const Text(
                        'Nama Pelanggan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _customerNameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            hintText: 'Masukkan nama pelanggan',
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Daftar Barang (Sparepart)
                      if (widget.type != SalesType.service) ...[
                        // Header dengan alignment yang sesuai
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 4,
                                child: Text(
                                  'Daftar Barang',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'Harga jual',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 100,
                                child: const Text(
                                  'Qty',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        ..._selectedProducts.map((product) {
                          final qty = _selectedQuantities[product.id] ?? 1;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 5,
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                // Nama Produk
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                // Harga Jual
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    _currencyFormat
                                        .format(product.price)
                                        .replaceAll('Rp', '')
                                        .replaceAll(',00', '')
                                        .trim(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Qty Controls
                                SizedBox(
                                  width: 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 28,
                                          minHeight: 28,
                                        ),
                                        icon: const Icon(
                                          LucideIcons.minus,
                                          size: 16,
                                        ),
                                        onPressed: () =>
                                            _updateQuantity(product, -1),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                        ),
                                        child: Text(
                                          '$qty',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 28,
                                          minHeight: 28,
                                        ),
                                        icon: const Icon(
                                          LucideIcons.plus,
                                          size: 16,
                                        ),
                                        onPressed: qty < product.stock
                                            ? () => _updateQuantity(product, 1)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        Center(
                          child: InkWell(
                            onTap: _showProductSelection,
                            child: Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: 120, // Reduced width
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDA1818),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                LucideIcons.plus,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Daftar Jasa (Single Input as requested simple)
                      if (widget.type != SalesType.sparepart) ...[
                        const Text(
                          'Daftar Jasa',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 5,
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: Text(
                                  'Biaya Jasa',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                width: 120,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 5,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: TextField(
                                  controller: _serviceFeeController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    hintText: 'Rp 0',
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isEmpty) return;

                                    // Remove non-digit characters
                                    String cleanValue = value.replaceAll(
                                      RegExp(r'[^0-9]'),
                                      '',
                                    );

                                    if (cleanValue.isNotEmpty) {
                                      final number = double.parse(cleanValue);
                                      final formatted = _currencyFormat
                                          .format(number)
                                          .replaceAll(',00', '');

                                      _serviceFeeController.value =
                                          TextEditingValue(
                                            text: formatted,
                                            selection: TextSelection.collapsed(
                                              offset: formatted.length,
                                            ),
                                          );
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFDA1818)),
              ),
            ),

          // Footer
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFDA1818),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Payment Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPaymentOption('Cash', PaymentMethod.cash),
                        _buildPaymentOption('Qris', PaymentMethod.qris),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Total Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Harga',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(_totalPrice),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Button Buat Nota
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleCreateNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFDA1818),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Buat nota',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String label, PaymentMethod method) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.transparent
              : Colors.transparent, // Logic simplified
        ),
        child: Row(
          children: [
            // Radio Circle
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFDA1818) : Colors.grey,
                ),
                color: isSelected
                    ? const Color(0xFFDA1818)
                    : Colors
                          .transparent, // Fill logic might be different in image but this is close
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.black, // Always black text on white bg
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
