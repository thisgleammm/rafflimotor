# Function Documentation

Dokumentasi fungsi-fungsi dalam aplikasi dan database.

## Database Functions (Supabase RPC/Triggers)

### Existing (dari `database.sql`)
1.  **`create_product_with_initial_stock`**
    *   **Deskripsi**: Membuat produk baru sekaligus mencatat stok awal di `stock_movements`.
    *   **Params**: `p_name`, `p_price`, `p_category_id`, `p_vehicle_type_id`, `p_image_url`, `p_stock`.

2.  **`update_product`**
    *   **Deskripsi**: Memperbarui informasi produk.
    *   **Params**: `p_product_id`, `p_name`, ...

3.  **`delete_product`**
    *   **Deskripsi**: Menghapus produk dan dependensi.

### New Implementation (dari `update_sales_schema.sql`)
1.  **`calculate_sale_total(sale_row_id)`**
    *   **Tipe**: Helper Function
    *   **Deskripsi**: Menghitung total harga transaksi (`sales_details` + `service_fee`).
    *   **Return**: `bigint` (sesuai kolom `total_amount`).

2.  **`update_sale_total_trigger`**
    *   **Tipe**: Trigger
    *   **Deskripsi**: Update otomatis kolom `sales.total_amount` saat ada perubahan item di `sales_details`.

3.  **`get_weekly_revenue_chart`**
    *   **Tipe**: RPC
    *   **Deskripsi**: Data pendapatan mingguan untuk dashboard (Nominal Rp).

4.  **`get_monthly_revenue_fixed`**
    *   **Tipe**: RPC
    *   **Deskripsi**: Total pendapatan bulanan (fix bug 0).

## Dart Services

### `DatabaseService`
-   **`createSale`**: Insert ke `sales` dan `sales_details`. `total_amount` dihitung otomatis oleh trigger database.
-   **`getWeeklySales`**: Menggunakan RPC `get_weekly_revenue_chart`.
-   **`getMonthlyRevenue`**: Menggunakan RPC `get_monthly_revenue_fixed`.
