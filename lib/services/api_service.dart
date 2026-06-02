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
}
