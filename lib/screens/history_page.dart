import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
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

  bool _isCalendarVisible = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;

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

  void _toggleCalendar() {
    setState(() {
      _isCalendarVisible = !_isCalendarVisible;
    });
  }

  // _pickDate is superseded by TableCalendar selection, removing it to avoid confusion

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
            // Month selector and Calendar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left side: Current Month Name (e.g., "Januari")
                        Row(
                          children: [
                            Text(
                              monthName,
                              style: const TextStyle(
                                fontSize: 24, // Bigger font as per UI
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedMonth.year}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(width: 5),
                            // Use next month/prev month for chevron navigation if needed,
                            // but UI shows just the current month name.
                            // Keeping chevron as indicator for now.
                            const Icon(LucideIcons.chevronRight, size: 24),
                          ],
                        ),

                        // Right side: Calendar Icon
                        IconButton(
                          onPressed: _toggleCalendar,
                          icon: const Icon(LucideIcons.calendar),
                          color: const Color(0xFF2D3748),
                        ),
                      ],
                    ),
                    if (_isCalendarVisible) ...[
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Gray background as per UI
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: _selectedMonth,
                          calendarFormat: _calendarFormat,
                          headerVisible: false, // We use custom header
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedMonth, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedMonth = selectedDay;
                            });
                            _loadSalesHistory();
                          },
                          calendarStyle: CalendarStyle(
                            selectedDecoration: const BoxDecoration(
                              color: Color(0xFFDA1818), // Red Color
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: const Color(
                                0xFFDA1818,
                              ).withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            defaultTextStyle: TextStyle(
                              color: Colors.grey[800],
                            ),
                            weekendTextStyle: const TextStyle(
                              color: Color(0xFFDA1818),
                            ), // Red for weekends
                            outsideDaysVisible: true,
                            outsideTextStyle: TextStyle(
                              color: Colors.grey[400],
                            ),
                          ),
                          daysOfWeekStyle: const DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            weekendStyle: TextStyle(
                              color: Color(0xFFDA1818),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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

  String _getTransactionTypeLabel(String? type) {
    switch (type?.toLowerCase()) {
      case 'sparepart':
        return 'Sparepart';
      case 'service':
        return 'Servis';
      case 'serviceandspareparт':
      case 'serviceandsparepart':
        return 'Servis + Sparepart';
      default:
        return type ?? 'Tidak diketahui';
    }
  }

  Future<void> _launchReceipt(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch receipt URL')),
        );
      }
    }
  }

  Widget _buildSaleCard(Sale sale) {
    final items = _saleItemsCache[sale.id] ?? [];
    // Convert UTC time to local device time
    final localTime = sale.createdAt.toLocal();
    final timeStr = DateFormat('HH:mm').format(localTime);
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
              'Jenis Transaksi',
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
                    _getTransactionTypeLabel(sale.type),
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
          if (sale.receiptUrl != null && sale.receiptUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _launchReceipt(sale.receiptUrl!),
                icon: const Icon(LucideIcons.fileText, size: 18),
                label: const Text('Lihat Nota'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDA1818),
                  side: const BorderSide(color: Color(0xFFDA1818)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
