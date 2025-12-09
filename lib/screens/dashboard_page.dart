import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/database_service.dart';
import '../models/product_with_stock.dart';
import '../models/sale.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/low_stock_alert.dart';
import '../widgets/sales_type_sheet.dart';
import '../widgets/weekly_sales_chart.dart';
import '../widgets/daily_sales_list.dart';
import 'stock_page.dart'; // ✅ import halaman inventory
import 'profile_page.dart'; // ✅ import halaman profile
import 'history_page.dart'; // ✅ import halaman history

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

  // Sales data
  List<Map<String, dynamic>> _weeklySalesData = [];
  List<Sale> _todaySales = [];
  double _monthlyRevenue = 0;
  bool _isLoadingSales = true;

  @override
  void initState() {
    super.initState();
    _checkLowStock();
    _loadSalesData();
  }

  Future<void> _checkLowStock() async {
    setState(() {
      _isLoadingStock = true;
    });

    try {
      final lowStock = await _databaseService.getLowStockProducts(
        threshold: _minStockThreshold,
      );

      setState(() {
        _lowStockProducts = lowStock;
        _isLoadingStock = false;
      });
    } catch (e) {
      debugPrint('Error checking low stock: $e');
      setState(() {
        _isLoadingStock = false;
      });
    }
  }

  Future<void> _loadSalesData() async {
    setState(() {
      _isLoadingSales = true;
    });

    try {
      final now = DateTime.now();
      final weeklySales = await _databaseService.getWeeklySales();
      final todaySales = await _databaseService.getTodaySales();
      final monthlyRevenue = await _databaseService.getMonthlyRevenue(
        year: now.year,
        month: now.month,
      );

      setState(() {
        _weeklySalesData = weeklySales;
        _todaySales = todaySales;
        _monthlyRevenue = monthlyRevenue;
        _isLoadingSales = false;
      });
    } catch (e) {
      debugPrint('Error loading sales data: $e');
      setState(() {
        _isLoadingSales = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Refresh low stock alert when switching to stock page
      _checkLowStock();
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      // Dashboard content
      SingleChildScrollView(
        child: Column(
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
                      _isLoadingSales
                          ? const SizedBox(
                              height: 30,
                          child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              NumberFormat.currency(
                                locale: 'id_ID',
                                symbol: 'Rp. ',
                                decimalDigits: 0,
                              ).format(_monthlyRevenue),
                              style: const TextStyle(
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
                // 🔹 Weekly Sales Chart
            if (!_isLoadingSales) WeeklySalesChart(salesData: _weeklySalesData),
                // 🔹 Daily Sales List
                if (!_isLoadingSales) DailySalesList(sales: _todaySales),
                // Spacer
                const SizedBox(height: 20),
          ],
        ),
      ),
      // History page
      const HistoryPage(),
      // Inventory Page
      const StockPage(),
      // Profile Page
      ProfilePage(username: widget.username),
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
          isSelected: false, // Never selected since it navigates away
          onTap: () => Navigator.pushNamed(context, '/inventory'),
        ),
        CustomBottomNavItem(
          icon: LucideIcons.user,
          isSelected: _selectedIndex == 3,
          onTap: () => _onItemTapped(3),
        ),
      ],
      child: pages[_selectedIndex],
    );
  }
}
