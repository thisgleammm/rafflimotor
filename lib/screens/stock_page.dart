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
import 'package:raffli_motor/widgets/product_card.dart';
import 'package:raffli_motor/widgets/add_stock_dialog.dart';

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

  // Pagination state
  final ScrollController _scrollController = ScrollController();
  int _page = 0;
  final int _limit = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _validateSessionAndRefresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _fetchMore();
    }
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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final items = await _databaseService.getProductsWithStock();

    if (!mounted) return;
    setState(() {
      _inventoryItems = items;
      _isLoading = false;
    });
  }

  Future<void> _fetchMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _page + 1;
      final items = await _databaseService.getProductsWithStock(
        limit: _limit,
        offset: nextPage * _limit,
      );

      if (!mounted) return;

      setState(() {
        if (items.isEmpty) {
          _hasMore = false;
        } else {
          _inventoryItems.addAll(items);
          _page = nextPage;
          if (items.length < _limit) {
            _hasMore = false;
          }
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
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

  Future<void> _addStock(ProductWithStock product) async {
    final quantity = await showDialog<int>(
      context: context,
      builder: (context) => AddStockDialog(productName: product.name),
    );

    if (quantity != null && quantity > 0) {
      try {
        await _databaseService.addStock(product.id, quantity);
        if (mounted) {
          CustomSnackBar.showSuccess(
            context,
            'Berhasil menambah stok ${product.name}',
          );
        }
        _refresh();
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(context, 'Gagal menambah stok: $e');
        }
      }
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
      body: RefreshIndicator(
        color: const Color(0xFFDA1818),
        backgroundColor: Colors.white,
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: const Color(0xFFDA1818),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              expandedHeight: 80, // Reduced height for cleaner look
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true, // Center title for better balance
                titlePadding: const EdgeInsets.only(bottom: 20),
                title: const Text(
                  'Stok Barang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Slightly smaller for dense feel
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari barang...',
                        prefixIcon: const Icon(LucideIcons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, // More comfortable touch target
                          horizontal: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              BorderSide.none, // Cleaner look without border
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color(0xFFDA1818),
                            width: 1.5,
                          ),
                        ),
                        // Add shadow for depth
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Jelajahi Stok',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    onAddStock: _addStock,
                  ),
            if (_isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            // Add padding at bottom to avoid FAB overlap
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
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
  const _LoadingProductGrid();

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
