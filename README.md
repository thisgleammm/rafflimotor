# 🏍️ Raffli Motor - Aplikasi Manajemen Bengkel Motor

Aplikasi manajemen bengkel motor yang membantu Anda mengelola inventori sparepart, transaksi penjualan, dan layanan servis dengan mudah dan efisien.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue)
![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-green)
![License](https://img.shields.io/badge/License-Private-red)

---

## 📋 Table of Contents

- [Features](#-features)
- [Screenshots](#-screenshots)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Running the App](#-running-the-app)
- [Build](#-build)
- [Project Structure](#-project-structure)
- [Documentation](#-documentation)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

---

## ✨ Features

### 📦 Manajemen Inventori
- ✅ CRUD produk sparepart
- ✅ Manajemen stok dengan history
- ✅ Kategori dan tipe kendaraan
- ✅ Upload gambar produk
- ✅ Alert stok rendah

### 💰 Transaksi Penjualan
- ✅ 3 tipe transaksi: Servis, Sparepart, Servis + Sparepart
- ✅ Generate nota PDF otomatis
- ✅ Multiple payment methods (Cash, Transfer, QRIS)
- ✅ Auto-update stok setelah penjualan
- ✅ Histori transaksi lengkap

### 📊 Dashboard & Analytics
- ✅ Summary pendapatan bulanan
- ✅ Chart penjualan mingguan
- ✅ Daftar penjualan hari ini
- ✅ Alert stok rendah
- ✅ Auto-refresh setelah transaksi

### 🔐 Keamanan
- ✅ Login dengan session management
- ✅ Password hashing (SHA-256)
- ✅ Session token validation
- ✅ Auto logout setelah 7 hari
- ✅ Audit trail logging

---

## 📱 Screenshots

> **Note**: Tambahkan screenshots aplikasi di sini

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** 3.9.2 - Cross-platform framework
- **Dart** 3.9.2 - Programming language
- **Lucide Icons** - Modern icon library
- **Google Fonts** - Typography
- **FL Chart** - Data visualization

### Backend
- **Supabase** - Backend as a Service
- **PostgreSQL** - Database
- **Supabase Storage** - File storage untuk gambar & PDF
- **Supabase Auth** - Authentication (custom implementation)

### Libraries
- `supabase_flutter` - Supabase client
- `shared_preferences` - Local storage
- `image_picker` - Image selection
- `pdf` - PDF generation
- `printing` - PDF printing
- `table_calendar` - Calendar widget
- `package_info_plus` - App version info

---

## 📋 Prerequisites

Sebelum install, pastikan Anda sudah install:

### Required
- ✅ **Flutter SDK** >= 3.9.2
  ```bash
  flutter --version
  ```
  Download: https://flutter.dev/docs/get-started/install

- ✅ **Dart SDK** >= 3.9.2 (included with Flutter)

- ✅ **Git**
  ```bash
  git --version
  ```

### For Android Development
- ✅ **Android Studio** atau **Android SDK**
- ✅ **Java JDK** 11 atau lebih tinggi
- ✅ **Android Emulator** atau device fisik

### For iOS Development (Mac only)
- ✅ **Xcode** 14 atau lebih tinggi
- ✅ **CocoaPods**
  ```bash
  sudo gem install cocoapods
  ```
- ✅ **iOS Simulator** atau device fisik

### Optional
- **VS Code** dengan Flutter extension
- **Android Studio** dengan Flutter plugin

---

## 🚀 Installation

### 1. Clone Repository

```bash
git clone <repository-url>
cd raffli_motor
```

### 2. Install Dependencies

```bash
# Install Flutter dependencies
flutter pub get

# For iOS (Mac only)
cd ios
pod install
cd ..
```

### 3. Setup Supabase

#### a. Create Supabase Project
1. Buka https://supabase.com
2. Create new project
3. Simpan **Project URL** dan **Anon Key**

#### b. Setup Database
1. Di Supabase Dashboard → **SQL Editor**
2. Jalankan file SQL berikut secara berurutan:

```sql
-- 1. Create tables
-- Copy & paste isi dari: database.sql

-- 2. Create users
-- Copy & paste isi dari: create_users.sql

-- 3. Update sales schema (optional, jika ada)
-- Copy & paste isi dari: update_sales_schema.sql
```

#### c. Setup Storage
1. Di Supabase Dashboard → **Storage**
2. Create 2 buckets:
   - `products` (untuk gambar produk)
   - `receipts` (untuk nota PDF)
3. Set policy **public read** untuk kedua bucket

---

## ⚙️ Configuration

### 1. Create `.env` File

Buat file `.env` di root project:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**Cara mendapatkan credentials:**
1. Buka Supabase Dashboard
2. Settings → API
3. Copy **Project URL** dan **anon public** key

### 2. Update `pubspec.yaml` (Optional)

Jika ingin update dependencies ke versi terbaru:

```bash
flutter pub upgrade
```

### 3. Setup Assets

Pastikan folder `assets` berisi:
- `app.png` - Logo aplikasi
- `colorwpp.png` - Background image
- `profile.jpg` - Default profile image

---

## 🏃 Running the App

### Development Mode

```bash
# Run di device/emulator yang terhubung
flutter run

# Pilih device spesifik
flutter devices  # Lihat list devices
flutter run -d <device-id>

# Run dengan hot reload
flutter run --debug
```

### Simulator/Emulator

#### iOS Simulator (Mac only)
```bash
open -a Simulator
flutter run
```

#### Android Emulator
```bash
# Buka emulator dari Android Studio
# Atau via command line:
emulator -avd <avd-name>
flutter run
```

### Physical Device

#### Android
1. Enable **Developer Options** dan **USB Debugging**
2. Connect device via USB
3. Run: `flutter run`

#### iOS (Mac only)
1. Connect device via USB
2. Trust computer di iPhone
3. Setup signing di Xcode (lihat [Build](#-build))
4. Run: `flutter run`

---

## 📦 Build

### Android APK

```bash
# Debug APK (untuk testing)
flutter build apk --debug

# Release APK (untuk distribusi)
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (untuk Play Store)

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS App

```bash
# Build tanpa code signing (untuk testing build process)
flutter build ios --release --no-codesign

# Build dengan signing (untuk device/App Store)
flutter build ios --release

# Output: build/ios/iphoneos/Runner.app
```

#### Setup iOS Code Signing

1. Buka Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Select **Runner** → **Signing & Capabilities**

3. Centang **"Automatically manage signing"**

4. Pilih **Team** (Apple ID atau Developer account)

5. Build ulang:
   ```bash
   flutter build ios --release
   ```

---

## 📁 Project Structure

```
raffli_motor/
├── android/                 # Android native code
├── ios/                     # iOS native code
├── lib/                     # Dart source code
│   ├── models/             # Data models
│   │   ├── category.dart
│   │   ├── product_with_stock.dart
│   │   ├── sale.dart
│   │   └── ...
│   ├── screens/            # UI screens
│   │   ├── dashboard_page.dart
│   │   ├── add_sales_page.dart
│   │   ├── history_page.dart
│   │   ├── stock_page.dart
│   │   └── ...
│   ├── services/           # Business logic
│   │   ├── auth_service.dart
│   │   ├── database_service.dart
│   │   └── ...
│   ├── widgets/            # Reusable widgets
│   │   ├── custom_snackbar.dart
│   │   ├── bottom_navbar.dart
│   │   └── ...
│   └── main.dart           # App entry point
├── assets/                 # Images, fonts, etc
├── .env                    # Environment variables (GITIGNORED)
├── pubspec.yaml            # Dependencies
├── function.md             # Function documentation
├── README.md               # This file
└── database.sql            # Database schema
```

---

## 📚 Documentation

### Function Documentation
Lihat [`function.md`](function.md) untuk dokumentasi lengkap semua function:
- Database Functions (RPC, Triggers)
- AuthService methods
- DatabaseService methods
- Widget APIs

### API Documentation
- **Supabase**: https://supabase.com/docs
- **Flutter**: https://flutter.dev/docs
- **Dart**: https://dart.dev/guides

---

## 🔧 Troubleshooting

### Common Issues

#### 1. `flutter pub get` gagal
```bash
# Clear cache
flutter clean
flutter pub get
```

#### 2. Build Android gagal
```bash
# Update Gradle
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 3. Build iOS gagal (Mac only)
```bash
# Update pods
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

#### 4. Supabase connection error
- Cek `.env` file sudah benar
- Cek internet connection
- Cek Supabase project masih aktif

#### 5. Image picker tidak berfungsi

**Android**: Tambahkan permission di `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**iOS**: Tambahkan di `Info.plist`
```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan akses kamera untuk foto produk</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi memerlukan akses galeri untuk foto produk</string>
```

---

## 🐛 Known Issues

### Android
- ⚠️ Java source/target version 8 warning (tidak mempengaruhi fungsionalitas)

### iOS
- ⚠️ Build tanpa code signing tidak bisa di-install ke device fisik
- ⚠️ Perlu Apple Developer account untuk distribusi

---

## 🔐 Security

### Environment Variables
**JANGAN commit file `.env` ke Git!**

File `.env` sudah ada di `.gitignore`. Pastikan tidak ter-commit.

### Credentials
- Password di-hash dengan SHA-256
- Session token random 32 bytes
- Session expire 7 hari
- Supabase RLS enabled

---

## 📝 Development Workflow

### 1. Create Feature Branch
```bash
git checkout -b feat/nama-fitur
```

### 2. Development
```bash
flutter run  # Test di emulator
```

### 3. Testing
```bash
flutter test
flutter analyze
```

### 4. Commit
```bash
git add .
git commit -m "feat: deskripsi fitur"
```

### 5. Push
```bash
git push origin feat/nama-fitur
```

### 6. Create Pull Request
Buat PR di GitHub/GitLab

---

## 🤝 Contributing

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` before commit
- Run `flutter analyze` untuk check issues

### Commit Message Format
```
<type>: <description>

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Code style (formatting)
- refactor: Code refactoring
- test: Testing
- chore: Maintenance
```

---

## 📄 License

Private - All rights reserved

---

## 👨‍💻 Developer

**Raffli Motor Team**

- Email: support@rafflimotor.com
- Website: https://rafflimotor.com

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev)
- [Supabase Team](https://supabase.com)
- [Lucide Icons](https://lucide.dev)
- [Google Fonts](https://fonts.google.com)

---

## 📞 Support

Jika ada pertanyaan atau issue:

1. Check [Troubleshooting](#-troubleshooting)
2. Check [function.md](function.md) untuk dokumentasi function
3. Create issue di repository
4. Contact developer team

---

## 🗺️ Roadmap

### v1.1.0 (Coming Soon)
- [ ] Export laporan ke Excel
- [ ] Multi-user support
- [ ] Role-based access control
- [ ] Backup & restore database
- [ ] Dark mode

### v1.2.0 (Future)
- [ ] WhatsApp notification
- [ ] Barcode scanner
- [ ] Customer management
- [ ] Supplier management
- [ ] Purchase order

---

## 📊 Version History

### v1.0.0 (Current)
- ✅ Manajemen inventori sparepart
- ✅ Transaksi penjualan & servis
- ✅ Generate nota PDF
- ✅ Dashboard analytics
- ✅ Histori penjualan
- ✅ Auto-refresh after transaction
- ✅ Dynamic app version

---

**Made with ❤️ using Flutter**
