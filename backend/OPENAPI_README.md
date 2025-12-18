# OpenAPI Documentation

File `openapi.yaml` berisi dokumentasi lengkap API Raffli Motor dalam format OpenAPI 3.0 (Swagger).

## Cara Menggunakan

### 1. Menggunakan Swagger Editor Online

Buka [Swagger Editor](https://editor.swagger.io/) dan copy-paste isi file `openapi.yaml`.

### 2. Menggunakan Swagger UI Lokal

Install Swagger UI:

```bash
pnpm add -D swagger-ui-react swagger-ui-express
```

Buat file `src/app/api-docs/page.tsx`:

```tsx
'use client';

import SwaggerUI from 'swagger-ui-react';
import 'swagger-ui-react/swagger-ui.css';

export default function ApiDocs() {
  return <SwaggerUI url="/openapi.yaml" />;
}
```

Pindahkan `openapi.yaml` ke folder `public/`.

### 3. Menggunakan Redoc

Alternatif lain untuk visualisasi yang lebih modern:

```bash
pnpm add -D redoc
```

### 4. Generate Postman Collection

Gunakan [OpenAPI to Postman Converter](https://www.postman.com/api-platform/api-schema-conversion/) untuk convert `openapi.yaml` ke Postman Collection.

## Fitur Dokumentasi

✅ Semua 20+ endpoints terdokumentasi lengkap  
✅ Request & Response schemas dengan contoh  
✅ Authentication dengan Bearer Token  
✅ Error responses standar  
✅ Tag grouping untuk navigasi mudah  
✅ Parameter descriptions  
✅ File upload endpoints  

## Endpoints yang Terdokumentasi

### Authentication
- POST `/api/auth/login` - Login
- GET `/api/auth/validate` - Validasi token
- POST `/api/auth/logout` - Logout

### Products
- GET `/api/products` - List produk
- POST `/api/products` - Buat produk
- GET `/api/products/:id` - Detail produk
- PUT `/api/products/:id` - Update produk
- DELETE `/api/products/:id` - Hapus produk
- POST `/api/products/stock` - Tambah stock

### Sales
- GET `/api/sales` - History penjualan
- GET `/api/sales/today` - Penjualan hari ini
- GET `/api/sales/:id/items` - Detail items
- POST `/api/sales` - Buat transaksi

### Master Data
- GET `/api/categories` - List kategori
- GET `/api/vehicle-types` - List tipe kendaraan

### Dashboard
- GET `/api/dashboard/weekly` - Chart weekly
- GET `/api/dashboard/monthly` - Revenue bulanan
- GET `/api/dashboard/low-stock` - Produk stock rendah

### File Upload
- POST `/api/upload/product-image` - Upload gambar
- POST `/api/upload/receipt` - Upload receipt

## Validasi

Untuk validasi OpenAPI spec, gunakan:

```bash
npx @apidevtools/swagger-cli validate openapi.yaml
```
