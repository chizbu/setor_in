# Setor.in — Mobile Nasabah

Aplikasi Flutter Android untuk nasabah Rumah Hijau. Aplikasi mobile mengonsumsi REST API Laravel. File `.env` backend hanya dibaca server Laravel; mobile tidak memuat `.env` dan menerima URL API sebagai compile-time value.

## Setup lokal

1. Pasang Flutter stable dan Android SDK (target produk min. Android 8 / API 26).
2. Jalankan `flutter pub get`.
3. Tentukan URL API saat menjalankan aplikasi:

   ```sh
   # Android Emulator yang mengakses backend di komputer host
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
   ```

   Untuk perangkat fisik, gunakan IP LAN mesin backend. Untuk build rilis, gunakan URL HTTPS API yang benar:

   ```sh
   flutter build apk --release --dart-define=API_BASE_URL=https://<domain-api>/api
   ```

Jika `API_BASE_URL` tidak diberikan, build development memakai default emulator `http://10.0.2.2:8000/api`. CI menerima URL rilis dari GitHub Actions repository variable `API_BASE_URL` dan menolak tag rilis bila URL HTTPS belum dikonfigurasi. URL endpoint bersifat publik, bukan secret. **Jangan pernah menyimpan key atau kredensial server di aplikasi Flutter/APK** karena dapat diekstrak; `.env` Laravel tetap hanya untuk backend.

## Validasi

```sh
flutter pub get
flutter analyze
flutter test
flutter run -d <device>
```

## Status integrasi Proyek 3

Lihat [UPGRADE_NOTES.md](UPGRADE_NOTES.md) untuk audit endpoint backend saat ini dan integrasi PRD yang masih membutuhkan dukungan backend.
