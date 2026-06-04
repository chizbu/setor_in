import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti IP di bawah dengan IP Address Komputer Anda di Jaringan Wi-Fi
  // 192.168.1.6 adalah IP Wi-Fi Anda saat ini dari hasil ipconfig.
  static const String baseUrl = 'https://setorin.my.id/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        // Simpan token ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        
        // Simpan data user tambahan jika diperlukan
        if (data['user'] != null) {
          await prefs.setString('user_name', data['user']['nama'] ?? '');
          await prefs.setString('user_email', data['user']['email'] ?? '');
          await prefs.setString('user_role', data['user']['role'] ?? '');
        }
        
        return {'success': true, 'message': 'Login berhasil'};
      } else {
        return {
          'success': false, 
          'message': data['message'] ?? 'Login gagal, periksa kredensial Anda'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String noTelepon,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'no_telepon': noTelepon,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 && data['status'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        // Jika error dari validasi laravel (422)
        if (data['errors'] != null) {
          final errorValues = (data['errors'] as Map).values.first;
          return {'success': false, 'message': errorValues[0] ?? 'Terjadi kesalahan'};
        }
        return {'success': false, 'message': data['message'] ?? 'Registrasi gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String kodeOtp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'kode_otp': kodeOtp,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'OTP tidak valid atau sudah kadaluwarsa'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia, silakan login ulang.'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal mengambil data dashboard'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> getAktivitas() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia, silakan login ulang.'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/aktivitas'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal mengambil data aktivitas'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  /// GET /api/nasabah/edukasi — Artikel edukasi dari Admin
  Future<Map<String, dynamic>> getEdukasi() async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak tersedia'};
      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/edukasi'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil edukasi'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  /// GET /api/nasabah/notifikasi — Notifikasi nasabah
  Future<Map<String, dynamic>> getNotifikasi() async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak tersedia'};
      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/notifikasi'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil notifikasi'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  /// GET /api/nasabah/profil — Profil nasabah lengkap
  Future<Map<String, dynamic>> getProfil() async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak tersedia'};
      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/profil'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil profil'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  /// PUT /api/nasabah/profil — Update profil nasabah
  Future<Map<String, dynamic>> updateProfil(Map<String, String> fields) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak tersedia'};
      final response = await http.put(
        Uri.parse('$baseUrl/nasabah/profil'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(fields),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'data': data['data'] ?? {}};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal memperbarui profil'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  /// GET /api/nasabah/bank-sampah — Daftar Bank Sampah aktif
  Future<Map<String, dynamic>> getBankSampah() async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak tersedia'};
      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/bank-sampah'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil data bank sampah'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  /// POST /api/nasabah/transaksi/{id}/konfirmasi — Konfirmasi setoran dari petugas
  Future<Map<String, dynamic>> konfirmasiTransaksi(int idTransaksi) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak tersedia'};

      final response = await http.post(
        Uri.parse('$baseUrl/nasabah/transaksi/$idTransaksi/konfirmasi'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Setoran berhasil dikonfirmasi',
          'data': data['data'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengonfirmasi transaksi',
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  /// POST /api/nasabah/bank-sampah/pilih — Pilih bank sampah sebagai mitra
  Future<Map<String, dynamic>> pilihBankSampah(int idBankSampah) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak tersedia'};

      final response = await http.post(
        Uri.parse('$baseUrl/nasabah/bank-sampah/pilih'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'id_bank_sampah': idBankSampah}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'message': data['message'] ?? 'Bank sampah berhasil dipilih'};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal memilih bank sampah'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  /// POST /api/logout — Logout dan hapus token di server
  Future<Map<String, dynamic>> logoutServer() async {
    try {
      final token = await getToken();
      if (token == null) {
        // Tetap hapus data lokal meski token tidak ada
        await logout();
        return {'success': true, 'message': 'Berhasil keluar'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Hapus data lokal apapun response dari server
      await logout();

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'message': data['message'] ?? 'Berhasil keluar'};
      }
      return {'success': true, 'message': 'Berhasil keluar'};
    } catch (e) {
      // Tetap hapus lokal meski request gagal (misal offline)
      await logout();
      return {'success': true, 'message': 'Berhasil keluar (offline)'};
    }
  }

  /// GET /api/nasabah/transaksi — Riwayat transaksi penyetoran
  Future<Map<String, dynamic>> getRiwayatTransaksi({int page = 1}) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak tersedia'};

      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/transaksi?page=$page'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil riwayat transaksi'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  // Fungsi untuk mengambil token (bisa dipanggil di fungsi lain yang butuh token)
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fungsi Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }

  /// GET /api/nasabah/saldo — Ambil saldo, koin, dan riwayat penarikan
  Future<Map<String, dynamic>> getSaldo() async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak tersedia'};
      
      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/saldo'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengambil saldo'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  /// POST /api/nasabah/saldo/tukar-koin — Tukar koin menjadi saldo
  Future<Map<String, dynamic>> tukarKoin(int jumlahKoin) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak tersedia'};
      
      final response = await http.post(
        Uri.parse('$baseUrl/nasabah/saldo/tukar-koin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'jumlah_koin': jumlahKoin}),
      );
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal menukar koin'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  /// POST /api/nasabah/saldo/tarik — Ajukan penarikan saldo (dengan PIN)
  Future<Map<String, dynamic>> ajukanPenarikan({
    required double jumlahTarik,
    required String metodeBayar,
    required String noRekening,
    required String pin,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak tersedia'};
      
      final response = await http.post(
        Uri.parse('$baseUrl/nasabah/saldo/tarik'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'jumlah_tarik': jumlahTarik,
          'metode_bayar': metodeBayar,
          'no_rekening': noRekening,
          'pin': pin,
        }),
      );
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengajukan penarikan'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  /// POST /api/nasabah/saldo/set-pin — Set atau ubah PIN transaksi
  Future<Map<String, dynamic>> setPin({
    required String pin,
    String? pinLama,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token tidak tersedia'};
      
      final body = <String, dynamic>{'pin': pin};
      if (pinLama != null) body['pin_lama'] = pinLama;

      final response = await http.post(
        Uri.parse('$baseUrl/nasabah/saldo/set-pin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal menyimpan PIN'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }
}

