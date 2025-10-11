import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../widgets/bottom_navbar.dart';
import 'inventory_page.dart'; // ✅ import halaman inventory

class DashboardPage extends StatefulWidget {
  final String username;
  const DashboardPage({super.key, required this.username});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    if (index == 3) {
      // 🔴 Tombol logout
      await SessionService.clearSession();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } else if (index == 2) {
      // 📦 Tombol inventory
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InventoryPage()),
      );
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
                    const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 28,
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
        onPressed: () {},
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Color(0xFFDA1818), size: 40),
      ),
      items: [
        CustomBottomNavItem(
          icon: Icons.home_rounded,
          isSelected: _selectedIndex == 0,
          onTap: () => _onItemTapped(0),
        ),
        CustomBottomNavItem(
          icon: Icons.history_rounded,
          isSelected: _selectedIndex == 1,
          onTap: () => _onItemTapped(1),
        ),
        CustomBottomNavItem(
          icon: Icons.inventory_2_rounded,
          isSelected: false, // Tidak perlu ubah state karena pindah halaman
          onTap: () => _onItemTapped(2),
        ),
        CustomBottomNavItem(
          icon: Icons.logout_rounded,
          isSelected: false,
          onTap: () => _onItemTapped(3),
        ),
      ],
      child: pages[_selectedIndex],
    );
  }
}
