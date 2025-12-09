import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raffli_motor/models/category.dart';
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
import 'package:raffli_motor/widgets/stock_section.dart';
import 'package:raffli_motor/widgets/image_source_dialog.dart';

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

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        CustomSnackBar.showError(context, 'Gambar produk wajib diupload');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final imageUrl = await _storageService.uploadImage(_imageFile!);

        await _databaseService.createProduct(
          name: _nameController.text,
          price: int.parse(_priceController.text.replaceAll('.', '')),
          stock: int.parse(_stockController.text),
          categoryId: _selectedCategory!.id,
          vehicleTypeId: _selectedVehicleType!.id,
          imageUrl: imageUrl,
        );

        if (mounted) {
          CustomSnackBar.showSuccess(context, 'Produk berhasil ditambahkan!');
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(context, 'Gagal menambahkan produk: $e');
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
      backgroundColor: Colors.grey[50],
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppBarContent(title: 'Tambah Barang'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Upload Section
              ImagePickerWidget(imageFile: _imageFile, onTap: _pickImage),
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
              StockSection(controller: _stockController, label: 'Stok Awal'),
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
                onPressed: _saveProduct,
                text: 'Tambah Barang',
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
