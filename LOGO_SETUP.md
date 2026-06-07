# 📱 Panduan Setup Logo Aplikasi Setor.In

## ✅ Perubahan yang Sudah Dilakukan

### 1. Nama Aplikasi
- ✅ Android: Diubah menjadi "Setor.In" di `AndroidManifest.xml`
- ✅ iOS: Diubah menjadi "Setor.In" di `Info.plist`
- ✅ Web Backend Admin: Diubah menjadi "Setor.in Admin"
- ✅ Web Backend Petugas: Diubah menjadi "Setor.in Petugas"

### 2. Konfigurasi Logo
- ✅ Ditambahkan flutter_launcher_icons di `pubspec.yaml`
- ✅ Web backend sudah dikonfigurasi untuk menggunakan logo

---

## 🎯 Langkah yang Perlu Anda Lakukan

### A. Untuk Aplikasi Mobile

#### 1. Simpan Logo ke Folder Assets
Simpan logo Anda dengan nama **`logo.png`** ke folder:
```
c:\xampp1\htdocs\setorin_mobile\assets\images\logo.png
```

#### 2. Generate Icon Launcher
Setelah menyimpan logo, jalankan command berikut di terminal:

```bash
cd c:\xampp1\htdocs\setorin_mobile
flutter pub get
flutter pub run flutter_launcher_icons
```

Command ini akan otomatis:
- Generate icon untuk berbagai ukuran (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Update icon launcher untuk Android
- Update icon launcher untuk iOS

#### 3. Test Aplikasi
```bash
flutter run
```

---

### B. Untuk Web Backend (Laravel)

#### 1. Buat Folder Images
Buat folder `images` di dalam `public`:
```bash
cd c:\xampp1\htdocs\SetorIn
mkdir public\images
```

#### 2. Simpan Logo
Simpan logo Anda dengan nama **`logo.png`** ke folder:
```
c:\xampp1\htdocs\SetorIn\public\images\logo.png
```

#### 3. Test Backend
Akses backend Anda:
- Admin: `http://localhost/SetorIn/public/admin`
- Petugas: `http://localhost/SetorIn/public/petugas`

Logo akan muncul di sidebar dan header.

---

## 📝 Catatan Penting

### Untuk Logo Mobile:
- **Format**: PNG dengan background transparan (recommended)
- **Ukuran**: Minimal 1024x1024 px
- **Rasio**: 1:1 (persegi)
- Logo Anda yang ada sudah cocok dengan simbol recycle dan dollar sign hijau

### Untuk Logo Web:
- Logo yang sama akan digunakan
- Tinggi logo sudah diset ke 2.5rem (sekitar 40px)
- Logo akan otomatis responsive

---

## 🔧 Troubleshooting

### Jika flutter_launcher_icons Gagal:
```bash
# Install ulang dependencies
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
```

### Jika Logo Web Tidak Muncul:
1. Pastikan file ada di `public/images/logo.png`
2. Clear cache Laravel:
```bash
php artisan cache:clear
php artisan view:clear
```

---

## 📦 File yang Diubah

### Mobile:
- ✅ `pubspec.yaml` - Konfigurasi dependencies dan launcher icons
- ✅ `android/app/src/main/AndroidManifest.xml` - Nama aplikasi Android
- ✅ `ios/Runner/Info.plist` - Nama aplikasi iOS

### Web Backend:
- ✅ `app/Providers/Filament/AdminPanelProvider.php` - Logo dan nama admin panel
- ✅ `app/Providers/Filament/PetugasPanelProvider.php` - Logo dan nama petugas panel

---

## ✨ Hasil Akhir

Setelah semua langkah selesai:
- 📱 Aplikasi mobile akan bernama **"Setor.In"** dengan logo hijau recycle
- 🌐 Web admin akan menampilkan **"Setor.in Admin"** dengan logo
- 🌐 Web petugas akan menampilkan **"Setor.in Petugas"** dengan logo
- 📲 Icon launcher di Android & iOS akan menggunakan logo baru
