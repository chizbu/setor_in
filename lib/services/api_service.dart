import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Set at build time, for example --dart-define=API_BASE_URL=https://api.example.id/api/v1
  /// An empty value is intentional: never silently point a production app at localhost.
  static const String baseUrl = String.fromEnvironment('API_BASE_URL');

  bool get isConfigured => baseUrl.trim().isNotEmpty;

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${baseUrl.replaceFirst(RegExp(r'/$'), '')}/$path')
          .replace(queryParameters: query);

  Future<Map<String, dynamic>> _v1Request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    if (!isConfigured) {
      return {
        'success': false,
        'message': 'Server belum dikonfigurasi. Hubungi pengelola aplikasi.',
      };
    }
    try {
      final token = await getToken();
      final headers = <String, String>{
        'Accept': 'application/json',
        if (body != null) 'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      late http.Response response;
      final uri = _uri(path, query);
      switch (method) {
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        default:
          throw UnsupportedError('HTTP method tidak didukung');
      }
      final decoded = response.body.trim().isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
      if (decoded is Map<String, dynamic> &&
          response.statusCode >= 200 &&
          response.statusCode < 300) {
        return {
          'success': true,
          'data': decoded['data'] ?? decoded,
          'message': decoded['message'],
        };
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': decoded, 'message': 'Berhasil'};
      }
      final message = decoded is Map
          ? (decoded['message'] ??
                (decoded['errors'] is Map
                    ? (decoded['errors'] as Map).values.first
                    : null))
          : null;
      return {
        'success': false,
        'message':
            message?.toString() ?? 'Permintaan gagal (${response.statusCode}).',
      };
    } catch (_) {
      return {
        'success': false,
        'message':
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      };
    }
  }

  Future<Map<String, dynamic>> getMe() => _v1Request('GET', 'me');
  Future<Map<String, dynamic>> resendOtp(String email) =>
      _v1Request('POST', 'auth/resend-otp', body: {'email': email});
  Future<Map<String, dynamic>> forgotPassword(String email) =>
      _v1Request('POST', 'auth/forgot-password', body: {'email': email});
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) => _v1Request(
    'POST',
    'auth/reset-password',
    body: {
      'email': email,
      'otp': otp,
      'new_password': password,
      'password_confirmation': password,
    },
  );
  Future<Map<String, dynamic>> getJenisSampah() =>
      _v1Request('GET', 'jenis-sampah');
  Future<Map<String, dynamic>> getSaldoV1() => _v1Request('GET', 'saldo');
  Future<Map<String, dynamic>> getLokasi() => _v1Request('GET', 'lokasi');
  Future<Map<String, dynamic>> getJadwalSetor() =>
      _v1Request('GET', 'jadwal-setor/terdekat');
  Future<Map<String, dynamic>> getRiwayatV1({int page = 1}) =>
      _v1Request('GET', 'riwayat', query: {'page': '$page'});
  Future<Map<String, dynamic>> getChatReply(
    List<Map<String, String>> messages,
  ) => _v1Request('POST', 'chat', body: {'messages': messages});
  Future<Map<String, dynamic>> getFaqContext() => _v1Request('GET', 'faq');
  Future<Map<String, dynamic>> markNotificationRead(String id) =>
      _v1Request('POST', 'notifikasi/$id/dibaca');
  Future<Map<String, dynamic>> markAllNotificationsRead() =>
      _v1Request('POST', 'notifikasi/dibaca-semua');
  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> fields) =>
      _v1Request('PUT', 'me', body: fields);
  Future<Map<String, dynamic>> setPinV1(String pin) =>
      _v1Request('POST', 'me/pin', body: {'pin': pin});
  Future<Map<String, dynamic>> createSaldoExchange(
    Map<String, dynamic> fields,
  ) => _v1Request('POST', 'tukar-saldo', body: fields);
  Future<Map<String, dynamic>> getSavedExchangeTarget() =>
      _v1Request('GET', 'tujuan-tersimpan');

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _v1Request(
      'POST',
      'auth/login',
      body: {'email': email, 'password': password},
    );
    if (result['success'] != true) return result;
    final data = result['data'];
    final token = data is Map ? (data['access_token'] ?? data['token']) : null;
    if (token == null || token.toString().isEmpty) {
      return {'success': false, 'message': 'Server tidak mengirim token sesi.'};
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token.toString());
    final user = data is Map ? data['user'] : null;
    if (user is Map) {
      await prefs.setString('user_name', user['nama']?.toString() ?? '');
      await prefs.setString('user_email', user['email']?.toString() ?? email);
      await prefs.setString('user_role', user['role']?.toString() ?? 'nasabah');
    }
    return {'success': true, 'message': result['message'] ?? 'Login berhasil'};
  }

  Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String noTelepon,
    required String alamat,
  }) async {
    return _v1Request(
      'POST',
      'auth/register',
      body: {
        'nama': nama,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'no_hp': noTelepon,
        'alamat': alamat,
      },
    );
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String kodeOtp) async {
    return _v1Request(
      'POST',
      'auth/verify-otp',
      body: {'email': email, 'kode_otp': kodeOtp},
    );
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak tersedia, silakan login ulang.',
        };
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
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data dashboard',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getAktivitas() async {
    final result = await getRiwayatV1();
    if (result['success'] != true) return result;
    final raw = result['data'];
    final rows = raw is Map ? (raw['data'] ?? raw['items'] ?? []) : raw;
    if (rows is! List)
      return {
        'success': false,
        'message': 'Format riwayat dari server tidak dikenali.',
      };
    final normalized = rows.whereType<Map>().map((row) {
      final item = Map<String, dynamic>.from(row);
      final type =
          (item['type'] ??
                  item['tipe'] ??
                  (item.containsKey('nominal') ? 'tukar_saldo' : 'setor'))
              .toString()
              .toLowerCase();
      final rawDate =
          (item['created_at'] ?? item['tanggal'] ?? item['waktu'] ?? '')
              .toString();
      DateTime? date;
      try {
        date = DateTime.parse(rawDate).toLocal();
      } catch (_) {}
      final isExchange = type.contains('tukar') || type.contains('exchange');
      return <String, dynamic>{
        ...item,
        'type': isExchange ? 'tukar_saldo' : 'setor',
        'title':
            item['title'] ??
            item['judul'] ??
            (isExchange ? 'Tukar saldo' : 'Setoran sampah'),
        'subtitle':
            (item['subtitle'] ?? item['nominal'] ?? item['total_nilai'] ?? '')
                .toString(),
        'detail': (item['detail'] ?? item['tujuan'] ?? item['ringkasan'] ?? '')
            .toString(),
        'date':
            item['date'] ??
            (date == null ? '' : '${date.day} ${date.month} ${date.year} WIB'),
        'time':
            item['time'] ??
            (date == null
                ? ''
                : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'),
        'status': item['status'] ?? 'MENUNGGU',
      };
    }).toList();
    return {'success': true, 'data': normalized};
  }

  /// GET /api/nasabah/edukasi — Artikel edukasi dari Admin
  Future<Map<String, dynamic>> getEdukasi() => _v1Request('GET', 'edukasi');

  /// GET /api/nasabah/notifikasi — Notifikasi nasabah
  Future<Map<String, dynamic>> getNotifikasi() =>
      _v1Request('GET', 'notifikasi');

  /// GET /api/nasabah/profil — Profil nasabah lengkap
  Future<Map<String, dynamic>> getProfil() => getMe();

  /// PUT /api/nasabah/profil — Update profil nasabah
  Future<Map<String, dynamic>> updateProfil(Map<String, String> fields) =>
      updateMe(fields);

  /// GET /api/nasabah/bank-sampah — Daftar Bank Sampah aktif
  Future<Map<String, dynamic>> getBankSampah() async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Token tidak tersedia'};
      final response = await http.get(
        Uri.parse('$baseUrl/nasabah/bank-sampah'),
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
        'message': data['message'] ?? 'Gagal mengambil data bank sampah',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e',
      };
    }
  }

  /// POST /api/nasabah/transaksi/{id}/konfirmasi — Konfirmasi setoran dari petugas
  Future<Map<String, dynamic>> konfirmasiTransaksi(int idTransaksi) async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Token tidak tersedia'};

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
        'message': 'Tidak dapat terhubung ke server: $e',
      };
    }
  }

  /// POST /api/nasabah/bank-sampah/pilih — Pilih bank sampah sebagai mitra
  Future<Map<String, dynamic>> pilihBankSampah(int idBankSampah) async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Token tidak tersedia'};

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
          'message': data['message'] ?? 'Bank sampah berhasil dipilih',
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memilih bank sampah',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e',
      };
    }
  }

  /// POST /api/logout — Logout dan hapus token di server
  Future<Map<String, dynamic>> logoutServer() async {
    final result = await _v1Request('POST', 'auth/logout');
    await logout();
    return result['success'] == true
        ? result
        : {'success': true, 'message': 'Sesi lokal diakhiri.'};
  }

  /// GET /api/nasabah/transaksi — Riwayat transaksi penyetoran
  Future<Map<String, dynamic>> getRiwayatTransaksi({int page = 1}) =>
      getRiwayatV1(page: page);

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
  Future<Map<String, dynamic>> getSaldo() => getSaldoV1();

  /// POST /api/nasabah/saldo/tukar-koin — Tukar koin menjadi saldo
  Future<Map<String, dynamic>> tukarKoin(int jumlahKoin) async {
    try {
      final token = await getToken();
      if (token == null)
        return {'success': false, 'message': 'Token tidak tersedia'};

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
        'message': data['message'] ?? 'Gagal menukar koin',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e',
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
      if (token == null)
        return {'success': false, 'message': 'Token tidak tersedia'};

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
        'message': data['message'] ?? 'Gagal mengajukan penarikan',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server: $e',
      };
    }
  }

  /// POST /api/nasabah/saldo/set-pin — Set atau ubah PIN transaksi
  Future<Map<String, dynamic>> setPin({
    required String pin,
    String? pinLama,
  }) async {
    final body = <String, dynamic>{'pin': pin};
    if (pinLama != null) body['pin_lama'] = pinLama;
    return pinLama == null
        ? setPinV1(pin)
        : _v1Request('PUT', 'me/pin', body: body);
  }
}
