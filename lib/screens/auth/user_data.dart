import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static final UserData _instance = UserData._internal();
  factory UserData() => _instance;
  UserData._internal();

  String nama = '';
  String email = '';
  String noTelpon = '';
  String alamat = '';
  Uint8List? fotoProfil;
  bool profileNeedsSync = false;

  // Legacy-only fields retained for screens that still read existing local data.
  int koin = 0;
  double saldo = 0;
  double saldoTertahan = 0;
  int totalSetor = 0;
  double beratTotal = 0;
  bool hasPin = false;

  bool _sudahLoad = false;

  void resetLoadFlag() => _sudahLoad = false;

  Future<void> load() async {
    if (_sudahLoad) return;
    final prefs = await SharedPreferences.getInstance();

    nama = prefs.getString('nama') ?? '';
    email = prefs.getString('email') ?? '';
    noTelpon = prefs.getString('noTelpon') ?? '';
    alamat = prefs.getString('alamat') ?? '';
    profileNeedsSync = prefs.getBool('profileNeedsSync') ?? false;

    koin = prefs.getInt('koin') ?? 0;
    saldo = prefs.getDouble('saldo') ?? 0;
    saldoTertahan = prefs.getDouble('saldoTertahan') ?? 0;
    totalSetor = prefs.getInt('totalSetor') ?? 0;
    beratTotal = prefs.getDouble('beratTotal') ?? 0;
    hasPin = prefs.getBool('hasPin') ?? false;

    final encodedPhoto = prefs.getString('fotoProfilBase64');
    if (encodedPhoto == null || encodedPhoto.isEmpty) {
      fotoProfil = null;
    } else {
      try {
        fotoProfil = base64Decode(encodedPhoto);
      } on FormatException {
        fotoProfil = null;
        await prefs.remove('fotoProfilBase64');
      }
    }
    // Remove obsolete temporary file paths saved by older app versions.
    await prefs.remove('fotoProfil');
    _sudahLoad = true;
  }

  Future<void> simpan() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('nama', nama);
    await prefs.setString('email', email);
    await prefs.setString('noTelpon', noTelpon);
    await prefs.setString('alamat', alamat);
    await prefs.setBool('profileNeedsSync', profileNeedsSync);

    await prefs.setInt('koin', koin);
    await prefs.setDouble('saldo', saldo);
    await prefs.setDouble('saldoTertahan', saldoTertahan);
    await prefs.setInt('totalSetor', totalSetor);
    await prefs.setDouble('beratTotal', beratTotal);
    await prefs.setBool('hasPin', hasPin);

    if (fotoProfil != null && fotoProfil!.isNotEmpty) {
      await prefs.setString('fotoProfilBase64', base64Encode(fotoProfil!));
    } else {
      await prefs.remove('fotoProfilBase64');
    }
    await prefs.remove('fotoProfil');
    _sudahLoad = true;
  }

  Future<void> tambahSetor({
    required int koinDapat,
    required double rupiahDapat,
    required double berat,
  }) async {
    koin += koinDapat;
    saldo += rupiahDapat;
    totalSetor += 1;
    beratTotal += berat;
    await simpan();
  }

  Future<void> tukarKoin({
    required int koinDipakai,
    required double rupiahDapat,
  }) async {
    koin -= koinDipakai;
    saldo += rupiahDapat;
    await simpan();
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    nama = '';
    email = '';
    noTelpon = '';
    alamat = '';
    fotoProfil = null;
    profileNeedsSync = false;
    koin = 0;
    saldo = 0;
    saldoTertahan = 0;
    totalSetor = 0;
    beratTotal = 0;
    hasPin = false;
    _sudahLoad = false;
  }
}
