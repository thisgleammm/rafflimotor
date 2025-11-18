# Raffli Motor - AI Coding Assistant Guide

## Project Overview
Flutter aplikasi manajemen inventori motor untuk Raffli Motor dengan backend Supabase. Stack: Flutter 3.9.2+, Supabase (PostgreSQL + Storage), SHA-256 auth, shared_preferences session.

## Architecture

### Data Flow Pattern
**Database → RPC Functions → Services → Screens → Widgets**

- Supabase RPC functions (`get_products_with_stock`, `create_product_with_initial_stock`) handle business logic server-side
- `DatabaseService` wraps all Supabase calls using `Supabase.instance.client`
- `StorageService` manages image uploads to `productimage_bucket` (auto-converts to WebP)
- `SessionService` uses `SharedPreferences` for 7-day sessions (no Supabase auth)

### Custom Authentication
**NO Supabase Auth** - Uses custom table-based auth:
- Password: SHA-256 hashing via `SecureSupabaseClient._hashPassword()`
- Login: Direct query to `user` table matching username + hashed password
- Session: `SharedPreferences` stores username + timestamp (7-day expiry)
- Check `lib/services/secure_supabase_client.dart` for auth pattern

### Models & Database
- `Product`: Base product model with category/vehicle_type foreign keys
- `ProductWithStock`: Extended model from `get_products_with_stock()` RPC that joins products + calculates stock from `stock_movements`
- Stock tracking: `stock_movements` table with `quantity_change` summed via RPC (not stored directly in products table)
- See `database.sql` for complete schema and RPC function definitions

## Key Conventions

### Widget Patterns
```dart
// ProductCard loading state pattern
ProductCard.loading() // Named constructor for shimmer placeholders

// Custom bottom nav pattern (not BottomNavigationBar)
BottomNavbar(
  items: [CustomBottomNavItem(...)],  // Custom wrapper
  floatingActionButton: FAB(),        // Integrated with BottomAppBar
)
```

### Error Handling
- Use `ErrorHandler.getReadableError(error)` for user-facing messages
- Filters sensitive info (Supabase URLs, JWT, API keys) from error messages
- Indonesian-language error messages (e.g., "Tidak ada koneksi internet")
- See `lib/utils/error_handler.dart` for implementation

### State Management
- **No state management package** - Pure `StatefulWidget` with `setState()`
- Refresh pattern: `_refresh()` method that sets `_isLoading = true`, fetches data, updates state
- Loading states: `_isLoading` boolean + `ProductCard.loading()` shimmer placeholders

### Styling Standards
- Primary color: `Color(0xFFDA1818)` (red)
- Font: Google Fonts Poppins (set globally in `main.dart`)
- Icons: `lucide_icons` package (NOT Material Icons)
- Rounded corners: 20-30px `BorderRadius.circular()`
- Low stock warning: `stock <= 3` shows red text + alert icon

## Environment Setup

### Required Files
1. Create `.env` from `.env.example`:
   ```bash
   cp .env.example .env
   # Add SUPABASE_URL and SUPABASE_ANON_KEY
   ```

2. Assets in `pubspec.yaml`:
   ```yaml
   assets:
     - assets/colorwpp.png
     - assets/app.png
     - assets/profile.jpg
     - .env  # MUST be included for dotenv
   ```

### Database Setup
- Import `database.sql` to Supabase
- Create storage bucket `productimage_bucket` with public access
- Default user password: `admin` (hashes to `8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918`)

## Development Workflows

### Running the App
```bash
flutter pub get
flutter run
# No build_runner or code generation needed
```

### Adding Products
- Flow: `AddProductPage` → `StorageService.uploadImage()` → `DatabaseService.createProduct()` → RPC creates product + initial stock_movement
- Images: Auto-compressed to WebP 80% quality before upload
- Form uses `SearchableDropdown` for category/vehicle_type selection

### Image Handling
- Upload: Returns filename only (not full URL)
- Display: `StorageService.getPublicUrl(filename)` generates public URL
- Delete: Must delete from storage bucket separately when deleting product

## Common Gotchas

1. **Product Stock**: Never query `products` table directly for stock - always use `get_products_with_stock()` RPC
2. **Image URLs**: Store filename in DB, generate public URL on read using `getPublicUrl()`
3. **Navigation**: Dashboard uses `PageRouteBuilder` with slide transitions, not `Navigator.pushNamed()`
4. **Session Check**: `LoadPage` checks `SessionService.getValidSession()` on app start, redirects to dashboard if valid
5. **Indonesian Locale**: All user-facing text in Indonesian (UI labels, errors, date formats)

## File Organization
```
lib/
  main.dart              # App entry, Supabase init, routes
  supabase_config.dart   # Env var loader with validation
  models/                # Data classes (no business logic)
  screens/               # Page-level widgets with state
  services/              # API/database/storage layers
  widgets/               # Reusable components
  utils/                 # Helpers (error_handler, formatters)
```

## Testing Notes
- No tests currently (`test/widget_test.dart` is boilerplate)
- Debug with `debugPrint()` in services
- Check Supabase dashboard for RPC function logs
