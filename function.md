# Function Documentation - Raffli Motor

Dokumentasi lengkap semua function penting dalam aplikasi Raffli Motor.

---

## 📚 Table of Contents

- [REST API Backend](#rest-api-backend)
- [Database Functions (Supabase)](#database-functions-supabase)
- [Dart Services](#dart-services)
  - [ApiService](#apiservice)
  - [AuthService](#authservice)
  - [DatabaseService](#databaseservice)
- [Widgets](#widgets)

---

## REST API Backend

Backend Next.js yang mengganti penggunaan Supabase API langsung.

### Configuration

**Environment Variables (Flutter `.env`):**
```env
API_BASE_URL=http://localhost:3000  # Development
# API_BASE_URL=https://your-app.vercel.app  # Production
```

### Base URL

| Environment | URL |
|-------------|-----|
| Development | `http://localhost:3000` |
| Production | URL Vercel setelah deploy |

### Authentication

Semua endpoint (kecuali login) memerlukan header:
```
Authorization: Bearer <session_token>
```

### Endpoints Summary

| Category | Endpoint | Method | Description |
|----------|----------|--------|-------------|
| **Auth** | `/api/auth/login` | POST | Login |
| | `/api/auth/logout` | POST | Logout |
| | `/api/auth/validate` | GET | Validate session |
| **Products** | `/api/products` | GET | List products |
| | `/api/products` | POST | Create product |
| | `/api/products/:id` | GET/PUT/DELETE | CRUD by ID |
| | `/api/products/stock` | POST | Add stock |
| **Sales** | `/api/sales` | GET | Sales history |
| | `/api/sales` | POST | Create sale |
| | `/api/sales/today` | GET | Today's sales |
| | `/api/sales/:id/items` | GET | Sale items |
| **Master** | `/api/categories` | GET | All categories |
| | `/api/vehicle-types` | GET | All vehicle types |
| **Dashboard** | `/api/dashboard/weekly` | GET | Weekly revenue |
| | `/api/dashboard/monthly` | GET | Monthly revenue |
| | `/api/dashboard/low-stock` | GET | Low stock products |
| **Upload** | `/api/upload/product-image` | POST | Upload image |
| | `/api/upload/receipt` | POST | Upload receipt |

### Response Format

**Success:**
```json
{
  "success": true,
  "data": { ... },
  "message": "Optional message"
}
```

**Error:**
```json
{
  "success": false,
  "error": "Error message"
}
```

---

## Database Functions (Supabase)

### RPC Functions

#### 1. `create_product_with_initial_stock`
**Deskripsi**: Membuat produk baru sekaligus mencatat stok awal di `stock_movements`.

**Parameters**:
- `p_name` (text) - Nama produk
- `p_price` (bigint) - Harga produk
- `p_category_id` (int) - ID kategori
- `p_vehicle_type_id` (int) - ID tipe kendaraan
- `p_image_url` (text) - URL gambar produk
- `p_stock` (int) - Jumlah stok awal

**Return**: `int` - ID produk yang baru dibuat

**Usage**:
```dart
await supabase.rpc('create_product_with_initial_stock', params: {
  'p_name': 'Ban IRC',
  'p_price': 300000,
  'p_category_id': 1,
  'p_vehicle_type_id': 1,
  'p_image_url': 'https://...',
  'p_stock': 10,
});
```

---

#### 2. `update_product`
**Deskripsi**: Memperbarui informasi produk.

**Parameters**:
- `p_product_id` (int) - ID produk
- `p_name` (text) - Nama produk baru
- `p_price` (bigint) - Harga baru
- `p_category_id` (int) - ID kategori baru
- `p_vehicle_type_id` (int) - ID tipe kendaraan baru
- `p_image_url` (text) - URL gambar baru

**Return**: `void`

---

#### 3. `delete_product`
**Deskripsi**: Menghapus produk dan semua dependensinya (stock movements, sales details).

**Parameters**:
- `p_product_id` (int) - ID produk yang akan dihapus

**Return**: `void`

---

#### 4. `calculate_sale_total`
**Deskripsi**: Menghitung total harga transaksi (sales_details + service_fee).

**Parameters**:
- `sale_row_id` (int) - ID transaksi penjualan

**Return**: `bigint` - Total amount

**Note**: Function ini dipanggil otomatis oleh trigger, tidak perlu dipanggil manual.

---

#### 5. `get_weekly_revenue_chart`
**Deskripsi**: Mendapatkan data pendapatan mingguan untuk dashboard chart (7 hari terakhir).

**Parameters**: None

**Return**: 
```json
[
  {
    "day": "2024-01-01",
    "revenue": 1500000
  },
  ...
]
```

**Usage**:
```dart
final data = await supabase.rpc('get_weekly_revenue_chart');
```

---

#### 6. `get_monthly_revenue_fixed`
**Deskripsi**: Mendapatkan total pendapatan bulanan.

**Parameters**:
- `p_year` (int) - Tahun
- `p_month` (int) - Bulan (1-12)

**Return**: `bigint` - Total revenue

**Usage**:
```dart
final revenue = await supabase.rpc('get_monthly_revenue_fixed', params: {
  'p_year': 2024,
  'p_month': 1,
});
```

---

### Database Triggers

#### 1. `update_sale_total_trigger`
**Trigger On**: `sales_details` (INSERT, UPDATE, DELETE)

**Deskripsi**: Otomatis update kolom `sales.total_amount` saat ada perubahan item di `sales_details`.

**Behavior**:
- Saat item ditambah → total_amount bertambah
- Saat item diupdate → total_amount di-recalculate
- Saat item dihapus → total_amount berkurang

**Note**: Trigger ini berjalan otomatis, tidak perlu action manual.

---

## Dart Services

### ApiService

Service dasar untuk komunikasi HTTP dengan REST API backend.

**Location**: `lib/services/api_service.dart`

#### Methods

##### 1. `get(String endpoint, {Map<String, String>? queryParams})`
**Deskripsi**: HTTP GET request ke API.

**Parameters**:
- `endpoint` (String) - Path endpoint (e.g., `/api/products`)
- `queryParams` (Map?) - Query parameters

**Return**: `Future<Map<String, dynamic>>` - Response dari API

**Usage**:
```dart
final response = await apiService.get('/api/products', queryParams: {'limit': '10'});
if (response['success'] == true) {
  final data = response['data'];
}
```

---

##### 2. `post(String endpoint, {Map<String, dynamic>? body})`
**Deskripsi**: HTTP POST request ke API.

**Parameters**:
- `endpoint` (String) - Path endpoint
- `body` (Map?) - Request body (akan di-encode ke JSON)

**Return**: `Future<Map<String, dynamic>>`

---

##### 3. `put(String endpoint, {Map<String, dynamic>? body})`
**Deskripsi**: HTTP PUT request ke API.

---

##### 4. `delete(String endpoint)`
**Deskripsi**: HTTP DELETE request ke API.

---

##### 5. `uploadFile(String endpoint, Uint8List fileBytes, String fileName)`
**Deskripsi**: Upload file dengan multipart request.

**Parameters**:
- `endpoint` (String) - Upload endpoint
- `fileBytes` (Uint8List) - File bytes
- `fileName` (String) - Nama file

**Return**: `Future<Map<String, dynamic>>` - Contains `url` dan `file_name`

---

### AuthService

Service untuk autentikasi dan manajemen session user.

#### Methods

##### 1. `login({required String username, required String password})`
**Deskripsi**: Login user dengan validasi credentials dan generate session token.

**Parameters**:
- `username` (String) - Username
- `password` (String) - Password (akan di-hash dengan SHA-256)

**Return**: `Future<Map<String, dynamic>?>` - User data atau null jika gagal

**Response**:
```dart
{
  'username': 'admin',
  'fullname': 'Administrator',
  'role_id': 1
}
```

**Usage**:
```dart
final authService = AuthService();
final user = await authService.login(
  username: 'admin',
  password: 'password123',
);

if (user != null) {
  // Login berhasil
  print('Welcome ${user['fullname']}');
}
```

**Security Features**:
- Password di-hash dengan SHA-256
- Session token di-generate secara random (32 bytes)
- Session disimpan di database dan local storage
- Session expire setelah 7 hari

---

##### 2. `validateSession()`
**Deskripsi**: Validasi session token dengan server (middleware-like validation).

**Return**: `Future<bool>` - true jika session valid

**Validation Steps**:
1. Check session di local storage
2. Check expiry di client-side
3. Validate session token dengan database
4. Check expiry di server-side
5. Update last activity

**Usage**:
```dart
final isValid = await authService.validateSession();
if (!isValid) {
  // Redirect ke login
  Navigator.pushReplacementNamed(context, '/login');
}
```

---

##### 3. `getCurrentUser()`
**Deskripsi**: Get current user info dari valid session.

**Return**: `Future<Map<String, String>?>` - User data atau null

**Usage**:
```dart
final user = await authService.getCurrentUser();
if (user != null) {
  print('Current user: ${user['username']}');
}
```

---

##### 4. `logout()`
**Deskripsi**: Logout dan invalidate session di server.

**Return**: `Future<void>`

**Actions**:
1. Invalidate session di database
2. Clear local storage
3. Redirect ke login page

**Usage**:
```dart
await authService.logout();
Navigator.pushReplacementNamed(context, '/login');
```

---

##### 5. `logoutAllDevices(String username)`
**Deskripsi**: Invalidate semua session untuk user (logout dari semua device).

**Parameters**:
- `username` (String) - Username

**Return**: `Future<void>`

**Usage**:
```dart
await authService.logoutAllDevices('admin');
```

---

### DatabaseService

Service untuk semua operasi database (products, sales, analytics).

#### Product Management

##### 1. `getProductsWithStock({int limit = 10, int offset = 0})`
**Deskripsi**: Get list produk dengan informasi stok.

**Parameters**:
- `limit` (int) - Jumlah data per page (default: 10)
- `offset` (int) - Offset untuk pagination (default: 0)

**Return**: `Future<List<ProductWithStock>>`

**Usage**:
```dart
final products = await databaseService.getProductsWithStock(
  limit: 20,
  offset: 0,
);
```

---

##### 2. `createProduct({...})`
**Deskripsi**: Membuat produk baru dengan stok awal.

**Parameters**:
- `name` (String) - Nama produk
- `price` (int) - Harga produk
- `categoryId` (int) - ID kategori
- `vehicleTypeId` (int) - ID tipe kendaraan
- `imageUrl` (String?) - URL gambar
- `stock` (int) - Stok awal

**Return**: `Future<void>`

**Usage**:
```dart
await databaseService.createProduct(
  name: 'Ban IRC',
  price: 300000,
  categoryId: 1,
  vehicleTypeId: 1,
  imageUrl: 'https://...',
  stock: 10,
);
```

---

##### 3. `updateProduct({...})`
**Deskripsi**: Update informasi produk.

**Parameters**:
- `productId` (int) - ID produk
- `name` (String) - Nama baru
- `price` (int) - Harga baru
- `categoryId` (int) - Kategori baru
- `vehicleTypeId` (int) - Tipe kendaraan baru
- `imageUrl` (String?) - URL gambar baru

**Return**: `Future<void>`

---

##### 4. `deleteProduct(int productId)`
**Deskripsi**: Hapus produk dan dependensinya.

**Parameters**:
- `productId` (int) - ID produk

**Return**: `Future<void>`

---

##### 5. `addStock(int productId, int quantity)`
**Deskripsi**: Tambah stok produk.

**Parameters**:
- `productId` (int) - ID produk
- `quantity` (int) - Jumlah stok yang ditambah

**Return**: `Future<void>`

**Usage**:
```dart
await databaseService.addStock(productId: 1, quantity: 5);
```

---

#### Sales Management

##### 6. `createSale({...})`
**Deskripsi**: Membuat transaksi penjualan baru.

**Parameters**:
- `customerName` (String?) - Nama pelanggan
- `type` (String) - Tipe transaksi ('service', 'sparepart', 'serviceAndSparepart')
- `serviceFee` (double) - Biaya jasa
- `items` (List<Map>) - List item yang dijual
- `receiptUrl` (String?) - URL nota PDF
- `paymentMethod` (String?) - Metode pembayaran

**Return**: `Future<void>`

**Items Format**:
```dart
[
  {
    'product_id': 1,
    'quantity': 2,
    'price': 300000,
    'subtotal': 600000,
  },
  ...
]
```

**Usage**:
```dart
await databaseService.createSale(
  customerName: 'John Doe',
  type: 'serviceAndSparepart',
  serviceFee: 50000,
  items: [
    {
      'product_id': 1,
      'quantity': 2,
      'price': 300000,
      'subtotal': 600000,
    },
  ],
  receiptUrl: 'https://...',
  paymentMethod: 'cash',
);
```

**Note**: 
- Stock otomatis berkurang saat sale dibuat
- Total amount dihitung otomatis oleh trigger

---

##### 7. `getSalesHistory({required int year, required int month})`
**Deskripsi**: Get histori penjualan per bulan.

**Parameters**:
- `year` (int) - Tahun
- `month` (int) - Bulan (1-12)

**Return**: `Future<List<Sale>>`

**Usage**:
```dart
final sales = await databaseService.getSalesHistory(
  year: 2024,
  month: 1,
);
```

---

##### 8. `getSaleItems(int saleId)`
**Deskripsi**: Get detail item dari transaksi penjualan.

**Parameters**:
- `saleId` (int) - ID transaksi

**Return**: `Future<List<SaleItem>>`

---

#### Analytics & Dashboard

##### 9. `getWeeklySales()`
**Deskripsi**: Get data penjualan mingguan untuk chart (7 hari terakhir).

**Return**: `Future<List<Map<String, dynamic>>>`

**Response**:
```dart
[
  {'day': '2024-01-01', 'revenue': 1500000},
  {'day': '2024-01-02', 'revenue': 2000000},
  ...
]
```

---

##### 10. `getTodaySales()`
**Deskripsi**: Get transaksi penjualan hari ini.

**Return**: `Future<List<Sale>>`

---

##### 11. `getMonthlyRevenue({required int year, required int month})`
**Deskripsi**: Get total pendapatan bulanan.

**Parameters**:
- `year` (int) - Tahun
- `month` (int) - Bulan

**Return**: `Future<double>`

**Usage**:
```dart
final revenue = await databaseService.getMonthlyRevenue(
  year: 2024,
  month: 1,
);
print('Revenue: Rp ${revenue}');
```

---

##### 12. `getLowStockProducts({int limit = 5, int threshold = 3})`
**Deskripsi**: Get produk dengan stok rendah untuk alert.

**Parameters**:
- `limit` (int) - Jumlah produk (default: 5)
- `threshold` (int) - Batas stok rendah (default: 3)

**Return**: `Future<List<ProductWithStock>>`

**Usage**:
```dart
final lowStock = await databaseService.getLowStockProducts(
  limit: 10,
  threshold: 5,
);
```

---

#### File Management

##### 13. `uploadReceipt(String path, Uint8List fileBytes)`
**Deskripsi**: Upload file nota PDF ke Supabase Storage.

**Parameters**:
- `path` (String) - Path file di storage
- `fileBytes` (Uint8List) - File bytes

**Return**: `Future<String>` - Public URL

**Usage**:
```dart
final pdfBytes = await generatePDF();
final url = await databaseService.uploadReceipt(
  'receipts/nota_${DateTime.now().millisecondsSinceEpoch}.pdf',
  pdfBytes,
);
```

---

#### Logging

##### 14. `logActivity({required String action, required String description})`
**Deskripsi**: Log aktivitas user untuk audit trail.

**Parameters**:
- `action` (String) - Jenis aksi (CREATE, UPDATE, DELETE, dll)
- `description` (String) - Deskripsi detail

**Return**: `Future<void>`

**Usage**:
```dart
await databaseService.logActivity(
  action: 'CREATE_SALE',
  description: 'Membuat transaksi penjualan untuk John Doe',
);
```

---

## Widgets

### Custom Widgets

#### 1. `CustomSnackBar`
**Static Methods**:
- `showSuccess(BuildContext context, String message)` - Success snackbar (hijau)
- `showError(BuildContext context, String message)` - Error snackbar (merah)
- `showInfo(BuildContext context, String message)` - Info snackbar (biru)

**Usage**:
```dart
CustomSnackBar.showSuccess(context, 'Transaksi berhasil disimpan');
CustomSnackBar.showError(context, 'Gagal menyimpan data');
```

---

#### 2. `ConfirmationDialog`
**Parameters**:
- `title` (String) - Judul dialog
- `content` (String) - Konten/pesan
- `confirmText` (String) - Text tombol konfirmasi
- `cancelText` (String) - Text tombol batal

**Return**: `Future<bool?>` - true jika confirm, false jika cancel

**Usage**:
```dart
final confirm = await showDialog<bool>(
  context: context,
  builder: (context) => ConfirmationDialog(
    title: 'Konfirmasi Hapus',
    content: 'Apakah Anda yakin ingin menghapus produk ini?',
    confirmText: 'Ya, Hapus',
    cancelText: 'Batal',
  ),
);

if (confirm == true) {
  // User confirmed
  await deleteProduct();
}
```

---

## 🔐 Security Notes

### Password Hashing
- Password di-hash menggunakan **SHA-256**
- Hash disimpan di database, bukan plain text
- Tidak ada cara untuk decrypt password

### Session Management
- Session token: 32 bytes random secure
- Session expire: 7 hari
- Session disimpan di database dan local storage
- Validasi server-side setiap request

### Database Security
- RLS (Row Level Security) enabled di Supabase
- User hanya bisa akses data mereka sendiri
- Admin bisa akses semua data

---

## 📝 Best Practices

### Error Handling
```dart
try {
  await databaseService.createSale(...);
  CustomSnackBar.showSuccess(context, 'Berhasil');
} catch (e) {
  CustomSnackBar.showError(context, 'Gagal: $e');
}
```

### Loading State
```dart
setState(() => _isLoading = true);
try {
  final data = await databaseService.getData();
  setState(() {
    _data = data;
    _isLoading = false;
  });
} catch (e) {
  setState(() => _isLoading = false);
  showError(e);
}
```

### Pagination
```dart
int _page = 0;
final _limit = 20;

Future<void> loadMore() async {
  final products = await databaseService.getProductsWithStock(
    limit: _limit,
    offset: _page * _limit,
  );
  _page++;
}
```

---

## 🔄 Auto-Refresh Mechanism

Setelah transaksi penjualan berhasil:
1. `AddSalesPage` return `true`
2. `SalesTypeSheet` call `onSaleCompleted` callback
3. `Dashboard` refresh data otomatis:
   - Weekly sales chart
   - Monthly revenue
   - Today's sales
   - Low stock alert
4. `HistoryPage` rebuild dan reload data

**Flow**:
```
AddSalesPage (success) 
  → Navigator.pop(true) 
  → SalesTypeSheet (callback) 
  → Dashboard (_handleSaleCompleted) 
  → Auto refresh all data
```

---

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
