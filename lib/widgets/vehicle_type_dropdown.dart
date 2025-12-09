import 'package:flutter/material.dart';
import 'package:raffli_motor/models/vehicle_type.dart';
import 'package:raffli_motor/widgets/searchable_dropdown.dart';

class VehicleTypeDropdown extends StatelessWidget {
  final Future<List<VehicleType>> vehicleTypesFuture;
  final VehicleType? selectedVehicleType;
  final Function(VehicleType?) onSelected;
  final String? Function(VehicleType?)? validator;

  const VehicleTypeDropdown({
    super.key,
    required this.vehicleTypesFuture,
    required this.selectedVehicleType,
    required this.onSelected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipe Kendaraan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SearchableDropdown<VehicleType>(
            future: vehicleTypesFuture,
            hintText: "Pilih tipe kendaraan",
            labelText: '',
            initialSelection: selectedVehicleType,
            onSelected: onSelected,
            itemAsString: (VehicleType vehicleType) => vehicleType.name,
            validator:
                validator ??
                (value) =>
                    value == null ? 'Tipe kendaraan tidak boleh kosong' : null,
          ),
        ),
      ],
    );
  }
}
