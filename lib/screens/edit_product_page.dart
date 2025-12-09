import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:raffli_motor/models/category.dart';
import 'package:raffli_motor/models/product_with_stock.dart';
import 'package:raffli_motor/models/vehicle_type.dart';
import 'package:raffli_motor/services/database_service.dart';
import 'package:raffli_motor/services/storage_service.dart';
import 'package:raffli_motor/services/auth_service.dart';
import 'package:raffli_motor/widgets/custom_snackbar.dart';
import 'package:raffli_motor/utils/currency_input_formatter.dart';
import 'package:raffli_motor/widgets/custom_app_bar_content.dart';
import 'package:raffli_motor/widgets/custom_text_field.dart';
import 'package:raffli_motor/widgets/image_picker_widget.dart';
import 'package:raffli_motor/widgets/primary_button.dart';
import 'package:raffli_motor/widgets/category_dropdown.dart';
import 'package:raffli_motor/widgets/vehicle_type_dropdown.dart';
import 'package:raffli_motor/widgets/image_source_dialog.dart';

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
  final _stockController = TextEditingController();

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

    // Pre-fill form
    _nameController.text = widget.product.name;
    _priceController.text = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    ).format(widget.product.price);
    _stockController.text = widget.product.stock.toString();
    _existingImageUrl = widget.product.image;

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final categories = await _categoriesFuture;
    final vehicleTypes = await _vehicleTypesFuture;

    if (mounted) {
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
  }

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
      builder: (context) => const ImageSourceDialog(),
    );

    if (source != null) {
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        // Basic validations
        final fileSize = await file.length();
        const maxFileSize = 5 * 1024 * 1024; // 5MB
        final String fileExtension = pickedFile.name
            .split('.')
            .last
            .toLowerCase();

        if (!['jpg', 'jpeg', 'png'].contains(fileExtension)) {
          if (mounted) CustomSnackBar.showError(context, 'Hanya JPG dan PNG.');
          return;
        }
        if (fileSize > maxFileSize) {
          if (mounted) CustomSnackBar.showError(context, 'Maksimal 5MB.');
          return;
        }

        final imageBytes = await file.readAsBytes();
        final ui.Image image = await decodeImageFromList(imageBytes);
        if (image.width < image.height) {
          if (mounted) {
            CustomSnackBar.showError(context, 'Gambar harus landscape.');
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

        if (_imageFile != null) {
          if (_existingImageUrl != null) {
            try {
              // Extract filename from URL for deletion
              // URLs are like: https://.../productimage_bucket/123.webp
              final uri = Uri.parse(_existingImageUrl!);
              final fileName = uri.pathSegments.last;
              await _storageService.deleteImage(fileName);
            } catch (e) {
              debugPrint('Error deleting old image: $e');
            }
          }
          imageUrl = await _storageService.uploadImage(_imageFile!);
        }

        // Update Product Details
        await _databaseService.updateProduct(
          productId: widget.product.id,
          name: _nameController.text,
          price: int.parse(_priceController.text.replaceAll('.', '')),
          categoryId: _selectedCategory!.id,
          vehicleTypeId: _selectedVehicleType!.id,
          imageUrl: imageUrl,
        );

        // Update Stock if changed
        final newStock = int.parse(_stockController.text);
        final oldStock = widget.product.stock;
        final diff = newStock - oldStock;

        if (diff != 0) {
          await _databaseService.addStock(widget.product.id, diff);
        }

        if (mounted) {
          CustomSnackBar.showSuccess(context, 'Produk berhasil diperbarui!');
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(context, 'Gagal memperbarui produk: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Match AddProductPage background
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppBarContent(title: 'Edit Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0), // Match AddProductPage padding
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Upload Section
              ImagePickerWidget(
                imageFile: _imageFile,
                existingImageUrl: _existingImageUrl,
                onTap: _pickImage,
              ),
              const SizedBox(height: 20),

              // Name
              CustomTextField(
                controller: _nameController,
                label: 'Nama Barang',
                hintText: 'Oli',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama barang tidak boleh kosong';
                  }
                  if (value.length < 3) {
                    return 'Minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stok Saat Ini',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      '${widget.product.stock} pcs',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Price
              CustomTextField(
                controller: _priceController,
                label: 'Harga Beli per Pcs',
                hintText: 'Rp. -',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                validator: (value) => value == null || value.isEmpty
                    ? 'Harga tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),

              // Category
              CategoryDropdown(
                categoriesFuture: _categoriesFuture,
                selectedCategory: _selectedCategory,
                onSelected: (Category? category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Vehicle Type
              VehicleTypeDropdown(
                vehicleTypesFuture: _vehicleTypesFuture,
                selectedVehicleType: _selectedVehicleType,
                onSelected: (VehicleType? vehicleType) {
                  setState(() {
                    _selectedVehicleType = vehicleType;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              PrimaryButton(
                onPressed: _updateProduct,
                text: 'Perbarui Produk',
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
