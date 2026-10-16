import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // This is a public endpoint, not a secret. Never embed server credentials here.
  static String get baseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://setorin.my.id/api',
      ).replaceAll(RegExp(r'/$'), '');

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
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String alamat,
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
          'alamat': alamat,
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
          return {
            'success': false,
            'message': errorValues[0] ?? 'Terjadi kesalahan'
          };
        }
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
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
        return {
          'success': false,
          'message': data['message'] ?? 'OTP tidak valid atau sudah kadaluwarsa'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
    }
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    final results =
        await Future.wait([getProfil(), getSaldo(), getRiwayatTransaksi()]);
    final profileResult = results[0];
    final balanceResult = results[1];
    final historyResult = results[2];
    if (profileResult['success'] != true) return profileResult;

    final profile = profileResult['data'] is Map
        ? Map<String, dynamic>.from(profileResult['data'] as Map)
        : <String, dynamic>{};
    final balanceData = balanceResult['data'] is Map
        ? Map<String, dynamic>.from(balanceResult['data'] as Map)
        : <String, dynamic>{};
    final saldoTersedia = extractSaldoTersedia(balanceResult['data']);
    final saldoPayload = balanceData['saldo'] is Map
        ? Map<String, dynamic>.from(balanceData['saldo'] as Map)
        : balanceData;
    final saldoDitahan = saldoPayload['ditahan'] ??
        saldoPayload['saldo_ditahan'] ??
        balanceData['saldo_ditahan'];
    final historyPayload = historyResult['data'];
    final historyRows = historyResult['success'] == true
        ? (historyPayload is Map && historyPayload['data'] is List
            ? historyPayload['data'] as List
            : historyPayload is List
                ? historyPayload
                : <dynamic>[])
        : <dynamic>[];

    return {
      'success': true,
      'data': {
        'user': profile,
        'keuangan': {
          // Never fall back to Proyek 2's `jumlah_saldo` or coin balance.
          'saldo': saldoTersedia,
          'saldo_ditahan': saldoDitahan,
        },
        'ringkasan': const {'total_setor': null, 'berat_total': null},
        'aktivitas': historyRows.whereType<Map>().map((row) {
          final date = row['tgl_setor'] ?? row['created_at'] ?? '';
          final weight = row['total_berat_kg'] ?? row['total_berat'] ?? '-';
          return <String, dynamic>{
            'title': 'Setoran #${row['id'] ?? '-'}',
            'subtitle': '$weight kg sampah terpilah',
            'date': date.toString(),
            'status': (row['status'] ?? 'status belum tersedia').toString(),
          };
        }).toList(),
        'partial_errors': [
          if (balanceResult['success'] != true) balanceResult['message'],
          if (historyResult['success'] != true) historyResult['message'],
        ],
      },
    };
  }

  /// Extracts only explicit Rupiah balance fields; never coins or legacy totals.
  static dynamic extractSaldoTersedia(dynamic rawBalance) {
    if (rawBalance is num || rawBalance is String) return rawBalance;
    if (rawBalance is! Map) return null;
    final data = Map<String, dynamic>.from(rawBalance);
    final saldo = data['saldo'];
    final saldoPayload = saldo is Map
        ? Map<String, dynamic>.from(saldo)
        : data;
    final scalarSaldo = saldo is num || saldo is String ? saldo : null;
    return saldoPayload['tersedia'] ??
        saldoPayload['saldo_tersedia'] ??
        data['saldo_tersedia'] ??
        data['saldo_rupiah'] ??
        (saldoPayload != data &&
                (saldoPayload['saldo'] is num || saldoPayload['saldo'] is String)
            ? saldoPayload['saldo']
            : null) ??
        scalarSaldo;
  }

  Future<Map<String, dynamic>> getAktivitas() async {
    final result = await getRiwayatTransaksi();
    if (result['success'] != true) return result;
    final payload = result['data'];
    final List rows = payload is Map && payload['data'] is List
        ? payload['data'] as List
        : (payload is List ? payload : <dynamic>[]);
    return {
      'success': true,
      'data': rows.whereType<Map>().map((row) {
        final date = row['tgl_setor'] ?? row['created_at'] ?? '';
        final weight = row['total_berat_kg'] ?? 0;
        final status = (row['status'] ?? 'selesai').toString();
        final details =
            row['detail'] is List ? row['detail'] as List : <dynamic>[];
        final bank = row['bank_sampah'] is Map
            ? Map<String, dynamic>.from(row['bank_sampah'] as Map)
            : <String, dynamic>{};
        return <String, dynamic>{
          'type': 'setor',
          'title': 'Setoran #${row['id'] ?? '-'}',
          'subtitle': '$weight kg sampah terpilah',
          'detail': '$status • $date',
          'status': status,
          'date': date.toString(),
          'total_weight': weight,
          'total_amount': row['total_saldo'] ?? row['total_setoran'],
          'bank_name': bank['nama_bank'],
          'details': details.whereType<Map>().map((detail) {
            final price = detail['harga_sampah'] is Map
                ? Map<String, dynamic>.from(detail['harga_sampah'] as Map)
                : <String, dynamic>{};
            return <String, dynamic>{
              'material':
                  (price['jenis_sampah'] ?? 'Jenis tidak tersedia').toString(),
              'weight': detail['berat_kg'],
              'price_per_kg': price['harga_per_kg'],
              'subtotal': detail['subtotal'],
            };
          }).toList(),
        };
      }).toList(),
    };
  }

  /// GET /api/nasabah/edukasi — Artikel edukasi dari Admin
  Future<Map<String, dynamic>> getEdukasi() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia'};
      }
      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/edukasi'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengambil edukasi'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
    }
  }

  /// GET /api/nasabah/notifikasi — Notifikasi nasabah
  Future<Map<String, dynamic>> getNotifikasi() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia'};
      }
      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/notifikasi'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengambil notifikasi'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
    }
  }

  /// GET /api/nasabah/profil — Profil nasabah lengkap
  Future<Map<String, dynamic>> getProfil() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia'};
      }
      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/profil'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengambil profil'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
    }
  }

  /// PUT /api/nasabah/profil — Update profil nasabah
  Future<Map<String, dynamic>> updateProfil(Map<String, String> fields) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia'};
      }
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
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memperbarui profil'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
    }
  }

  /// GET /api/nasabah/bank-sampah — Daftar Bank Sampah aktif
  Future<Map<String, dynamic>> getBankSampah() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia'};
      }
      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/bank-sampah'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengambil data bank sampah'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
    }
  }

  /// POST /api/nasabah/transaksi/{id}/konfirmasi — Konfirmasi setoran dari petugas
  Future<Map<String, dynamic>> konfirmasiTransaksi(int idTransaksi) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia'};
      }

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
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
    }
  }

  /// POST /api/nasabah/bank-sampah/pilih — Pilih bank sampah sebagai mitra
  Future<Map<String, dynamic>> pilihBankSampah(int idBankSampah) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia'};
      }

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
        return {
          'success': true,
          'message': data['message'] ?? 'Bank sampah berhasil dipilih'
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memilih bank sampah'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
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
        return {
          'success': true,
          'message': data['message'] ?? 'Berhasil keluar'
        };
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
      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia'};
      }

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
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengambil riwayat transaksi'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
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
    await prefs.remove('setor_in_chat_history_v1');
  }

  /// GET /api/nasabah/saldo — Ambil saldo, koin, dan riwayat penarikan
  Future<Map<String, dynamic>> getSaldo() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/saldo'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengambil saldo'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
    }
  }

  /// POST /api/nasabah/saldo/tukar-koin — Tukar koin menjadi saldo
  Future<Map<String, dynamic>> tukarKoin(int jumlahKoin) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia'};
      }

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
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menukar koin'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
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
      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia'};
      }

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
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengajukan penarikan'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
    }
  }

  /// POST /api/nasabah/saldo/set-pin — Set atau ubah PIN transaksi
  Future<Map<String, dynamic>> setPin({
    required String pin,
    String? pinLama,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak tersedia'};
      }

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
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menyimpan PIN'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e'
      };
    }
  }

  /// POST /api/v1/chat — chatbot umum. Riwayat percakapan tidak disimpan server.
  Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    required List<Map<String, String>> history,
  }) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Sesi masuk tidak tersedia. Masuk kembali untuk memakai Asisten.',
        };
      }

      final limitedHistory = history.length > 10
          ? history.sublist(history.length - 10)
          : history;
      final response = await http
          .post(
            Uri.parse('$baseUrl/v1/chat'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'message': message, 'history': limitedHistory}),
          )
          .timeout(const Duration(seconds: 12));

      final decoded = jsonDecode(response.body);
      final data = decoded is Map ? decoded : const <String, dynamic>{};
      if (response.statusCode == 200 && data['status'] == true) {
        final payload = data['data'];
        final reply = payload is Map ? payload['reply']?.toString().trim() : null;
        if (reply != null && reply.isNotEmpty) {
          return {'success': true, 'reply': reply};
        }
      }

      final serverMessage = data['message']?.toString();
      return {
        'success': false,
        'message': response.statusCode == 429
            ? 'Batas pertanyaan tercapai. Coba lagi sebentar.'
            : serverMessage?.isNotEmpty == true
                ? serverMessage
                : 'Asisten belum dapat menjawab. Coba lagi beberapa saat.',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Koneksi ke Asisten terputus. Periksa jaringan lalu coba lagi.',
      };
    }
  }
}
