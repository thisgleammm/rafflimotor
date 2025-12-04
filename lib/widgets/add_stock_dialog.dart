import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raffli_motor/widgets/confirmation_dialog.dart';

class AddStockDialog extends StatefulWidget {
  final String productName;

  const AddStockDialog({super.key, required this.productName});

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tambah Stok: ${widget.productName}'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Jumlah Stok',
            hintText: 'Masukkan jumlah stok yang ingin ditambahkan',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Harap masukkan jumlah';
            }
            final number = int.tryParse(value);
            if (number == null || number <= 0) {
              return 'Jumlah harus lebih dari 0';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final quantity = int.parse(_controller.text);

              showDialog<bool>(
                context: context,
                builder: (context) => ConfirmationDialog(
                  title: 'Konfirmasi Tambah Stok',
                  content:
                      'Apakah Anda yakin ingin menambahkan $quantity stok untuk ${widget.productName}?',
                  confirmText: 'Simpan',
                  confirmColor: const Color(0xFFDA1818),
                ),
              ).then((confirmed) {
                if (confirmed == true && context.mounted) {
                  Navigator.of(context).pop(quantity);
                }
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDA1818),
            foregroundColor: Colors.white,
          ),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
