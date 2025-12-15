# Raffli Motor REST API Documentation

Backend REST API untuk aplikasi Raffli Motor - Sistem Manajemen Bengkel Motor.

## Base URL

- **Development**: `http://localhost:3000`
- **Production**: `https://your-app.vercel.app`

## Authentication

Semua endpoint (kecuali `/api/auth/login`) memerlukan authentication menggunakan Bearer Token.

### Header Format
```
Authorization: Bearer <session_token>
```

---

## Endpoints

### 1. Authentication

#### POST `/api/auth/login`

Login dan mendapatkan session token.

**Request Body:**
```json
{
  "username": "admin",
  "password": "admin"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "username": "admin",
    "fullname": "Administrator",
    "role_id": 1,
    "session_token": "abc123...",
    "expires_at": "2024-12-22T12:00:00.000Z"
  },
  "message": "Login successful"
}
```

**Response Error (401):**
```json
{
  "success": false,
  "error": "Invalid username or password"
}
```

---

#### GET `/api/auth/validate`

Validasi session token yang aktif.

**Headers:** `Authorization: Bearer <token>`

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "valid": true,
    "username": "admin"
  }
}
```

---

#### POST `/api/auth/logout`

Logout dan invalidate session.

**Headers:** `Authorization: Bearer <token>`

**Response Success (200):**
```json
{
  "success": true,
  "data": null,
  "message": "Logout successful"
}
```

---

### 2. Products

#### GET `/api/products`

Get list produk dengan stock.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| limit | integer | 10 | Jumlah data per page |
| offset | integer | 0 | Offset untuk pagination |

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Oli Mesin Honda",
      "price": 75000,
      "category_name": "Oli",
      "vehicle_type_name": "Motor",
      "image": "https://...",
      "created_at": "2024-12-01T10:00:00.000Z",
      "updated_at": "2024-12-15T10:00:00.000Z",
      "stock": 15
    }
  ]
}
```

---

#### GET `/api/products/:id`

Get detail produk berdasarkan ID.

**Headers:** `Authorization: Bearer <token>`

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Oli Mesin Honda",
    "price": 75000,
    "category_name": "Oli",
    "vehicle_type_name": "Motor",
    "image": "https://...",
    "stock": 15
  }
}
```

**Response Error (404):**
```json
{
  "success": false,
  "error": "Product not found"
}
```

---

#### POST `/api/products`

Buat produk baru dengan initial stock.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Oli Mesin Honda",
  "price": 75000,
  "category_id": 1,
  "vehicle_type_id": 1,
  "image_url": null,
  "stock": 10
}
```

**Response Success (201):**
```json
{
  "success": true,
  "data": {
    "id": 5
  },
  "message": "Product created successfully"
}
```

---

#### PUT `/api/products/:id`

Update data produk.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Oli Mesin Honda - Updated",
  "price": 80000,
  "category_id": 1,
  "vehicle_type_id": 1,
  "image_url": null
}
```

**Response Success (200):**
```json
{
  "success": true,
  "data": null,
  "message": "Product updated successfully"
}
```

---

#### DELETE `/api/products/:id`

Hapus produk.

**Headers:** `Authorization: Bearer <token>`

**Response Success (200):**
```json
{
  "success": true,
  "data": null,
  "message": "Product deleted successfully"
}
```

---

#### POST `/api/products/stock`

Tambah stock produk.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "product_id": 1,
  "quantity": 5,
  "type": "manual_add"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "data": null,
  "message": "Stock added successfully"
}
```

---

### 3. Sales

#### GET `/api/sales`

Get history penjualan per bulan.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| year | integer | current year | Tahun |
| month | integer | current month | Bulan (1-12) |

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user": "admin",
      "customer_name": "Budi Santoso",
      "type": "sparepart",
      "service_fee": 0,
      "total_amount": 150000,
      "payment_method": "cash",
      "receipt_url": "https://...",
      "created_at": "2024-12-15T10:00:00.000Z"
    }
  ]
}
```

---

#### GET `/api/sales/today`

Get penjualan hari ini.

**Headers:** `Authorization: Bearer <token>`

**Response:** Same as above

---

#### GET `/api/sales/:id/items`

Get detail items dari sebuah transaksi.

**Headers:** `Authorization: Bearer <token>`

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "sale_id": 1,
      "product_id": 1,
      "product_name": "Oli Mesin Honda",
      "quantity": 2,
      "price_at_sale": 75000,
      "subtotal": 150000
    }
  ]
}
```

---

#### POST `/api/sales`

Buat transaksi penjualan baru.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "customer_name": "Budi Santoso",
  "type": "sparepart",
  "service_fee": 0,
  "payment_method": "cash",
  "receipt_url": null,
  "items": [
    {
      "product_id": 1,
      "quantity": 2,
      "price": 75000
    }
  ]
}
```

**Response Success (201):**
```json
{
  "success": true,
  "data": {
    "id": 5,
    "total_amount": 150000
  },
  "message": "Sale created successfully"
}
```

---

### 4. Master Data

#### GET `/api/categories`

Get semua kategori produk.

**Headers:** `Authorization: Bearer <token>`

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Oli",
      "created_at": "2024-01-01T00:00:00.000Z"
    },
    {
      "id": 2,
      "name": "Sparepart",
      "created_at": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

---

#### GET `/api/vehicle-types`

Get semua tipe kendaraan.

**Headers:** `Authorization: Bearer <token>`

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Motor Matic",
      "created_at": "2024-01-01T00:00:00.000Z"
    },
    {
      "id": 2,
      "name": "Motor Manual",
      "created_at": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

---

### 5. Dashboard

#### GET `/api/dashboard/weekly`

Get data chart revenue 7 hari terakhir.

**Headers:** `Authorization: Bearer <token>`

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    { "date": "Sen", "count": 500000 },
    { "date": "Sel", "count": 750000 },
    { "date": "Rab", "count": 600000 },
    { "date": "Kam", "count": 900000 },
    { "date": "Jum", "count": 850000 },
    { "date": "Sab", "count": 1200000 },
    { "date": "Min", "count": 400000 }
  ]
}
```

---

#### GET `/api/dashboard/monthly`

Get total revenue bulanan.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| year | integer | current year | Tahun |
| month | integer | current month | Bulan (1-12) |

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "revenue": 15000000,
    "year": 2024,
    "month": 12
  }
}
```

---

#### GET `/api/dashboard/low-stock`

Get produk dengan stock rendah.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| limit | integer | 5 | Jumlah produk |
| threshold | integer | 3 | Batas stock rendah |

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 3,
      "name": "Kampas Rem",
      "stock": 2,
      "price": 45000
    }
  ]
}
```

---

### 6. File Upload

#### POST `/api/upload/product-image`

Upload gambar produk.

**Headers:** `Authorization: Bearer <token>`

**Body:** `form-data`
| Key | Type | Description |
|-----|------|-------------|
| file | file | Image file (jpeg, png, webp) |

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "file_name": "1702650000000.webp",
    "url": "https://xxx.supabase.co/storage/v1/object/public/productimage_bucket/1702650000000.webp"
  },
  "message": "Image uploaded successfully"
}
```

---

#### POST `/api/upload/receipt`

Upload receipt PDF.

**Headers:** `Authorization: Bearer <token>`

**Body:** `form-data`
| Key | Type | Description |
|-----|------|-------------|
| file | file | PDF file |

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "file_name": "receipt_1702650000000.pdf",
    "url": "https://xxx.supabase.co/storage/v1/object/public/receipts/receipt_1702650000000.pdf"
  },
  "message": "Receipt uploaded successfully"
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "error": "Invalid request body or parameters"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "error": "No authorization token provided"
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": "Internal server error"
}
```

---

## Development

### Prerequisites
- Node.js 18+
- pnpm

### Setup
```bash
cd backend
pnpm install
```

### Environment Variables
Copy `.env.example` to `.env.local` and fill in:
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_SERVICE_ROLE_KEY` - Supabase service role key (from dashboard)

### Run Development Server
```bash
pnpm dev
```

Server akan berjalan di `http://localhost:3000`

### Deploy to Vercel
```bash
vercel
```

---

## Postman Collection

Import file `postman_collection.json` ke Postman untuk testing.

Collection sudah termasuk:
- Auto-save session token setelah login
- Semua endpoint dengan contoh request
- Environment variables untuk base_url dan token
