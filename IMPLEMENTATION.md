# Setor.in Mobile — Rencana Implementasi & Penyelesaian Project

Dokumen ini merangkum **alur bisnis**, **status fitur**, dan **langkah yang disarankan** agar aplikasi Flutter nasabah selesai dengan maksimal dan selaras dengan backend (SetorIn) + web Admin/Petugas.

---

## 1. Alur bisnis (yang disepakati)

```text
[Nasabah di rumah]
  → Buka app: lihat lokasi bank sampah, jam buka, harga, edukasi
  → (Opsional) pilih bank sampah mitra

[Nasabah di bank sampah — MANUAL]
  → Bawa sampah fisik
  → Tunjukkan QR kartu nasabah ke petugas

[Petugas — web Filament]
  → Scan QR → verifikasi identitas
  → Input jenis & berat sampah → simpan transaksi
  → Status: "Menunggu Konfirmasi" (belum ada koin)

[Nasabah — mobile]
  → Terima notifikasi
  → Tap "Konfirmasi Setoran"
  → Status transaksi: Selesai → koin masuk ke akun

[Nasabah — mobile]
  → Tukar koin → saldo
  → Ajukan tarik saldo → admin approve di web
```

**Catatan:** Setor sampah **tidak** dilakukan lewat form digital di rumah. Transaksi resmi hanya lewat petugas + konfirmasi nasabah.

---

## 2. Peta layar aplikasi (navigasi saat ini)

| Layar | File | Terhubung dari app? | Integrasi API |
|-------|------|---------------------|---------------|
| Login | `login_screen.dart` | Ya (entry) | ✅ |
| Register | `register_screen.dart` | Ya | ✅ |
| OTP | `otp_screen.dart` | Ya | ✅ (resend OTP ❌) |
| Dashboard | `dashboard_screen.dart` | Ya | ✅ |
| Setor Sampah + QR | `setor_sampah_screen.dart` | Ya (menu utama) | ✅ profil, harga bank |
| Cek Bank Sampah | `cek_bank_sampah_screen.dart` | Ya | ✅ list (pilih bank ❌) |
| Target / Misi | `misi_page_screen.dart` | Ya | ⚠️ lokal (SharedPreferences) |
| Notifikasi + konfirmasi | `notifikasi_screen.dart` | Ya | ✅ konfirmasi transaksi |
| Aktivitas | `aktivitas_screen.dart` | Ya | ✅ |
| Edukasi | `edukasi_screen.dart` | Ya | ✅ (+ fallback lokal) |
| Profil | `profil_screen.dart` | Ya | ✅ baca |
| Edit profil | `edit_profil_screen.dart` | Ya | ❌ hanya UserData lokal |
| Keuangan | `keuangan_screen.dart` | Ya (tab) | ⚠️ saldo/koin lokal |
| Tukar koin | `tukar_koin_screen.dart` | Ya (dari keuangan) | ❌ lokal |
| Tarik saldo | `tarik_saldo_screen.dart` | Ya | ❌ lokal |
| Reset / new password | `resetpassword_screen.dart`, `new_password_screen.dart` | Ya | ❌ TODO |
| ~~Laporan sampah~~ | ~~dihapus~~ | — | — |
| Misi harian | `misi_harian_screen.dart` | ❌ tidak dipanggil | ❌ dummy |
| Penargetan sampah | `penargetan_sampah_screen.dart` | ❌ tidak dipanggil | ❌ |

---

## 3. Yang sudah selesai (jangan rusak)

- [x] Auth: login, register, verify OTP
- [x] Dashboard: saldo, koin, ringkasan, aktivitas singkat (dari API)
- [x] QR nasabah unik (`SETORIN:NASABAH:{id}`) + dialog perbesar
- [x] Scan QR di web petugas (backend `NasabahQrCode`)
- [x] Alur konfirmasi transaksi: petugas input → notifikasi → nasabah konfirmasi → koin masuk
- [x] Notifikasi list dari API
- [x] Cek bank sampah (lokasi, jam, harga dari API)
- [x] Edukasi dari API
- [x] Aktivitas dari API
- [x] CI/CD build APK + Telegram (split ABI arm64)

---

## 4. Prioritas penyelesaian (urutan disarankan)

### Fase A — Konfigurasi & stabilitas (1–2 hari)

**A1. Base URL API (wajib)**

File: `lib/services/api_service.dart`

| Environment | Contoh `baseUrl` |
|-------------|------------------|
| Emulator Android | `http://10.0.2.2:8000/api` |
| HP fisik (Wi-Fi sama dengan PC) | `http://<IP-LAN-PC>:8000/api` |
| Production (VPS) | `https://<domain-anda>/api` |

Saran: pakai konstanta per flavor atau file config terpisah (`api_config.dart`) agar tidak salah push IP lokal ke production.

**A2. Deploy backend terbaru ke VPS**

Pastikan di server sudah:

```bash
php artisan migrate   # termasuk notifikasi: id_transaksi, memerlukan_konfirmasi
```

**A3. Tes alur inti (checklist demo)**

1. Register + OTP nasabah baru  
2. Login → Setor Sampah → QR tampil  
3. Petugas scan QR → input transaksi → simpan  
4. Nasabah: Notifikasi → **Konfirmasi Setoran**  
5. Dashboard: koin bertambah  
6. Web petugas: status **Selesai**

---

### Fase B — Integrasi keuangan (penting, 2–3 hari)

Saat ini `keuangan_screen`, `tukar_koin`, `tarik_saldo` banyak memakai **UserData lokal** — bisa tidak sama dengan database setelah transaksi petugas.

| Task | API backend | File Flutter |
|------|-------------|--------------|
| B1. Load saldo & koin real-time | `GET /nasabah/saldo` | `api_service.dart`, `keuangan_screen.dart`, `dashboard_screen.dart` |
| B2. Tukar koin | `POST /nasabah/saldo/tukar-koin` | `tukar_koin_screen.dart` atau sheet di keuangan |
| B3. Ajukan tarik saldo | `POST /nasabah/saldo/tarik` | `tarik_saldo_screen.dart` |
| B4. Riwayat penarikan | dari response `GET /saldo` | tampilkan status: pending / disetujui / ditolak |

Setelah Fase B: setiap kembali ke dashboard/keuangan, panggil API (bukan hanya `UserData` cache).

---

### Fase C — Data nasabah & bank (1–2 hari)

| Task | API | File |
|------|-----|------|
| C1. Pilih bank sampah mitra | `POST /nasabah/bank-sampah/pilih` | `cek_bank_sampah_screen.dart` (saat user pilih/tap konfirmasi) |
| C2. Update profil | `PUT /nasabah/profil` | `edit_profil_screen.dart` |
| C3. Logout server | `POST /logout` | `profil_screen.dart` + hapus token lokal |
| C4. Riwayat transaksi setor | `GET /nasabah/transaksi` | layar baru atau tab di aktivitas |

---

### Fase D — Misi & engagement (opsional untuk tugas, 2–3 hari)

| Task | Keterangan |
|------|------------|
| D1. Misi dari API | `GET /nasabah/misi`, `POST /nasabah/misi/{id}/klaim` → ganti dummy di `misi_harian_screen` atau integrasi ke `misi_page_screen` |
| D2. Bersihkan layar tidak terpakai | Pertimbangkan hapus atau hubungkan: `misi_harian_screen.dart`, `penargetan_sampah_screen.dart` jika tidak dipakai di demo |
| D3. Target sampah | `misi_page_screen` + `target_sampah_screen` — putuskan: fitur tugas (lokal OK) atau sync API misi |

---

### Fase E — Auth lengkap & polish (1–2 hari)

| Task | Backend perlu? | Mobile |
|------|----------------|--------|
| E1. Kirim ulang OTP | Endpoint resend (belum ada) | `otp_screen.dart` |
| E2. Lupa / reset password | Endpoint forgot/reset (belum ada) | `resetpassword_screen.dart`, `new_password_screen.dart` |
| E3. Loading & error UI | — | semua layar API: spinner, SnackBar error |
| E4. Pull-to-refresh | — | dashboard, notifikasi, aktivitas |
| E5. Handle token expired | — | redirect ke login jika API 401 |

---

## 5. Sinkronisasi dengan web Admin & Petugas

| Aksi di web | Dampak ke mobile | Status |
|-------------|------------------|--------|
| Petugas input transaksi | Notifikasi konfirmasi | ✅ |
| Nasabah konfirmasi | Koin masuk | ✅ |
| Admin approve penarikan | Nasabah harus lihat di riwayat/tarik | ❌ perlu Fase B |
| Admin buat misi | Misi di app | ❌ perlu Fase D |
| Admin kirim notifikasi | List notifikasi | ✅ |
| Admin kelola harga/edukasi | Harga & edukasi di app | ✅ |

---

## 6. File yang disarankan diubah (ringkas)

```
lib/
├── services/
│   └── api_service.dart          ← tambah method + baseUrl production
├── screens/auth/
│   ├── keuangan_screen.dart      ← Fase B
│   ├── tukar_koin_screen.dart    ← Fase B
│   ├── tarik_saldo_screen.dart   ← Fase B
│   ├── cek_bank_sampah_screen.dart ← Fase C1
│   ├── edit_profil_screen.dart   ← Fase C2
│   ├── profil_screen.dart        ← logout API
│   ├── dashboard_screen.dart     ← reload saldo dari API
│   ├── notifikasi_screen.dart    ← sudah OK
│   └── setor_sampah_screen.dart  ← sudah OK
```

**Backend (SetorIn)** — jika perlu Fase E:

- `AuthController`: resend OTP, forgot password, reset password
- Pastikan `GET /nasabah/saldo` mengembalikan struktur yang mudah dipakai Flutter

---

## 7. Quality checklist sebelum dianggap “selesai”

### Fungsional

- [ ] Login / register / OTP di HP fisik ke server production/staging  
- [ ] QR bisa di-scan petugas  
- [ ] Konfirmasi notifikasi → koin naik di dashboard  
- [ ] Tukar koin mengurangi koin & menambah saldo di server  
- [ ] Tarik saldo tercatat & status terbaca setelah admin approve  
- [ ] Pilih bank sampah tersimpan di profil nasabah  

### Non-fungsional

- [ ] Tidak ada hardcode IP di build release (gunakan URL VPS)  
- [ ] APK release ter-build di GitHub Actions  
- [ ] Tidak ada layar “mati” yang membingungkan penguji (hapus atau hubungkan)  
- [ ] Pesan error dalam Bahasa Indonesia yang jelas  

### Dokumentasi tugas

- [ ] Screenshot alur: QR → petugas → konfirmasi → koin  
- [ ] Akun demo: 1 nasabah, 1 petugas, 1 admin  
- [ ] URL backend + cara menjalankan mobile  

---

## 8. Estimasi waktu (kasar)

| Fase | Estimasi | Impact demo tugas |
|------|----------|-------------------|
| A — Config & tes alur inti | 1–2 hari | ⭐⭐⭐⭐⭐ |
| B — Keuangan API | 2–3 hari | ⭐⭐⭐⭐⭐ |
| C — Profil & bank & riwayat | 1–2 hari | ⭐⭐⭐⭐ |
| D — Misi API | 2–3 hari | ⭐⭐⭐ |
| E — Auth + polish | 1–2 hari | ⭐⭐⭐ |

**Minimum viable untuk demo bagus:** selesaikan **A + B + C1 + C4**.

---

## 9. Yang sudah dihapus

- `lib/screens/auth/laporan_sampah_screen.dart` — tidak terhubung navigasi & tidak sesuai alur setor manual di bank.

---

## 10. Langkah Anda berikutnya (action items)

1. Baca dokumen ini dan tentukan deadline demo/tugas.  
2. Kerjakan **Fase A** hari ini (URL API + migrate VPS + tes QR → konfirmasi).  
3. Kerjakan **Fase B** agar saldo/koin di app = database.  
4. Opsional: minta bantuan implement per fase (mis. “lanjut Fase B”) — sebutkan fase agar perubahan terfokus.  

---

*Terakhir diperbarui: mengacu pada alur konfirmasi nasabah, penghapusan layar laporan sampah, dan audit integrasi API per Maret 2026.*
