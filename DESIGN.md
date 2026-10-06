# DESIGN.md — Setor.in Proyek 3

> **Sumber desain:** PRD Setor.in Proyek 3 v1.0, draft final untuk disetujui tim, 24 September 2026.  
> **Mitra:** Rumah Hijau  
> **Cakupan:** Mobile Nasabah, Web Petugas, Web Admin  
> **Dokumen ini:** menerjemahkan requirement PRD menjadi arahan UI/UX dan design system. Requirement bisnis dan acceptance criteria tetap mengacu pada PRD.

---

## 1. Tujuan Desain

Setor.in adalah sistem bank sampah digital untuk Rumah Hijau. Desain harus membuat tiga pengalaman utama terasa sederhana dan berbeda sesuai perannya:

1. **Nasabah — Mobile**
   - Melihat saldo rupiah.
   - Menunjukkan QR saat setor.
   - Melihat harga sampah dan riwayat.
   - Mengajukan tukar saldo.
   - Mendapat edukasi, jadwal, notifikasi, FAQ, dan chatbot AI.

2. **Petugas — Web**
   - Melakukan proses setor secepat mungkin.
   - Scan QR atau mencari nasabah.
   - Menginput beberapa jenis sampah dan berat desimal.
   - Memverifikasi transaksi.
   - Menampilkan struk.
   - Memantau transaksi dan rekap pengepul.

3. **Admin — Web**
   - Mengelola master data.
   - Mengelola nasabah dan petugas.
   - Mengatur harga beli/jual.
   - Menyetujui/menolak tukar saldo.
   - Mengelola edukasi dan audit log.

### Prinsip utama

- **Rupiah, bukan koin.**
- **Rumah Hijau adalah satu-satunya mitra bank sampah dalam Proyek 3.**
- **Status transaksi harus selalu terlihat jelas.**
- **Primary action harus mudah ditemukan.**
- **Input angka berat dan rupiah harus mudah dibaca.**
- **UI tidak boleh membuat petugas melakukan langkah yang tidak diperlukan.**
- **Bahasa antarmuka: Bahasa Indonesia.**
- **Gunakan format WIB dan format rupiah sesuai PRD.**

---

# 2. Scope UI/UX

## 2.1 Mobile Nasabah

### Fase F1
- Splash
- Login
- Registrasi
- OTP
- Lupa password
- Beranda
- QR nasabah
- Harga sampah
- Riwayat setoran
- Detail setoran
- Identitas visual Rumah Hijau

### Fase F2
- Google Sign-In
- Tukar saldo
- PIN
- Notifikasi
- Edukasi
- FAQ
- Lokasi & jadwal setor
- Chatbot AI
- Edit akun
- Riwayat tukar saldo

---

## 2.2 Web Petugas

### Fase F1
- Login
- Dashboard
- Setoran Baru
- Scan QR
- Cari nasabah
- Input multi-jenis sampah
- Verifikasi setoran
- Struk
- Transaksi hari ini
- Cek transaksi
- Data pengepul
- Export XLSX

### Fase F2
- Jadwal setor
- Override buka/tutup darurat

---

## 2.3 Web Admin

### Fase F1
- Login
- Dashboard minimum
- Nasabah
- Petugas
- Jenis sampah & harga
- Setoran
- Data pengepul

### Fase F2
- Persetujuan tukar saldo
- Edukasi
- Dashboard lengkap
- Audit log
- Penyempurnaan identitas visual

---

# 3. Information Architecture

## 3.1 Mobile

Struktur navigasi utama:

```text
Mobile
├── Beranda
│   ├── Saldo tersedia
│   ├── Saldo ditahan
│   ├── QR
│   ├── Status Rumah Hijau
│   ├── Setoran terakhir
│   └── Shortcut chatbot
│
├── Harga
│   └── Daftar jenis sampah
│
├── QR
│   └── QR nasabah + panduan setor
│
├── Edukasi
│   ├── Filter kategori
│   └── Detail artikel
│
└── Profil
    ├── Data akun
    ├── Riwayat transaksi
    ├── Notifikasi
    ├── FAQ
    ├── Lokasi & jadwal
    ├── PIN
    └── Logout

Floating Action
└── Chatbot AI
```

Bottom navigation yang direkomendasikan:

```text
[ Beranda ] [ Harga ] [ QR ] [ Edukasi ] [ Profil ]
```

QR ditempatkan sebagai pusat perhatian karena merupakan bagian penting dari alur setor.

---

## 3.2 Web Petugas

```text
Web Petugas
├── Dashboard
├── Setoran
│   ├── Setoran Baru
│   ├── Scan QR
│   └── Transaksi
├── Nasabah
├── Data Pengepul
├── Jadwal Setor
└── Profil / Logout
```

**Catatan:** Scan QR merupakan bagian dari Setoran Baru, bukan proses terpisah yang membuat alur baru.

---

## 3.3 Web Admin

```text
Web Admin
├── Dashboard
├── Nasabah
├── Petugas
├── Jenis Sampah & Harga
├── Setoran
├── Data Pengepul
├── Tukar Saldo
├── Edukasi
├── Audit Log
└── Profil / Logout
```

---

# 4. Design System

## 4.1 Identitas Visual

Logo utama menggunakan **logo Rumah Hijau** yang disediakan tim.

Arah visual:

- Natural
- Bersih
- Modern
- Terpercaya
- Ramah lingkungan
- Tidak terlalu "kartun"
- Tidak menggunakan visual koin/reward dari Proyek 2

### Warna

Karena PRD belum menetapkan hex color final, warna berikut merupakan **usulan design token**, bukan requirement bisnis.

```text
Primary      : #2E7D32
Primary Dark : #1B5E20
Primary Soft : #E8F5E9

Background   : #F7F9F7
Surface      : #FFFFFF

Text Primary : #1F2937
Text Muted   : #6B7280

Success      : #2E7D32
Warning      : #F59E0B
Danger       : #DC2626
Info         : #2563EB

Border       : #E5E7EB
```

Jika warna resmi Rumah Hijau tersedia, warna resmi harus menggantikan token usulan di atas.

---

## 4.2 Typography

Gunakan satu keluarga font yang konsisten pada satu platform.

### Mobile

Rekomendasi:

- **Manrope** atau font sans-serif modern yang setara.
- Hindari terlalu banyak weight.

Hierarchy:

```text
Display / Saldo besar : 28–32 px / Bold
H1                    : 24 px / Bold
H2                    : 20 px / Bold
H3                    : 18 px / SemiBold
Body                  : 14–16 px / Regular
Caption               : 12–13 px / Regular
Button                : 14–16 px / SemiBold
```

### Web

```text
Page Title            : 24 px / Bold
Section Title         : 18–20 px / SemiBold
Body                  : 14 px
Table                 : 13–14 px
Caption               : 12 px
Button                : 14 px / SemiBold
```

---

## 4.3 Spacing

Gunakan sistem 4 px / 8 px.

```text
4   = micro spacing
8   = tight spacing
12  = small spacing
16  = default spacing
24  = section spacing
32  = large spacing
40  = hero spacing
48+ = page-level spacing
```

---

## 4.4 Radius

```text
Small   : 8 px
Medium  : 12 px
Large   : 16 px
Card    : 16 px
Pill    : 999 px
```

Gunakan radius yang konsisten. Jangan mencampur banyak bentuk card pada halaman yang sama.

---

## 4.5 Elevation

Gunakan shadow secara ringan.

Prioritas:

1. Surface datar untuk sebagian besar card.
2. Shadow tipis untuk floating card.
3. Shadow lebih kuat hanya untuk modal/floating element.

Hindari efek glassmorphism berlebihan karena aplikasi membutuhkan keterbacaan data transaksi.

---

# 5. Component Library

## 5.1 Button

### Primary

Untuk aksi utama:

- Verifikasi Setoran
- Ajukan Tukar Saldo
- Simpan
- Login
- Daftar

### Secondary

Untuk aksi pendukung:

- Lihat Detail
- Petunjuk Arah
- Export
- Batal

### Destructive

Untuk:

- Nonaktifkan akun
- Batalkan setoran
- Tolak tukar saldo

Destructive action harus memiliki confirmation dialog jika menyebabkan perubahan data penting.

---

## 5.2 Input

Semua input harus mempunyai:

- Label
- Placeholder bila diperlukan
- Error state
- Helper text bila diperlukan

Untuk angka:

- Gunakan numeric keyboard pada mobile.
- Format berat mendukung dua desimal.
- Format rupiah tidak boleh ambigu.

Contoh:

```text
Berat
[ 1,25 ] kg
```

```text
Nominal
[ Rp50.000 ]
```

---

## 5.3 Status Badge

Gunakan status badge yang mudah dibedakan secara visual dan tetap mempunyai teks.

```text
MENUNGGU_VERIFIKASI → Warning
SELESAI              → Success
DIBATALKAN           → Danger

MENUNGGU             → Warning
DIPROSES             → Info
BERHASIL             → Success
DITOLAK              → Danger
GAGAL                → Danger

BUKA                  → Success
TUTUP                 → Neutral/Danger
```

Jangan hanya mengandalkan warna; status harus selalu ditulis.

---

## 5.4 Card

Card digunakan untuk:

- Saldo
- Status Rumah Hijau
- Setoran terakhir
- Harga sampah
- Artikel edukasi
- Jadwal setor
- Ringkasan transaksi

Card harus memiliki hierarchy:

```text
Label
Value utama
Informasi tambahan
Optional action
```

---

## 5.5 Modal / Dialog

Gunakan dialog untuk aksi yang membutuhkan konfirmasi.

Contoh:

```text
Verifikasi Setoran?

Pastikan berat dan jenis sampah
sudah benar.

Total:
Rp35.500

[Batal] [Verifikasi]
```

Untuk penolakan tukar saldo:

```text
Tolak Tukar Saldo

Alasan penolakan
[________________]

[ Batal ] [ Tolak ]
```

Alasan wajib.

---

# 6. Mobile UX Specification

# 6.1 Splash Screen

Isi:

- Logo Rumah Hijau
- Nama Setor.in
- Loading indicator ringan

Tujuan:

- Brand recognition
- Menunggu pemeriksaan sesi/token

Jangan membuat splash terlalu lama.

---

# 6.2 Login

Layout:

```text
Logo

Selamat datang di Setor.in
Kelola saldo hasil setoran sampah
dengan mudah.

Email
[________________]

Password
[________________]

[ Masuk ]

Lupa password?

──── atau ────

[ Lanjut dengan Google ]

Belum punya akun?
Daftar
```

Requirement:

- Email + password.
- Google Sign-In tersedia pada F2.
- Akun nonaktif tidak dapat login.

---

# 6.3 Registrasi

Field:

1. Nama
2. No. HP
3. Alamat
4. Email
5. Password
6. Konfirmasi password

CTA:

```text
[ Daftar ]
```

Setelah submit:

```text
Registrasi
→ OTP
→ Akun aktif
→ QR dibuat
→ Beranda
```

---

# 6.4 OTP

Tampilkan:

```text
Verifikasi Email

Kode OTP telah dikirim ke
email pengguna.

[ _ _ _ _ _ _ ]

Kirim ulang dalam 00:xx

[ Verifikasi ]
```

Aturan dari PRD:

- OTP 6 digit.
- Berlaku 5 menit.
- Maks. 5 percobaan.
- Resend cooldown 60 detik.

---

# 6.5 Beranda

Prioritas informasi:

```text
Header
├── Greeting
└── Notification icon

Saldo
├── Saldo tersedia
└── Saldo ditahan jika > 0

[ Tukar Saldo ]

Status Rumah Hijau
├── BUKA / TUTUP
├── Jadwal terdekat
└── [ Petunjuk Arah ]

[ Tampilkan QR ]

Setoran Terakhir
└── Transaction cards

Floating Chatbot
```

Saldo harus menjadi visual paling dominan karena merupakan value utama nasabah.

---

# 6.6 QR Nasabah

QR harus berukuran besar dan mudah dipindai webcam.

```text
QR Saya

Tunjukkan QR ini kepada
petugas Rumah Hijau.

        [ QR ]

Kode: XXXX-XXXX

Sebelum setor:
✓ Sampah bersih
✓ Sampah sudah dipilah
✓ Siapkan QR
```

QR berisi kode unik acak, bukan ID berurutan.

---

# 6.7 Harga Sampah

Tampilan:

```text
Harga Sampah

[ Semua ] [ Plastik ] [ Kertas ] ...

Botol Plastik
Plastik
Rp1.800 / kg
Diperbarui 24 Sep 2026

Kardus
Kertas
Rp1.500 / kg
Diperbarui 24 Sep 2026
```

Fokus mobile adalah **harga beli nasabah**, bukan harga jual pengepul.

---

# 6.8 Riwayat

Gunakan list dengan status yang jelas.

```text
24 Sep 2026 • 14:05 WIB

Botol Plastik + Kardus
2,50 kg

Rp4.500

[ SELESAI ]
```

Filter F2:

```text
Tanggal mulai
Tanggal akhir
Jenis transaksi
Status
```

---

# 6.9 Detail Setoran

Field minimum:

- ID transaksi
- Tanggal & jam
- Jenis sampah
- Berat
- Harga/kg
- Subtotal
- Total berat
- Total nilai
- Status

Gunakan tabel/list detail agar angka mudah diverifikasi.

---

# 6.10 Tukar Saldo

Flow:

```text
Input nominal
      ↓
Pilih Bank / E-wallet
      ↓
Isi tujuan
      ↓
Review
      ↓
PIN
      ↓
Saldo ditahan
      ↓
MENUNGGU
```

Validasi:

- Minimum Rp10.000.
- Tidak boleh melebihi saldo tersedia.
- Satu request aktif per nasabah.
- Tanpa biaya/potongan.

---

# 6.11 PIN

First-time:

```text
Buat PIN
[ _ _ _ _ _ _ ]

Konfirmasi PIN
[ _ _ _ _ _ _ ]

[ Simpan PIN ]
```

Security state:

```text
5x salah
↓
PIN terkunci
↓
15 menit
```

---

# 6.12 Notifikasi

Inbox:

```text
Notifikasi

[●] Setoran berhasil
    Setoran #ST-001 berhasil diverifikasi.
    5 menit lalu

[ ] Tukar saldo ditolak
    Alasan: ...
    Kemarin

[ ] Edukasi baru
    ...
```

Unread menggunakan dot/badge.

Push notification membuka halaman terkait.

---

# 6.13 Edukasi

Card:

```text
[ Cover Image ]

Cara Memilah Sampah
Lingkungan
24 Sep 2026
```

Detail:

```text
Judul
Kategori
Tanggal
Cover
Isi artikel
[ Tonton Video ] optional
```

---

# 6.14 FAQ

Gunakan accordion.

```text
Bagaimana cara setor sampah?
[ + ]

Bagaimana saldo bertambah?
[ + ]

Kapan Rumah Hijau buka?
[ + ]
```

---

# 6.15 Lokasi & Jadwal

```text
Rumah Hijau
Alamat lengkap

● BUKA

Jadwal terdekat
24 Oktober 2026
08:00 – 12:00

Catatan:
...

[ Petunjuk Arah ]

[ WhatsApp ] optional
```

Status dihitung server berdasarkan WIB.

---

# 6.16 Chatbot AI

Entry point:

- Floating button di mobile.
- Bisa juga diakses dari area bantuan.

Chat:

```text
Setor.in Assistant

Hai! Saya bisa membantu tentang
sampah, lingkungan, dan penggunaan
Setor.in.

User:
Apa saja sampah yang bisa disetor?

AI:
...
```

Aturan UI:

- Maksimum 500 karakter.
- Tampilkan typing/loading state.
- Tampilkan error yang jelas.
- Jika pertanyaan di luar topik, berikan fallback sopan.
- Beri keterangan bahwa jawaban bersifat umum.
- Jangan menampilkan data saldo/riwayat melalui chatbot.

---

# 7. Web Petugas UX

## 7.1 Prinsip utama

Target PRD:

> Satu setoran dengan sampai 3 jenis sampah, dari scan sampai verifikasi dan struk, selesai dalam kurang dari 2 menit.

Karena itu halaman Setoran Baru harus menjadi halaman paling efisien.

---

# 7.2 Dashboard Petugas

Top KPI:

```text
Transaksi Hari Ini
Total Berat
Pembelian dari Nasabah
Estimasi Penjualan
Estimasi Selisih
```

Di bawahnya:

- Transaksi terbaru
- Top nasabah berdasarkan berat
- Shortcut Setoran Baru

CTA utama:

```text
[ + Setoran Baru ]
```

---

# 7.3 Setoran Baru

Layout desktop:

```text
┌───────────────────────────────────────────────┐
│ Setoran Baru                                  │
├───────────────────┬───────────────────────────┤
│ Nasabah            │ Ringkasan                │
│                   │                           │
│ [ Scan QR ]       │ Total Berat               │
│ [ Cari Manual ]   │ 3,50 kg                   │
│                   │                           │
│ Nama              │ Total Nilai               │
│ No. HP            │ Rp8.500                   │
│ Alamat            │                           │
│                   │ [ Simpan Setoran ]        │
├───────────────────┴───────────────────────────┤
│ Rincian Sampah                                │
│ Jenis | Berat | Harga/kg | Subtotal           │
│ ...                                           │
│ [+ Tambah Jenis]                              │
└───────────────────────────────────────────────┘
```

Harga beli otomatis.

Subtotal:

```text
berat × harga beli
```

Berat mendukung dua desimal.

---

# 7.4 Scan QR

Gunakan webcam dengan `html5-qrcode`.

State:

```text
Meminta akses kamera
        ↓
Kamera aktif
        ↓
Scan QR
        ↓
Nasabah ditemukan
        ↓
Tampilkan identitas
```

Fallback:

```text
Tidak bisa menggunakan kamera?

[ Masukkan kode QR manual ]
```

---

# 7.5 Identitas Nasabah

Setelah QR berhasil:

```text
Nasabah ditemukan

Nama
Zakkiyah

No. HP
08xxxxxxxxxx

Alamat
...

[ Ganti Nasabah ]
```

Tujuan: petugas memastikan orang yang benar sebelum input transaksi.

---

# 7.6 Status Menunggu Verifikasi

Setelah klik Simpan:

```text
Setoran #ST-0001

MENUNGGU VERIFIKASI

Rincian:
...

[ Edit Setoran ]
[ Batalkan Setoran ]
[ Verifikasi ]
```

Jika dibatalkan, wajib meminta alasan.

Setoran SELESAI tidak dapat diedit.

---

# 7.7 Verifikasi

Confirmation dialog harus menampilkan:

- Nama nasabah
- Jenis sampah
- Berat
- Harga/kg
- Total nilai

CTA:

```text
[ Kembali ]
[ Verifikasi Setoran ]
```

Saat berhasil, dalam satu transaksi:

- status menjadi SELESAI
- saldo bertambah
- mutasi saldo tercatat
- notifikasi dibuat

---

# 7.8 Struk

Struk langsung tampil setelah verifikasi.

```text
SETOR.IN
RUMAH HIJAU

ID Transaksi
ST-0001

Nama
...

No. HP
...

Alamat
...

Rincian
Botol Plastik   2,00 kg × Rp1.800 = Rp3.600
Kardus          1,50 kg × Rp1.500 = Rp2.250

Total Berat
3,50 kg

Total Nilai
Rp5.850

24 Sep 2026 14:05 WIB
```

CTA:

```text
[ Kembali ke Setoran Baru ]
```

Jika implementasi cetak diperlukan, gunakan layout yang juga aman untuk print.

---

# 7.9 Transaksi

Table columns:

```text
ID
Nasabah
No. HP
Alamat
Tipe Sampah
Berat
Nilai
Status
Tanggal
Aksi
```

Fitur:

- Search
- Date filter
- Status filter
- Detail
- Cek transaksi nasabah
- Export XLSX

---

# 7.10 Data Pengepul

Tampilkan:

```text
Periode: [ tanggal ] – [ tanggal ]

Jenis Sampah
Total Berat
Harga Beli
Harga Jual
Total Nilai Jual
Estimasi Selisih
```

Formula:

```text
Nilai Jual = Σ(berat × harga jual snapshot)

Estimasi Selisih =
Nilai Jual - Nilai Beli
```

Jangan membuat UI yang menyiratkan stok aktual karena PRD belum mencakup pencatatan pengurangan stok.

---

# 7.11 Jadwal Setor

Form:

```text
Tanggal
Jam buka
Jam tutup
Catatan

[ ] Override tutup darurat

[ Simpan Jadwal ]
```

Mobile membaca jadwal ini dan menghitung status BUKA/TUTUP berdasarkan WIB.

---

# 8. Web Admin UX

## 8.1 Dashboard

KPI:

```text
Total Nasabah
Total Kg Setoran Bulan Ini
Total Nilai Setoran
Total Saldo Nasabah
Permintaan Tukar Saldo Menunggu
```

Gunakan card KPI + tabel aktivitas.

---

# 8.2 Kelola Nasabah

Table:

```text
Nama
Email
No. HP
Status
Saldo
Tanggal Daftar
Aksi
```

Detail:

```text
Profil
Saldo tersedia
Saldo ditahan
Riwayat setoran
Riwayat tukar saldo
```

Saldo tidak boleh diedit manual.

---

# 8.3 Kelola Petugas

Action:

- Buat
- Edit
- Nonaktifkan
- Reset password

Status:

```text
AKTIF
NONAKTIF
```

---

# 8.4 Jenis Sampah & Harga

Table:

```text
Jenis
Kategori
Harga Beli
Harga Jual
Status
Updated
Aksi
```

Form:

```text
Nama
Kategori
Harga beli/kg
Harga jual/kg
Status aktif

[ Simpan ]
```

Jika harga jual < harga beli:

```text
⚠ Harga jual lebih rendah dari harga beli.
```

Simpan riwayat perubahan harga.

---

# 8.5 Persetujuan Tukar Saldo

Table:

```text
Kode
Nasabah
Nominal
Tujuan
Status
Tanggal
Aksi
```

Detail harus memperlihatkan:

- Nasabah
- Nominal
- Jenis tujuan
- Nama bank/e-wallet
- Nomor tujuan
- Nama pemilik
- Saldo
- Status

Action:

```text
[ Setujui ]
[ Tolak ]
```

Tolak membutuhkan alasan.

---

# 8.6 Edukasi

CMS sederhana:

```text
Judul
Kategori
Cover
Isi rich text
Video URL
Status: Draft / Terbit
```

Saat artikel pertama kali diterbitkan, sistem mengirim notifikasi edukasi baru.

---

# 8.7 Audit Log

Read-only.

Table:

```text
Waktu
User
Aksi
Entitas
ID
Ringkasan Perubahan
IP
```

Gunakan expandable detail untuk `data_lama` dan `data_baru`.

---

# 9. Responsive Rules

## Mobile

Target:

- Android 8.0+
- Fokus portrait.
- Touch target minimum sekitar 44–48 px.
- Hindari tabel lebar.
- Gunakan bottom navigation.
- Gunakan bottom sheet bila lebih natural daripada modal penuh.

## Web

Target:

- Desktop.
- Chrome/Edge terbaru.
- Minimum comfortable width sekitar 1024 px.
- Sidebar persistent.
- Table menggunakan horizontal scroll jika data tidak dapat dipadatkan tanpa kehilangan informasi.

---

# 10. Empty, Loading, Error & Success States

Setiap screen data-driven wajib mempunyai state berikut:

```text
Loading
Empty
Success
Error
```

## Empty

Contoh riwayat:

```text
Belum ada transaksi

Setoran kamu akan muncul di sini
setelah transaksi berhasil.
```

## Error

Jangan:

```text
Error 500
```

Gunakan:

```text
Data belum dapat dimuat

Periksa koneksi internet dan coba lagi.

[ Coba Lagi ]
```

## Success

Gunakan feedback singkat:

```text
Setoran berhasil diverifikasi.
Saldo kamu telah diperbarui.
```

---

# 11. Accessibility & Usability

- Jangan menggunakan warna sebagai satu-satunya indikator.
- Gunakan label dan icon secara bersamaan.
- Kontras teks harus memadai.
- Error harus menjelaskan cara memperbaiki input.
- Primary action konsisten.
- Hindari istilah teknis backend pada UI.
- Gunakan Bahasa Indonesia.
- Angka rupiah dan berat harus mudah dipindai secara visual.

---

# 12. Data Formatting

Ikuti BR-19 secara konsisten.

### Rupiah

```text
Rp1.800
Rp10.000
Rp125.500
```

### Berat

```text
1,25 kg
0,50 kg
10,00 kg
```

### Date time

```text
24 Sep 2026 14:05 WIB
```

Timezone:

```text
Asia/Jakarta
```

---

# 13. Security UX

Jangan tampilkan informasi sensitif secara berlebihan.

## PIN

- Jangan pernah menampilkan PIN.
- Input menggunakan masked field.
- Beri feedback ketika PIN salah.
- Setelah 5 kali salah, tampilkan waktu lock 15 menit.

## Rekening / E-wallet

Gunakan masking jika memungkinkan:

```text
BCA
****1234
```

## OTP

- Jangan tampilkan OTP di UI selain input yang diberikan user.
- Jangan menampilkan OTP dari API.
- Jangan menampilkan OTP di error/log.

---

# 14. Critical User Flows

## 14.1 Registrasi

```text
Splash
 ↓
Register
 ↓
Input Data
 ↓
OTP
 ↓
Akun Aktif
 ↓
QR Dibuat
 ↓
Beranda
```

## 14.2 Setor Sampah

```text
Nasabah menunjukkan QR
 ↓
Petugas Scan
 ↓
Identitas Nasabah
 ↓
Input Jenis + Berat
 ↓
Simpan
 ↓
MENUNGGU_VERIFIKASI
 ↓
Verifikasi
 ↓
SELESAI
 ↓
Saldo Bertambah
 ↓
Notifikasi
 ↓
Struk
```

## 14.3 Tukar Saldo

```text
Tukar Saldo
 ↓
Input Nominal
 ↓
Pilih Tujuan
 ↓
Review
 ↓
PIN
 ↓
Saldo Ditahan
 ↓
MENUNGGU
 ↓
Admin
 ├── Tolak → Saldo Kembali
 └── Setujui
       ↓
     Simulasi → BERHASIL
       atau
     Payout → DIPROSES → BERHASIL/GAGAL
```

## 14.4 Chatbot

```text
Open Chatbot
 ↓
Input ≤ 500 karakter
 ↓
Backend
 ↓
Gemini
 ↓
Jawaban
```

Jika out of scope:

```text
Pertanyaan di luar topik
 ↓
Fallback
 ↓
FAQ / Kontak Rumah Hijau
```

---

# 15. Design Constraints

Jangan memasukkan kembali fitur Proyek 2:

- Koin
- Misi
- Reward
- Harga koin
- Banyak bank sampah

Jangan membuat:

- Pencairan uang sungguhan sebagai requirement wajib.
- Pendaftaran nasabah oleh petugas.
- iOS.
- Play Store distribution.
- Google Maps SDK.
- Chatbot yang membaca saldo atau riwayat pribadi.

---

# 16. Screen Checklist

## Mobile F1

- [ ] Splash
- [ ] Login
- [ ] Register
- [ ] OTP
- [ ] Forgot Password
- [ ] Home
- [ ] QR
- [ ] Harga Sampah
- [ ] Riwayat Setoran
- [ ] Detail Setoran

## Mobile F2

- [ ] Google Login
- [ ] Tukar Saldo
- [ ] Review Tukar Saldo
- [ ] Input PIN
- [ ] Kelola PIN
- [ ] Notifikasi
- [ ] Edukasi
- [ ] Detail Edukasi
- [ ] FAQ
- [ ] Lokasi
- [ ] Jadwal
- [ ] Chatbot
- [ ] Edit Akun

## Web Petugas F1

- [ ] Login
- [ ] Dashboard
- [ ] Setoran Baru
- [ ] Scan QR
- [ ] Cari Nasabah
- [ ] Input Multi Sampah
- [ ] Menunggu Verifikasi
- [ ] Verifikasi
- [ ] Struk
- [ ] Transaksi
- [ ] Detail Transaksi
- [ ] Data Pengepul
- [ ] Export XLSX

## Web Petugas F2

- [ ] Jadwal Setor
- [ ] Override Buka/Tutup

## Web Admin F1

- [ ] Login
- [ ] Dashboard
- [ ] Nasabah
- [ ] Detail Nasabah
- [ ] Petugas
- [ ] Jenis Sampah
- [ ] Harga
- [ ] Riwayat Harga
- [ ] Setoran
- [ ] Data Pengepul

## Web Admin F2

- [ ] Tukar Saldo
- [ ] Detail Tukar Saldo
- [ ] Edukasi
- [ ] Dashboard Lengkap
- [ ] Audit Log

---

# 17. Acceptance Checklist untuk Design

Desain dianggap siap diimplementasikan jika:

- [ ] Semua screen F1 mempunyai flow lengkap.
- [ ] Primary action setiap screen jelas.
- [ ] Semua status transaksi mempunyai visual + teks.
- [ ] Semua form memiliki validation/error state.
- [ ] Empty/loading/error state tersedia.
- [ ] Format rupiah sesuai PRD.
- [ ] Format berat dua desimal.
- [ ] Format waktu WIB.
- [ ] QR mudah dipindai.
- [ ] Alur setor dapat dilakukan tanpa langkah UI yang tidak diperlukan.
- [ ] Struk memuat seluruh field P-04.
- [ ] Tukar saldo menampilkan saldo tersedia/ditahan dengan jelas.
- [ ] Chatbot tidak mengesankan bahwa ia dapat mengakses data pribadi.
- [ ] Tidak ada fitur koin, misi, reward, atau multi-bank-sampah.
- [ ] Desain menggunakan identitas Rumah Hijau setelah asset resmi tersedia.

---

# 18. Design-to-Development Handoff

Setiap screen yang masuk development harus mempunyai:

1. Nama screen.
2. Tujuan screen.
3. Entry point.
4. Primary action.
5. Secondary action.
6. Semua state:
   - loading
   - empty
   - error
   - success
   - disabled
7. Validasi form.
8. Navigation destination.
9. Data yang ditampilkan.
10. Permission/security requirement jika ada.

Contoh handoff:

```text
Screen: Setoran Baru

Role:
Petugas

Entry:
Sidebar → Setoran Baru

Primary action:
Simpan Setoran

Dependencies:
- Data nasabah
- Jenis sampah aktif
- Harga beli aktif

States:
- Initial
- QR scanning
- Nasabah selected
- Input item
- Saving
- Menunggu verifikasi
- Error

Next:
Verifikasi / Batalkan / Edit
```

---

# 19. Source of Truth

Prioritas ketika terjadi konflik:

1. **PRD Setor.in Proyek 3**
2. Requirement/acceptance criteria yang disetujui tim
3. DESIGN.md ini untuk keputusan visual dan UX
4. Implementasi kode

Jika DESIGN.md bertentangan dengan PRD, **PRD harus menang** dan DESIGN.md harus diperbarui.

---

# 20. Catatan yang Belum Final

PRD masih menyatakan beberapa data perlu disediakan tim/mitra:

- Logo Rumah Hijau
- Alamat lengkap dan koordinat
- Daftar jenis sampah
- Harga beli dan jual awal
- Tanggal setor Oktober dan November 2026
- Nomor WhatsApp Rumah Hijau
- Artikel edukasi awal
- FAQ awal

Jangan mengunci data tersebut ke desain sebagai data final sebelum diberikan.

---

## Referensi Requirement

Dokumen ini diturunkan dari:

- PRD Setor.in Proyek 3 v1.0
- Bagian 2 — Tujuan & Ruang Lingkup
- Bagian 3 — Peran Pengguna & Hak Akses
- Bagian 5 — Perubahan dari Proyek 2
- Bagian 6 — Aturan Bisnis
- Bagian 7 — Kebutuhan Fungsional Mobile
- Bagian 8 — Kebutuhan Fungsional Web Petugas
- Bagian 9 — Kebutuhan Fungsional Web Admin
- Bagian 10 — Alur Utama
- Bagian 14 — Kebutuhan Non-Fungsional
- Bagian 17 — Kriteria Penerimaan
- Bagian 18 — Data yang Dibutuhkan

**End of DESIGN.md**
