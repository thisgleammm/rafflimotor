import 'package:flutter/material.dart';

class BottomNavbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: const Color(0xFFDA1818),
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              iconSize: 32,
              icon: Icon(
                Icons.home_rounded,
                color: widget.currentIndex == 0 ? Colors.white : Colors.white70,
              ),
              onPressed: () => widget.onTap(0),
            ),
            IconButton(
              iconSize: 32,
              icon: Icon(
                Icons.history_rounded,
                color: widget.currentIndex == 1 ? Colors.white : Colors.white70,
              ),
              onPressed: () => widget.onTap(1),
            ),
            const SizedBox(width: 40), // jarak tengah untuk FAB
            IconButton(
              iconSize: 32,
              icon: Icon(
                Icons.inventory_2_rounded,
                color: widget.currentIndex == 2 ? Colors.white : Colors.white70,
              ),
              onPressed: () => widget.onTap(2),
            ),
            IconButton(
              iconSize: 32,
              icon: Icon(
                Icons.person_outline_rounded,
                color: widget.currentIndex == 3 ? Colors.white : Colors.white70,
              ),
              onPressed: () => widget.onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}
