import 'package:flutter/material.dart';

class VehicleTypeFilter extends StatelessWidget {
  final String selectedVehicleType;
  final Function(String) onSelect;

  const VehicleTypeFilter({
    super.key,
    required this.selectedVehicleType,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in ['Matic', 'Manual', "Matic dan Manual"])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(category),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selectedVehicleType == category
                        ? const Color(0xFFDA1818)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: selectedVehicleType == category
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
    );
  }
}
