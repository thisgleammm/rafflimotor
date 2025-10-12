import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomBottomNavItem {
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  CustomBottomNavItem({
    required this.icon,
    required this.onTap,
    required this.isSelected,
  });
}

class BottomNavbar extends StatelessWidget {
  final Widget? floatingActionButton;
  final List<CustomBottomNavItem> items;
  final Color backgroundColor;
  final double height;
  final double iconSize;
  final Widget child;

  const BottomNavbar({
    super.key,
    this.floatingActionButton,
    required this.items,
    required this.child,
    this.backgroundColor = const Color(0xFFDA1818),
    this.height = 70,
    this.iconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: child,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: backgroundColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Kiri FAB
              Row(
                children: [
                  _buildNavItem(items[0]),
                  const SizedBox(width: 40),
                  _buildNavItem(items[1]),
                ],
              ),
              // Space for FAB (lebih kecil)
              const SizedBox(width: 40),
              // Kanan FAB
              Row(
                children: [
                  _buildNavItem(items[2]),
                  const SizedBox(width: 40),
                  _buildNavItem(items[3]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(CustomBottomNavItem item) {
    return IconButton(
      iconSize: iconSize,
      icon: Icon(
        item.icon,
        color: item.isSelected ? Colors.white : Colors.white70,
      ),
      onPressed: item.onTap,
    );
  }
}
