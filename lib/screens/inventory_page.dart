import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:raffli_motor/widgets/product_card.dart';
import 'dashboard_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'All';
  late final Future<String> _placeholderImageUrl;

  final List<Map<String, dynamic>> items = [
    {
      'name': 'Oli SPX 2',
      'stock': 15,
      'date': DateTime(2025, 9, 15),
      'category': 'Matic',
    },
    {
      'name': 'Oli MPX 2',
      'stock': 3,
      'date': DateTime(2025, 9, 15),
      'category': 'Manual',
    },
    {
      'name': 'Minyak rem honda',
      'stock': 9,
      'date': DateTime(2025, 9, 15),
      'category': 'Matic',
    },
  ];

  @override
  void initState() {
    super.initState();
    _placeholderImageUrl = _getPlaceholderImageUrl();
  }

  Future<String> _getPlaceholderImageUrl() async {
    try {
      final url = Supabase.instance.client.storage
          .from('productimage_bucket')
          .getPublicUrl('placeholder.webp');
      return url;
    } catch (e) {
      print('Error getting placeholder image URL: $e');
      // Return a default placeholder or handle the error appropriately
      return 'https://via.placeholder.com/150';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = items.where((item) {
      final matchesSearch = _searchController.text.isEmpty || item['name'].toString().toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      final matchesCategory =
          selectedCategory == 'All' || item['category'] == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

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
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  DashboardPage(username: ''),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(-1.0, 0.0);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔍 Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari barang',
                  prefixIcon: const Icon(LucideIcons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              const Text(
                'Jelajahi Stok Barang',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // 🏷️ Filter kategori
              Row(
                children: [
                  for (final category in ['All', 'Matic', 'Manual'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedCategory = category);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selectedCategory == category
                                ? Color(0xFFDA1818)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: selectedCategory == category
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // 📦 Daftar barang
              FutureBuilder<String>(
                future: _placeholderImageUrl,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 6, // Placeholder count
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.63,
                      ),
                      itemBuilder: (context, index) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text('Error memuat gambar'));
                  }
                  final imageUrl = snapshot.data!;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredItems.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.63,
                    ),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return ProductCard(
                        imageUrl: imageUrl,
                        name: item['name'],
                        stock: item['stock'],
                        date: item['date'],
                        onEdit: () {
                          // TODO: Tambahkan logika edit di sini
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
