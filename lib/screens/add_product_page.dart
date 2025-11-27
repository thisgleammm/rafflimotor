import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:raffli_motor/models/category.dart';
import 'package:raffli_motor/models/vehicle_type.dart';
import 'package:raffli_motor/services/database_service.dart';
import 'package:raffli_motor/services/storage_service.dart';
import 'package:raffli_motor/services/auth_service.dart';
import 'package:raffli_motor/widgets/custom_snackbar.dart';
import 'package:raffli_motor/widgets/searchable_dropdown.dart';
import 'package:raffli_motor/utils/currency_input_formatter.dart';
import 'package:raffli_motor/widgets/stock_counter.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  final _databaseService = DatabaseService();
  final _storageService = StorageService();
  final _authService = AuthService();

  Category? _selectedCategory;
  VehicleType? _selectedVehicleType;
  XFile? _imageFile;
  bool _isLoading = false;

  late Future<List<Category>> _categoriesFuture;
  late Future<List<VehicleType>> _vehicleTypesFuture;

  @override
  void initState() {
    super.initState();
    _validateSession();
    _categoriesFuture = _databaseService.getCategories();
    _vehicleTypesFuture = _databaseService.getVehicleTypes();
  }

  // Middleware validation
  Future<void> _validateSession() async {
    final isValid = await _authService.validateSession();
    if (!isValid && mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Kamera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Galeri'),
          ),
        ],
      ),
    );

    if (source != null) {
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        final fileSize = await file.length();
        const maxFileSize = 5 * 1024 * 1024; // 5MB

        // Validate file type
        final String fileExtension = pickedFile.name
            .split('.')
            .last
            .toLowerCase();
        if (!['jpg', 'jpeg', 'png'].contains(fileExtension)) {
          if (mounted) {
            CustomSnackBar.showError(
              context,
              'Format file tidak didukung! Hanya JPG dan PNG.',
            );
          }
          return;
        }

        // Validate file size
        if (fileSize > maxFileSize) {
          if (mounted) {
            CustomSnackBar.showError(
              context,
              'Ukuran file terlalu besar! Maksimal 5MB.',
            );
          }
          return;
        }

        // Validate image orientation (landscape)
        final imageBytes = await file.readAsBytes();
        final ui.Image image = await decodeImageFromList(imageBytes);

        if (image.width < image.height) {
          if (mounted) {
            CustomSnackBar.showError(
              context,
              'Gambar harus landscape (lebar lebih besar dari tinggi).',
            );
          }
          return;
        }

        setState(() {
          _imageFile = pickedFile;
        });
      }
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _storageService.uploadImage(_imageFile!);
        }

        await _databaseService.createProduct(
          name: _nameController.text,
          price: int.parse(_priceController.text.replaceAll('.', '')),
          categoryId: _selectedCategory!.id,
          vehicleTypeId: _selectedVehicleType!.id,
          imageUrl: imageUrl,
          stock: int.parse(_stockController.text),
        );

        if (mounted) {
          CustomSnackBar.showSuccess(context, 'Produk berhasil ditambahkan!');
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(context, 'Gagal menambahkan produk: $e');
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      Navigator.of(context).pop();
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
                    'Tambah Produk Baru',
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  hintText: 'Contoh: Laptop ASUS ROG',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  if (value.length < 3) {
                    return 'Nama produk minimal 3 karakter';
                  }
                  if (value.length > 255) {
                    return 'Nama produk maksimal 255 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Harga Beli per Pcs',
                  hintText: '0',
                  prefixText: 'Rp ',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  final price = int.tryParse(value.replaceAll('.', ''));
                  if (price == null || price < 0) {
                    return 'Harga tidak valid';
                  }
                  if (price > 999999999999) {
                    return 'Harga terlalu besar';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              StockCounter(
                controller: _stockController,
                labelText: 'Stok Awal',
                minValue: 0,
                maxValue: 999999,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stok tidak boleh kosong';
                  }
                  final stock = int.tryParse(value);
                  if (stock == null || stock < 0) {
                    return 'Stok tidak valid';
                  }
                  if (stock > 999999) {
                    return 'Stok terlalu banyak';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SearchableDropdown<Category>(
                future: _categoriesFuture,
                hintText: "Pilih Kategori",
                labelText: 'Kategori',
                initialSelection: _selectedCategory,
                onSelected: (Category? category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                itemAsString: (Category category) => category.name,
                validator: (value) {
                  if (value == null) {
                    return 'Kategori tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SearchableDropdown<VehicleType>(
                future: _vehicleTypesFuture,
                hintText: "Pilih Tipe Kendaraan",
                labelText: 'Tipe Kendaraan',
                initialSelection: _selectedVehicleType,
                onSelected: (VehicleType? vehicleType) {
                  setState(() {
                    _selectedVehicleType = vehicleType;
                  });
                },
                itemAsString: (VehicleType vehicleType) => vehicleType.name,
                validator: (value) {
                  if (value == null) {
                    return 'Tipe Kendaraan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Gambar Produk (wajib gambar landscape, maks 5MB, JPG/PNG)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(LucideIcons.image),
                      label: const Text('Ketuk untuk upload foto'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_imageFile!.path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDA1818),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Produk',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
