# Status Upgrade Mobile Setor.in terhadap PRD

Dokumen ini mencatat kondisi branch upgrade mobile terhadap kontrak pada `PRD.md` dan hasil pemeriksaan repository backend `haris3n/setorin_backend`. **Status “parsial/terblokir” berarti aplikasi tidak memalsukan data atau keberhasilan ketika backend belum menyediakan kemampuan yang dibutuhkan.**

Default endpoint aplikasi dan fallback build Android release: `https://setorin.my.id/api`.

## Perubahan yang sudah diterapkan pada mobile

- Registrasi meminta nama, nomor HP, alamat, email, password, dan konfirmasi; validasi password mengikuti minimal 8 karakter PRD.
- Profil dapat mengubah nama, nomor HP, dan alamat; email ditampilkan read-only. Perubahan dan foto disimpan lokal segera; jika API gagal, layar menandai perubahan menunggu sinkronisasi. Foto disimpan sebagai bytes agar tidak bergantung pada path file sementara.
- Beranda hanya menampilkan saldo Rupiah dari field `tersedia`/`saldo_tersedia`/`saldo_rupiah` backend; tidak mengartikan field `jumlah_saldo` atau koin Proyek 2 sebagai Rupiah. Saldo ditahan hanya ditampilkan jika backend mengirim fieldnya.
- Harga dan riwayat memakai data backend yang tersedia; data harga hanya dicari pada mitra bernama Rumah Hijau. Timestamp harga tidak diganti dengan waktu perangkat.
- Riwayat memiliki detail jenis, berat, harga/kg, subtotal, status dan tanggal bila field itu ada di response backend; total uang tidak dihitung dari koin.
- Kartu QR tidak membuat QR berbasis ID berurutan atau kode palsu. Jika server tidak memberikan kode unik, aplikasi menyatakannya.
- Konten edukasi memakai API; error dan daftar kosong memiliki state tersendiri, tanpa fallback artikel/sample buatan.
- FAQ di aplikasi memakai panduan alur Proyek 3 dan menghapus nomor telepon/email support yang tidak terverifikasi.
- Inbox tidak lagi menampilkan filter koin atau tombol konfirmasi setoran nasabah yang bertentangan dengan flow petugas. Badge merah statis di Beranda dihapus.
- OTP tidak memiliki tombol kirim ulang palsu. Lupa password tidak lagi berpura-pura mengirim OTP setelah jeda buatan.
- Aplikasi mobile **tidak memakai `.env`**. URL API publik diberikan saat build memakai `--dart-define=API_BASE_URL=...`; rahasia backend tetap hanya di server.

## Matriks kebutuhan mobile

| ID PRD | Status di branch mobile | Catatan / dependency |
|---|---|---|
| M-01 Registrasi | **Parsial** | Field dan validasi client tersedia. Aktivasi OTP hanya akan berfungsi aman bila backend mengirim email OTP, memiliki masa berlaku dan pembatasan percobaan. Backend yang diperiksa masih memiliki perilaku OTP development; jangan rilis produksi sebelum diperbaiki. |
| M-02 Login dan sesi | **Parsial** | Client memakai login token dan logout API existing, tetapi endpoint dan payload masih kontrak legacy Proyek 2. |
| M-03 Lupa password | **Terblokir backend** | Tidak ada endpoint reset-password/OTP reset yang dapat dipakai; UI sekarang menjelaskan keterbatasan dan tidak mensimulasikan sukses. |
| M-04 Google Sign-In | **Terblokir backend** | Belum ada alur token Google/tautan akun di backend dan client. |
| M-05 Beranda dan tabungan | **Parsial** | Profil/riwayat memakai route lama; saldo legacy sengaja tidak ditampilkan sebagai Rupiah. Backend perlu saldo tersedia/ditahan, notifikasi belum dibaca, dan akses chatbot. |
| M-06 QR dan panduan setor | **Parsial** | Panduan setor ditampilkan. Backend saat ini belum menyediakan identitas QR acak non-sensitif sesuai BR-16, sehingga QR nyata tidak bisa muncul sampai API mengirimkannya. |
| M-07 Harga sampah | **Parsial** | Harga aktif dibaca dari data bank sampah existing untuk Rumah Hijau. Backend belum memiliki struktur kategori PRD; waktu hanya ditampilkan jika timestamp record tersedia. |
| M-08 Riwayat transaksi | **Parsial** | Detail dirender dari field `detail` existing jika tersedia. Backend legacy menyimpan `total_koin`, bukan snapshot nilai Rupiah/total setoran F1; nominal transaksi tidak boleh disimpulkan dari kolom koin. |
| M-09 Tarik Saldo | **UI review; submit terblokir backend** | Form bank/e-wallet mengikuti pola grid tiga kolom Project 2 dan persyaratan tujuan/nominal pada PRD. Pengajuan, saldo ditahan, PIN, dan status transaksi tetap menunggu endpoint F2; mobile tidak mensimulasikan pengajuan sukses. |
| M-10 PIN | **Terblokir backend** | Alur PRD memerlukan PIN 6 digit sebelum pengajuan; API setup/verifikasi/ganti/reset PIN, retry lock, serta masa lock belum tersedia/terverifikasi. Jangan menyimpan PIN hanya di perangkat atau menampilkan sukses palsu. |
| M-11 Notifikasi | **Parsial** | Inbox membaca route existing. Backend perlu status baca/tandai-baca yang persisten, pemicu F2 dan FCM/device-token. |
| M-12 Edukasi | **Parsial** | Daftar dari API admin dengan loading/error/empty state. Backend belum membuktikan seluruh metadata PRD (kategori, gambar sampul, isi/video) di endpoint yang ada. |
| M-13 FAQ | **Selesai di mobile** | FAQ statis/akordeon tersedia. Kontak Rumah Hijau hanya ditampilkan jika server menyediakan nomor pada halaman lokasi. |
| M-14 Lokasi dan jadwal | **Parsial** | Memilih mitra berdasarkan nama Rumah Hijau, mengambil alamat/jadwal yang tersedia, dan membatasi tombol WhatsApp bila nomor ada. API belum menyediakan status BUKA/TUTUP server-side, jadwal terdekat dengan catatan, atau refresh berkala 60 detik sesuai PRD. |
| M-15 Chatbot AI | **Parsial** | Flutter UI, batas input 500 karakter, riwayat lokal, penghapusan saat logout, endpoint Sanctum/role nasabah, rate limit 10/menit, privacy filter, FAQ context, dan Gemini Interactions client sudah tersedia. Uji live Gemini masih menunggu `GEMINI_API_KEY` di environment backend; API key tidak dimasukkan ke mobile atau commit. |
| M-16 Edit akun | **Parsial** | Nama, nomor HP, alamat dapat diedit; email read-only. Ganti password dan PIN belum dapat dihubungkan karena endpoint backend belum tersedia. |
| M-18 Pencarian lokasi tunai | **Selesai di mobile; discovery only** | Agen tarik tunai, Alfamart, dan Indomaret membuka pencarian Google Maps; Rumah Hijau membuka detail mitra/petunjuk arah. Tidak ada permintaan atau pembayaran tunai dan hasil Maps bukan daftar mitra payout terverifikasi. |

## Backend blocker sebelum acceptance PRD

1. Migrasikan API dari kontrak legacy Proyek 2 ke kontrak Proyek 3 tanpa mengembalikan field koin/misi sebagai saldo.
2. Amankan OTP: kirim melalui email, jangan mengirim `otp_dev`/kode debug pada response produksi, tambah expiry, resend dan rate-limit; implementasikan lupa-password.
3. Buat kode QR acak permanen yang tidak memuat ID berurutan dan kirimkan ke profil nasabah.
4. Implementasikan ledger Rupiah: snapshot harga saat transaksi, saldo tersedia/ditahan, pembatalan dan aturan status transaksi.
5. Tambahkan API transfer/PIN, notifikasi in-app/FCM, edukasi admin sesuai metadata PRD, status/jadwal Rumah Hijau, serta edit password/PIN. Konfigurasikan `GEMINI_API_KEY` pada secret environment backend sebelum uji live chatbot.
6. Tambahkan contract/integration tests lintas client-backend; widget tests mobile tidak menggantikan uji OTP, saldo, transaksi, notifikasi, ataupun integrasi API.

## Validasi pada mobile

- `flutter test`: **6 widget/regression tests lulus** pada branch ini, termasuk chatbot privacy copy.
- `dart analyze lib test`: **No issues found**.
- `flutter build web --release --dart-define=API_BASE_URL=https://api.example.invalid/api`: build berhasil; URL `.invalid` adalah placeholder uji kompilasi, bukan endpoint produksi.
- Backend: PHPUnit terfokus `ChatPrivacyFilterTest`, `GeminiChatServiceTest`, dan `ChatbotApiTest` lulus **4 tests / 8 assertions** dengan APP_KEY sementara untuk test.
- Suite Laravel penuh masih memiliki kegagalan terpisah pada `PengumumanTest::filament form persists author and validates period` (assertion `after_or_equal`); kode pengumuman tersebut tidak diubah pada pekerjaan chatbot ini.
- Android SDK dan emulator tidak tersedia pada sandbox saat verifikasi; APK belum diuji install/run lokal. Flutter Web release build berhasil; ada warning non-blocking dari dependensi `share_plus` terkait dry-run WebAssembly.
- Tidak tersedia `GEMINI_API_KEY` atau file `.env` backend lokal, jadi request live ke Google Gemini belum diuji. API key harus diatur pada secret environment backend dan tidak boleh dimasukkan ke APK.
