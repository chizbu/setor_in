import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  // ✅ Singleton — satu instance dipakai seluruh app
  static final UserData _instance = UserData._internal();
  factory UserData() => _instance;
  UserData._internal();

  String nama = 'User';
  String email = 'User@gmail.com';
  String noTelpon = '088888888888';
  File? fotoProfil;

  bool _sudahLoad = false;

  // ── Load dari SharedPreferences (hanya sekali) ──
  Future<void> load() async {
    if (_sudahLoad) return;
    final prefs = await SharedPreferences.getInstance();
    nama = prefs.getString('nama') ?? 'User';
    email = prefs.getString('email') ?? 'User@gmail.com';
    noTelpon = prefs.getString('noTelpon') ?? '088888888888';
    final fotoPath = prefs.getString('fotoProfil');
    if (fotoPath != null && File(fotoPath).existsSync()) {
      fotoProfil = File(fotoPath);
    }
    _sudahLoad = true;
  }

  // ── Simpan ke SharedPreferences ──
  Future<void> simpan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama', nama);
    await prefs.setString('email', email);
    await prefs.setString('noTelpon', noTelpon);
    if (fotoProfil != null) {
      await prefs.setString('fotoProfil', fotoProfil!.path);
    } else {
      await prefs.remove('fotoProfil');
    }
  }
}