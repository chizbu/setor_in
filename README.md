# Setor.in — aplikasi mobile nasabah Rumah Hijau

Upgrade Proyek 2 ini mempertahankan Flutter dan mengarahkan pengalaman nasabah ke alur Setor.in Proyek 3. Aplikasi menampilkan saldo Rupiah, proses setor melalui QR, harga Rumah Hijau, edukasi, riwayat, lokasi/jadwal, notifikasi, FAQ, chatbot, dan pengajuan tukar saldo.

## Menjalankan aplikasi

- Flutter stable (Dart 3.6 atau kompatibel) dan Android SDK.
- Install dependencies: `flutter pub get`
- Jalankan analyzer: `flutter analyze`
- Jalankan tests: `flutter test`
- Jalankan aplikasi: `flutter run --dart-define=API_BASE_URL=https://<host-api>/api/v1`

`API_BASE_URL` wajib menunjuk ke API Laravel yang menerapkan kontrak di PRD Bagian 12. Aplikasi **tidak** menyertakan endpoint lokal atau data transaksi/harga palsu; tanpa server terkonfigurasi, layar yang memerlukan data menampilkan status koneksi/error dan aksi coba lagi.

## Perubahan utama

- Navigasi nasabah lima tujuan: Beranda, Harga, QR, Edukasi, Profil.
- Beranda memprioritaskan saldo tersedia/ditahan, status Rumah Hijau, setoran terbaru, akses QR, riwayat, notifikasi, FAQ, tukar saldo, dan asisten.
- Alur QR menampilkan kode acak dari profil API (tidak dibuat dari ID berurutan oleh klien) serta panduan setor empat langkah.
- Registrasi menambahkan alamat wajib, pemeriksaan format email, konfirmasi password, dan minimum password 8 karakter; OTP memakai jeda kirim ulang 60 detik.
- Layar baru: daftar harga API, QR, chatbot (maks. 500 karakter, riwayat lokal terbatas 10 pesan sebagai konteks), FAQ statis, lokasi/jadwal dengan pembaruan berkala, dan form tukar saldo dengan minimum Rp10.000, PIN enam digit, saldo tersedia, serta tujuan tersimpan.
- Notifikasi nasabah tidak lagi meminta konfirmasi setoran; status baca dikirim ke API.
- Tema visual diperbarui dengan palet natural, hierarchy dan spacing lebih teratur, komponen Material 3, serta states loading/empty/error/retry.
- Ikon launcher memakai simbol daur ulang dan tunas tanpa simbol uang. Ini adalah placeholder aplikasi, bukan logo resmi Rumah Hijau; ganti saat aset branding resmi tersedia.
- API base URL tidak lagi tertanam ke alamat loopback. Autentikasi, profil, edukasi, riwayat, lokasi, saldo, notifikasi, chatbot, dan tukar saldo menggunakan kontrak `/api/v1` yang diusulkan PRD.

## Batas integrasi yang perlu diketahui

PRD menempatkan backend Laravel di repository lain dan hanya menyebut kontrak API usulan. Implementasi mobile ini mengirim request sesuai kontrak tersebut, tetapi tidak dapat membuktikan alur end-to-end tanpa backend yang menerapkan endpoint dan skema respons yang sama. Khususnya, endpoint QR, saldo, tujuan tersimpan, lokasi/jadwal, chatbot, tukar saldo, baca notifikasi, email OTP, dan profil harus tersedia di server.

Konfigurasi Firebase/FCM dan Google Sign-In (termasuk project Firebase, OAuth client, SHA-1 dan izin Android), serta izin notifikasi Android 13+, juga belum tersedia pada repository ini; karenanya push notification/Google Sign-In/native device delivery belum diklaim selesai. Aplikasi menampilkan status server yang tersedia dan tidak meniru keberhasilan transaksi secara lokal.
