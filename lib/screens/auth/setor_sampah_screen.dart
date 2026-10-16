import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'app_theme.dart';
import 'user_data.dart';
import '../../services/api_service.dart';

class SetorSampahScreen extends StatefulWidget {
  const SetorSampahScreen({super.key});

  @override
  State<SetorSampahScreen> createState() => _SetorSampahScreenState();
}

class _SetorSampahScreenState extends State<SetorSampahScreen> {
  final UserData _userData = UserData();
  bool _isLoading = true;
  String _nama = '';
  String _noTelpon = '';
  String _qrCode = '';
  List<Map<String, dynamic>> _hargaList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // 1. Ambil data profil dari API/local
    final profileRes = await ApiService().getProfil();
    if (profileRes['success'] == true && profileRes['data'] != null) {
      final p = profileRes['data'];
      _nama = p['nama'] ?? 'Nasabah SetorIn';
      _noTelpon = p['no_telepon'] ?? '-';
      // Never derive a scannable member code from a sequential database ID.
      // The backend must issue and return its dedicated QR value.
      _qrCode = (p['kode_qr'] ?? p['qr_code'] ?? p['code_qr'] ?? '').toString();
    } else {
      await _userData.load();
      _nama = _userData.nama;
      _noTelpon = _userData.noTelpon;
      _qrCode = '';
    }

    // 2. Ambil daftar harga dari API bank-sampah
    final bankRes = await ApiService().getBankSampah();
    if (bankRes['success'] == true && bankRes['data'] != null) {
      final List banks = bankRes['data'] is List ? bankRes['data'] : [];
      final List<Map<String, dynamic>> tempHarga = [];

      final partner = banks.whereType<Map>().where((bank) =>
          (bank['nama_bank'] ?? '')
              .toString()
              .toLowerCase()
              .contains('rumah hijau'));
      final harga = partner.isEmpty ? null : partner.first['harga_sampah'];
      if (harga is List) {
        for (final h in harga.whereType<Map>()) {
          tempHarga.add({
            'jenis': h['jenis_sampah']?.toString() ?? '',
            'harga':
                double.tryParse(h['harga_per_kg']?.toString() ?? '') ?? 0.0,
            'bank': partner.first['nama_bank']?.toString() ?? 'Rumah Hijau',
          });
        }
      }

      // Filter unik berdasarkan jenis sampah
      final seenJenis = <String>{};
      _hargaList = [];
      for (final h in tempHarga) {
        final jenisLower = h['jenis'].toLowerCase();
        if (!seenJenis.contains(jenisLower)) {
          seenJenis.add(jenisLower);
          _hargaList.add(h);
        }
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showQrDialog() {
    if (_qrCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('QR Code belum tersedia. Coba muat ulang halaman.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'QR Kartu Nasabah',
                style: TextStyle(
                    fontSize: 18.7, fontWeight: FontWeight.w800, color: kText),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tunjukkan ke petugas Bank Sampah untuk di-scan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.8, color: kTextSoft),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: QrImageView(
                  data: _qrCode,
                  size: 240,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _nama,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16.1, color: kText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _noTelpon,
                style: const TextStyle(fontSize: 13.8, color: kTextSoft),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tutup',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrWidget({required double size}) {
    if (_qrCode.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: Icon(Icons.qr_code_2_rounded, size: 56.6, color: Colors.black26),
        ),
      );
    }

    return QrImageView(
      data: _qrCode,
      size: size,
      backgroundColor: Colors.white,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 23.6, color: kText),
        ),
        title: const Text('Kartu nasabah'),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
              children: [
                // ── BAGIAN 1: KARTU DIGITAL & QR ──
                _buildDigitalCard(),
                if (_qrCode.isEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5E8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'QR unik belum diterbitkan oleh server. Kode tidak dibuat dari ID akun.',
                      style: TextStyle(color: Color(0xFF704300), fontSize: 13.8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                // ── BAGIAN 2: PANDUAN LANGKAH ──
                const Text(
                  'Panduan Setor Sampah',
                  style: TextStyle(
                    fontSize: 14.9,
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 14),
                _buildPanduanSteps(),
                const SizedBox(height: 28),

                // ── BAGIAN 3: DAFTAR HARGA TERKINI ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Harga Sampah Terkini',
                      style: TextStyle(
                        fontSize: 18.4,
                        fontWeight: FontWeight.w700,
                        color: kText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: kPrimary, size: 14.2),
                          SizedBox(width: 4),
                          Text(
                            'Live API',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: kPrimary,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildHargaList(),
              ],
            ),
    );
  }

  // ── 1. DIGITAL MEMBER CARD & QR CODE ──
  Widget _buildDigitalCard() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: kPrimaryDark,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Stack(children: [
        Positioned(
          right: -48,
          top: -62,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: .07)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(13),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('KARTU NASABAH', style: TextStyle(
                    color: Color(0xFFDDE5C9), fontSize: 10,
                    fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                SizedBox(height: 3),
                Text('Rumah Hijau', style: TextStyle(
                    color: Colors.white, fontSize: 16.1, fontWeight: FontWeight.w800)),
              ])),
              IconButton(
                tooltip: 'Perbesar QR',
                onPressed: _showQrDialog,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.open_in_full_rounded, color: Colors.white70, size: 18.9),
              ),
            ]),
            const SizedBox(height: 9),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              GestureDetector(
                onTap: _showQrDialog,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(9)),
                  child: _buildQrWidget(size: 76),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('NAMA NASABAH', style: TextStyle(
                    color: Color(0xFFCCD2C2), fontSize: 8.8,
                    fontWeight: FontWeight.w800, letterSpacing: .8)),
                const SizedBox(height: 2),
                Text(_nama.isEmpty ? 'Nasabah' : _nama, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13.8, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('KONTAK NASABAH', style: TextStyle(
                    color: Color(0xFFCCD2C2), fontSize: 8.8,
                    fontWeight: FontWeight.w800, letterSpacing: .8)),
                const SizedBox(height: 2),
                Text(_noTelpon.isEmpty ? 'Kontak belum tersedia' : _noTelpon,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                const Text('Tunjukkan QR ini kepada petugas',
                    style: TextStyle(color: Color(0xFFDDE5C9), fontSize: 10)),
              ])),
            ]),
          ]),
        ),
      ]),
    );
  }

  // ── 2. PANDUAN PANDUAN SETOR LANGKAH-LANGKAH ──
  Widget _buildPanduanSteps() {
    final steps = [
      {
        'step': '1',
        'title': 'Pilah Dari Rumah',
        'desc':
            'Pisahkan sampah anorganik (Plastik, Kertas, Logam, Kaca) dari sampah organik basah.',
        'icon': Icons.cleaning_services_rounded,
        'color': const Color(0xFF3B82F6),
      },
      {
        'step': '2',
        'title': 'Kunjungi Rumah Hijau',
        'desc':
            'Periksa lokasi dan jadwal Rumah Hijau sebelum datang menyetor.',
        'icon': Icons.map_rounded,
        'color': const Color(0xFF0D9146),
      },
      {
        'step': '3',
        'title': 'Tunjukkan QR kepada petugas',
        'desc':
            'Tunjukkan QR Code di kartu digital atas kepada petugas di lokasi timbangan.',
        'icon': Icons.qr_code_scanner_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'step': '4',
        'title': 'Petugas memverifikasi setoran',
        'desc':
            'Petugas menimbang dan mencatat sampah. Nilai setoran mengikuti harga yang berlaku saat transaksi.',
        'icon': Icons.payments_rounded,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return Column(
      children: steps.map((s) {
        final stepC = s['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: AppTheme.cardDecoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: stepC.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    s['step'] as String,
                    style: TextStyle(
                        color: stepC,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['title'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11.2,
                          color: kText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s['desc'] as String,
                      style: const TextStyle(
                          fontSize: 10, color: kTextSoft, height: 1.35),
                    ),
                  ],
                ),
              ),
              Icon(s['icon'] as IconData,
                  color: stepC.withValues(alpha: 0.4), size: 18.9),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── 3. LIST HARGA TERKINI DARI API ──
  Widget _buildHargaList() {
    if (_hargaList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.cardDecoration,
        child: const Text(
          'Harga belum tersedia dari server. Tarik ke bawah untuk memuat ulang.',
          textAlign: TextAlign.center,
          style: TextStyle(color: kTextSoft, fontSize: 13.8, height: 1.45),
        ),
      );
    }
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: _hargaList.asMap().entries.map((e) {
          final i = e.key;
          final h = e.value;
          final String jenis = h['jenis'];
          final double harga = h['harga'];
          final String bank = h['bank'];

          IconData iconData = Icons.recycling_rounded;
          Color c = kPrimary;

          if (jenis.toLowerCase().contains('plastik')) {
            iconData = Icons.water_drop_outlined;
            c = const Color(0xFF0D9146);
          } else if (jenis.toLowerCase().contains('kertas') ||
              jenis.toLowerCase().contains('karton')) {
            iconData = Icons.article_outlined;
            c = const Color(0xFF3B82F6);
          } else if (jenis.toLowerCase().contains('logam') ||
              jenis.toLowerCase().contains('besi') ||
              jenis.toLowerCase().contains('aluminium')) {
            iconData = Icons.hardware_outlined;
            c = const Color(0xFFF59E0B);
          } else if (jenis.toLowerCase().contains('kaca')) {
            iconData = Icons.wine_bar_outlined;
            c = const Color(0xFF8B5CF6);
          } else if (jenis.toLowerCase().contains('organik')) {
            iconData = Icons.eco_outlined;
            c = const Color(0xFF059669);
          }

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconData, color: c, size: 23.6),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jenis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.9,
                                color: kText),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            bank,
                            style:
                                const TextStyle(fontSize: 12.5, color: kTextSoft),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${harga.toStringAsFixed(0)}/kg',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14.9, color: c),
                    ),
                  ],
                ),
              ),
              if (i < _hargaList.length - 1)
                Divider(
                    height: 1,
                    color: Colors.grey.shade100,
                    indent: 16,
                    endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
