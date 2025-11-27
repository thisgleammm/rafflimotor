import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:raffli_motor/models/category.dart';
import 'package:raffli_motor/models/product_with_stock.dart';
import 'package:raffli_motor/models/vehicle_type.dart';
import 'package:raffli_motor/services/database_service.dart';
import 'package:raffli_motor/services/storage_service.dart';
import 'package:raffli_motor/services/auth_service.dart';
import 'package:raffli_motor/widgets/custom_snackbar.dart';
import 'package:raffli_motor/widgets/searchable_dropdown.dart';
import 'package:raffli_motor/utils/currency_input_formatter.dart';

class EditProductPage extends StatefulWidget {
  final ProductWithStock product;
  
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  final _databaseService = DatabaseService();
  final _storageService = StorageService();
  final _authService = AuthService();

  Category? _selectedCategory;
  VehicleType? _selectedVehicleType;
  XFile? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;

  late Future<List<Category>> _categoriesFuture;
  late Future<List<VehicleType>> _vehicleTypesFuture;

  @override
  void initState() {
    super.initState();
    _validateSession();
    _categoriesFuture = _databaseService.getCategories();
    _vehicleTypesFuture = _databaseService.getVehicleTypes();
    
    // Pre-fill form dengan data product yang ada
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toString();
    _existingImageUrl = widget.product.image;
    
    // Load kategori dan vehicle type untuk pre-select
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final categories = await _categoriesFuture;
    final vehicleTypes = await _vehicleTypesFuture;
    
    setState(() {
      _selectedCategory = categories.firstWhere(
        (c) => c.name == widget.product.category,
        orElse: () => categories.first,
      );
      _selectedVehicleType = vehicleTypes.firstWhere(
        (v) => v.name == widget.product.vehicleType,
        orElse: () => vehicleTypes.first,
      );
    });
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

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? imageUrl = _existingImageUrl;
        
        // Upload gambar baru jika ada
        if (_imageFile != null) {
          // Hapus gambar lama jika ada
          if (_existingImageUrl != null) {
            try {
              await _storageService.deleteImage(_existingImageUrl!);
            } catch (e) {
              debugPrint('Error deleting old image: $e');
            }
          }
          imageUrl = await _storageService.uploadImage(_imageFile!);
        }

        await _databaseService.updateProduct(
          productId: widget.product.id,
          name: _nameController.text,
          price: int.parse(_priceController.text.replaceAll('.', '')),
          categoryId: _selectedCategory!.id,
          vehicleTypeId: _selectedVehicleType!.id,
          imageUrl: imageUrl,
        );

        if (mounted) {
          CustomSnackBar.showSuccess(context, 'Produk berhasil diperbarui!');
          Navigator.of(context).pop(true); // Return true untuk refresh list
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(context, 'Gagal memperbarui produk: $e');
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
          decoration: const BoxDecoration(
            color: Color(0xFFDA1818),
            borderRadius: BorderRadius.only(
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
                    'Edit Produk',
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
                decoration: const InputDecoration(
                  labelText: 'Harga Beli per Pcs',
                  hintText: '0',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
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
                    )
                  else if (_existingImageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _storageService.getPublicUrl(_existingImageUrl!),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(LucideIcons.image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.info, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Stok tidak dapat diubah di sini. Gunakan halaman Stock untuk mengelola stok produk.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDA1818),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Perbarui Produk',
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
