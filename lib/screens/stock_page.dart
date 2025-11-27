import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:raffli_motor/screens/add_product_page.dart';
import 'package:raffli_motor/screens/edit_product_page.dart';
import 'package:raffli_motor/models/product_with_stock.dart';
import 'package:raffli_motor/services/database_service.dart';
import 'package:raffli_motor/services/storage_service.dart';
import 'package:raffli_motor/services/auth_service.dart';
import 'package:raffli_motor/widgets/custom_snackbar.dart';
import 'package:raffli_motor/widgets/product_grid.dart';
import 'package:raffli_motor/widgets/vehicle_type_filter.dart';
import 'package:raffli_motor/widgets/product_card.dart'; // Ensure ProductCard is imported

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();

  String _selectedVehicleType = 'All';
  List<ProductWithStock> _inventoryItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _validateSessionAndRefresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Middleware validation: Cek session sebelum load data
  Future<void> _validateSessionAndRefresh() async {
    final isValid = await _authService.validateSession();

    if (!isValid && mounted) {
      // Session invalid, redirect ke login
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    // Session valid, load data
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });

    final items = await _databaseService.getProductsWithStock();

    setState(() {
      _inventoryItems = items;
      _isLoading = false;
    });
  }

  Future<void> _deleteProduct(int productId, String? imageUrl) async {
    try {
      await _databaseService.deleteProduct(productId);
      if (imageUrl != null) {
        await _storageService.deleteImage(imageUrl);
      }
      _refresh();
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Gagal menghapus produk: $e');
      }
    }
  }

  Future<void> _editProduct(ProductWithStock product) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProductPage(product: product),
      ),
    );
    if (result == true) {
      _refresh();
    }
  }

  List<ProductWithStock> get _filteredItems {
    return _inventoryItems.where((item) {
      final matchesSearch =
          _searchController.text.isEmpty ||
          item.name.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      final matchesVehicleType =
          _selectedVehicleType == 'All' ||
          item.vehicleType.toLowerCase() == _selectedVehicleType.toLowerCase();
      return matchesSearch && matchesVehicleType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFDA1818),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Stok Barang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari barang',
                          prefixIcon: const Icon(LucideIcons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Jelajahi Stok Barang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      VehicleTypeFilter(
                        selectedVehicleType: _selectedVehicleType,
                        onSelect: (type) {
                          setState(() {
                            _selectedVehicleType = type;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              _isLoading
                  ? const _LoadingProductGrid()
                  : ProductGrid(
                      items: _filteredItems,
                      onDelete: _deleteProduct,
                      onEdit: _editProduct,
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );
          if (result == true) {
            _refresh();
          }
        },
        backgroundColor: const Color(0xFFDA1818),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _LoadingProductGrid extends StatelessWidget {
  const _LoadingProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
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
          (context, index) => const ProductCard.loading(),
          childCount: 6,
        ),
      ),
    );
  }
}
