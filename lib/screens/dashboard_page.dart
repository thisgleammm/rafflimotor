import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/product_with_stock.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/low_stock_alert.dart';
import '../widgets/sales_type_sheet.dart';
import 'stock_page.dart'; // ✅ import halaman inventory

class DashboardPage extends StatefulWidget {
  final String username;
  const DashboardPage({super.key, required this.username});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final DatabaseService _databaseService = DatabaseService();
  List<ProductWithStock> _lowStockProducts = [];
  bool _isLoadingStock = true;
  static const int _minStockThreshold = 3;

  @override
  void initState() {
    super.initState();
    _checkLowStock();
  }

  Future<void> _checkLowStock() async {
    setState(() {
      _isLoadingStock = true;
    });

    final products = await _databaseService.getProductsWithStock();
    final lowStock = products
        .where((product) => product.stock <= _minStockThreshold)
        .toList();

    setState(() {
      _lowStockProducts = lowStock;
      _isLoadingStock = false;
    });
  }

  void _onItemTapped(int index) async {
    if (index == 3) {
      // 🔴 Tombol logout - invalidate session di server juga
      final authService = AuthService();
      await authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } else if (index == 2) {
      // 📦 Tombol inventory
      final result = await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const StockPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
      // Refresh low stock alert ketika kembali dari stock page
      if (result == true || result == null) {
        _checkLowStock();
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      // Dashboard content
      Column(
        children: [
          // 🔹 Header bagian atas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 25,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFDA1818),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔸 Bagian atas (avatar dan notifikasi)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/profile.jpg'),
                          radius: 25,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, ${widget.username}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Owner",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Notification badge with count
                    Stack(
                      children: [
                        const Icon(
                          LucideIcons.bell,
                          color: Colors.white,
                          size: 28,
                        ),
                        if (_lowStockProducts.isNotEmpty && !_isLoadingStock)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                '${_lowStockProducts.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                // 🔸 Summary Monthly
                const Text(
                  "Summary Monthly",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Rp. 1.000.000",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 🔹 Low Stock Alert
          if (!_isLoadingStock)
            LowStockAlert(
              lowStockProducts: _lowStockProducts,
              onRefresh: _checkLowStock,
              onViewStock: () => _onItemTapped(2),
            ),
          // 🔹 Isi halaman
          Expanded(
            child: Center(
              child: Text(
                "Content Area",
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ),
        ],
      ),
      // History page (bisa diganti sesuai kebutuhan)
      const Center(child: Text("History Page")),
      Container(), // Placeholder untuk inventory, sudah di-handle navigator
    ];

    return BottomNavbar(
      backgroundColor: const Color(0xFFDA1818),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => const SalesTypeSheet(),
          );
        },
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus, color: Color(0xFFDA1818), size: 40),
      ),
      items: [
        CustomBottomNavItem(
          icon: LucideIcons.home,
          isSelected: _selectedIndex == 0,
          onTap: () => _onItemTapped(0),
        ),
        CustomBottomNavItem(
          icon: LucideIcons.history,
          isSelected: _selectedIndex == 1,
          onTap: () => _onItemTapped(1),
        ),
        CustomBottomNavItem(
          icon: LucideIcons.box,
          isSelected: false, // Tidak perlu ubah state karena pindah halaman
          onTap: () => _onItemTapped(2),
        ),
        CustomBottomNavItem(
          icon: LucideIcons.logOut,
          isSelected: false,
          onTap: () => _onItemTapped(3),
        ),
      ],
      child: pages[_selectedIndex],
    );
  }
}
