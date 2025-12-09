import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../services/database_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DatabaseService _databaseService = DatabaseService();
  DateTime _selectedMonth = DateTime.now();
  List<Sale> _sales = [];
  final Map<int, List<SaleItem>> _saleItemsCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSalesHistory();
  }

  Future<void> _loadSalesHistory() async {
    setState(() {
      _isLoading = true;
    });

    final sales = await _databaseService.getSalesHistory(
      year: _selectedMonth.year,
      month: _selectedMonth.month,
    );

    // Load items for each sale
    _saleItemsCache.clear();
    for (var sale in sales) {
      final items = await _databaseService.getSaleItems(sale.id);
      _saleItemsCache[sale.id] = items;
    }

    if (!mounted) return;

    setState(() {
      _sales = sales;
      _isLoading = false;
    });
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _loadSalesHistory();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    _loadSalesHistory();
  }

  Map<int, List<Sale>> _groupSalesByDate() {
    final grouped = <int, List<Sale>>{};
    for (var sale in _sales) {
      final day = sale.createdAt.day;
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(sale);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedSales = _groupSalesByDate();
    final monthName = DateFormat('MMMM').format(_selectedMonth);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        color: const Color(0xFFDA1818),
        backgroundColor: Colors.white,
        onRefresh: _loadSalesHistory,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: const Color(0xFFDA1818),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 20),
                title: const Text(
                  'Histori Penjualan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Month selector
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _previousMonth,
                      icon: const Icon(LucideIcons.chevronLeft),
                      color: const Color(0xFF2D3748),
                    ),
                    Text(
                      monthName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(LucideIcons.chevronRight),
                      color: const Color(0xFF2D3748),
                    ),
                  ],
                ),
              ),
            ),
            // Sales list
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_sales.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Tidak ada transaksi',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final days = groupedSales.keys.toList()
                    ..sort((a, b) => b.compareTo(a));
                  final day = days[index];
                  final salesForDay = groupedSales[day]!;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 20),
                          child: Text(
                            '$day',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ),
                        // Sales cards for this day
                        ...salesForDay.map((sale) => _buildSaleCard(sale)),
                        if (index == groupedSales.length - 1)
                          const SizedBox(height: 20), // Bottom padding
                      ],
                    ),
                  );
                }, childCount: groupedSales.keys.length),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleCard(Sale sale) {
    final items = _saleItemsCache[sale.id] ?? [];
    final timeStr = DateFormat('HH:mm').format(sale.createdAt);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer name and time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sale.customerName ?? 'Customer',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                timeStr,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Items list
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x  ${item.productName}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                  Text(
                    currencyFormat.format(item.subtotal),
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          // Service fee if any
          if (sale.serviceFee > 0) ...[
            const SizedBox(height: 8),
            const Text(
              'Add On',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Servis ${sale.type}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
                Text(
                  currencyFormat.format(sale.serviceFee),
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                currencyFormat.format(sale.totalPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
