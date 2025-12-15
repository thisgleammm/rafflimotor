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

  // Futures for async loading
  late Future<List<Map<String, dynamic>>> _weeklySalesFuture;
  late Future<double> _monthlyRevenueFuture;
  late Future<List<Sale>> _todaySalesFuture;

  @override
  void initState() {
    super.initState();
    _checkLowStock();
    _refreshDashboardData();
  }

  void _refreshDashboardData() {
    final now = DateTime.now();
    setState(() {
      _weeklySalesFuture = _databaseService.getWeeklySales();
      _monthlyRevenueFuture = _databaseService.getMonthlyRevenue(
        year: now.year,
        month: now.month,
      );
      _todaySalesFuture = _databaseService.getTodaySales();
    });
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

  void _onItemTapped(int index) {
    if (index == 0) {
      _refreshDashboardData();
    } else if (index == 2) {
      // Refresh low stock alert when switching to stock page
      _checkLowStock();
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleSaleCompleted() {
    // Refresh dashboard data
    _refreshDashboardData();
    _checkLowStock();

    // Trigger rebuild untuk refresh HistoryPage
    // HistoryPage akan reload data di initState saat rebuild
    setState(() {});
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
                  FutureBuilder<double>(
                    future: _monthlyRevenueFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 30,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      }
                      final revenue = snapshot.data ?? 0;
                      return Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp. ',
                          decimalDigits: 0,
                        ).format(revenue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
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
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _weeklySalesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  // Fallback or empty chart logic if needed,
                  // but WeeklySalesChart might handle empty lists.
                  // Let's assume it handles it or we pass empty.
                  return WeeklySalesChart(salesData: snapshot.data ?? []);
                }
                return WeeklySalesChart(salesData: snapshot.data!);
              },
            ),
            // 🔹 Daily Sales List
            FutureBuilder<List<Sale>>(
              future: _todaySalesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return DailySalesList(sales: snapshot.data ?? []);
              },
            ),
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
            builder: (context) =>
                SalesTypeSheet(onSaleCompleted: _handleSaleCompleted),
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
