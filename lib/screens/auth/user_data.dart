import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  // ✅ Singleton — satu instance dipakai seluruh app
  static final UserData _instance = UserData._internal();
  factory UserData() => _instance;
  UserData._internal();

  String nama      = 'User';
  String email     = 'user@gmail.com';
  String noTelpon  = '088888888888';
  File?  fotoProfil;

  // ── Field yang dipakai di dashboard ──
  int    koin        = 0;
  double saldo       = 0;
  int    totalSetor  = 0;
  double beratTotal  = 0;

  bool _sudahLoad = false;

  // ── Reset flag agar load() membaca ulang dari SharedPreferences ──
  // Dipanggil dari DashboardScreen setelah kembali dari layar lain
  // (misal: MisiPageScreen, SetorSampahScreen) supaya koin/saldo
  // yang berubah di layar tersebut langsung tampil di dashboard.
  void resetLoadFlag() {
    _sudahLoad = false;
  }

  // ── Load dari SharedPreferences (hanya sekali, kecuali flag direset) ──
  Future<void> load() async {
    if (_sudahLoad) return;
    final prefs = await SharedPreferences.getInstance();

    nama     = prefs.getString('nama')     ?? 'User';
    email    = prefs.getString('email')    ?? 'user@gmail.com';
    noTelpon = prefs.getString('noTelpon') ?? '088888888888';

    koin       = prefs.getInt('koin')          ?? 0;
    saldo      = prefs.getDouble('saldo')      ?? 0;
    totalSetor = prefs.getInt('totalSetor')    ?? 0;
    beratTotal = prefs.getDouble('beratTotal') ?? 0;

    final fotoPath = prefs.getString('fotoProfil');
    if (fotoPath != null && File(fotoPath).existsSync()) {
      fotoProfil = File(fotoPath);
    }

    _sudahLoad = true;
  }

  // ── Simpan ke SharedPreferences ──
  Future<void> simpan() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('nama',     nama);
    await prefs.setString('email',    email);
    await prefs.setString('noTelpon', noTelpon);

    await prefs.setInt('koin',           koin);
    await prefs.setDouble('saldo',       saldo);
    await prefs.setInt('totalSetor',     totalSetor);
    await prefs.setDouble('beratTotal',  beratTotal);

    if (fotoProfil != null) {
      await prefs.setString('fotoProfil', fotoProfil!.path);
    } else {
      await prefs.remove('fotoProfil');
    }
  }

  // ── Helper: tambah koin & saldo setelah setor sampah ──
  Future<void> tambahSetor({
    required int koinDapat,
    required double rupiahDapat,
    required double berat,
  }) async {
    koin       += koinDapat;
    saldo      += rupiahDapat;
    totalSetor += 1;
    beratTotal += berat;
    await simpan();
  }

  // ── Helper: kurangi koin & tambah saldo setelah tukar koin ──
  Future<void> tukarKoin({
    required int koinDipakai,
    required double rupiahDapat,
  }) async {
    koin  -= koinDipakai;
    saldo += rupiahDapat;
    await simpan();
  }

  // ── Reset (untuk logout / testing) ──
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    nama       = 'User';
    email      = 'user@gmail.com';
    noTelpon   = '088888888888';
    fotoProfil = null;
    koin       = 0;
    saldo      = 0;
    totalSetor = 0;
    beratTotal = 0;
    _sudahLoad = false;
  }
}