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

class _SetorSampahScreenState extends State<SetorSampahScreen>
    with SingleTickerProviderStateMixin {
  final UserData _userData = UserData();
  bool _isLoading = true;
  String _nama = '';
  String _noTelpon = '';
  String _qrCode = '';
  List<Map<String, dynamic>> _hargaList = [];
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // scanning effect
    _loadData();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
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
      final userId = p['id'];
      _qrCode = p['qr_code']?.toString() ??
          (userId != null ? 'SETORIN:NASABAH:$userId' : '');
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
      
      for (final b in banks) {
        final List hargas = b['harga_sampah'] ?? [];
        for (final h in hargas) {
          tempHarga.add({
            'jenis': h['jenis_sampah']?.toString() ?? '',
            'harga': double.tryParse(h['harga_per_kg']?.toString() ?? '') ?? 0.0,
            'bank': b['nama_bank']?.toString() ?? '',
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

    // Fallback harga jika kosong
    if (_hargaList.isEmpty) {
      _hargaList = [
        {'jenis': 'Plastik HDPE / Botol', 'harga': 2000.0, 'bank': 'Mitra SetorIn'},
        {'jenis': 'Kertas Karton / Kardus', 'harga': 1500.0, 'bank': 'Mitra SetorIn'},
        {'jenis': 'Logam Besi / Aluminium', 'harga': 4500.0, 'bank': 'Mitra SetorIn'},
        {'jenis': 'Kaca Bening', 'harga': 1200.0, 'bank': 'Mitra SetorIn'},
        {'jenis': 'Sampah Organik Kompos', 'harga': 800.0, 'bank': 'Mitra SetorIn'},
      ];
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showQrDialog() {
    if (_qrCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR Code belum tersedia. Coba muat ulang halaman.')),
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
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kText),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tunjukkan ke petugas Bank Sampah untuk di-scan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: kTextSoft),
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
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _noTelpon,
                style: const TextStyle(fontSize: 12, color: kTextSoft),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
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
          child: Icon(Icons.qr_code_2_rounded, size: 48, color: Colors.black26),
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black87, width: 2),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Colors.black87,
            ),
          ),
        ),
        title: const Text(
          'Setor Sampah',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: kText,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                // ── BAGIAN 1: KARTU DIGITAL & QR ──
                _buildDigitalCard(),
                const SizedBox(height: 28),

                // ── BAGIAN 2: PANDUAN LANGKAH ──
                const Text(
                  'Panduan Setor Sampah',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: kPrimary, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Live API',
                            style: TextStyle(fontSize: 10, color: kPrimary, fontWeight: FontWeight.bold),
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
      decoration: BoxDecoration(
        gradient: kGradientPrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Pattern Accent
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -50,
              bottom: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo & Judul Kartu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KARTU NASABAH',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'SetorIn Digital Bank',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _showQrDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // QR Code & Info Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Styled QR Code Container
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _buildQrWidget(size: 100),
                            // Scanning Line Animation
                            AnimatedBuilder(
                              animation: _animCtrl,
                              builder: (context, child) {
                                return Positioned(
                                  top: 100 * _animCtrl.value,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2.5,
                                    decoration: BoxDecoration(
                                      color: kPrimary,
                                      boxShadow: [
                                        BoxShadow(
                                          color: kPrimary.withValues(alpha: 0.6),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'NAMA LENGKAP',
                              style: TextStyle(color: Colors.white60, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            Text(
                              _nama,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'NO. HANDPHONE / ID',
                              style: TextStyle(color: Colors.white60, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            Text(
                              _noTelpon,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.camera_front_rounded, color: Colors.white, size: 12),
                                  SizedBox(width: 6),
                                  Text(
                                    'Tunjukkan ke Petugas',
                                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. PANDUAN PANDUAN SETOR LANGKAH-LANGKAH ──
  Widget _buildPanduanSteps() {
    final steps = [
      {
        'step': '1',
        'title': 'Pilah Dari Rumah',
        'desc': 'Pisahkan sampah anorganik (Plastik, Kertas, Logam, Kaca) dari sampah organik basah.',
        'icon': Icons.cleaning_services_rounded,
        'color': const Color(0xFF3B82F6),
      },
      {
        'step': '2',
        'title': 'Bawa ke Bank Sampah',
        'desc': 'Kunjungi mitra Bank Sampah SetorIn terdekat dari lokasi hunian Anda.',
        'icon': Icons.map_rounded,
        'color': const Color(0xFF0D9146),
      },
      {
        'step': '3',
        'title': 'Scan QR Code Anggota',
        'desc': 'Tunjukkan QR Code di kartu digital atas kepada petugas di lokasi timbangan.',
        'icon': Icons.qr_code_scanner_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'step': '4',
        'title': 'Terima Koin & Saldo',
        'desc': 'Petugas menimbang sampah, dan Saldo rupiah beserta Koin langsung masuk ke akun!',
        'icon': Icons.payments_rounded,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return Column(
      children: steps.map((s) {
        final stepC = s['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cardDecoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: stepC.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    s['step'] as String,
                    style: TextStyle(color: stepC, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s['desc'] as String,
                      style: const TextStyle(fontSize: 11, color: kTextSoft, height: 1.4),
                    ),
                  ],
                ),
              ),
              Icon(s['icon'] as IconData, color: stepC.withValues(alpha: 0.4), size: 24),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── 3. LIST HARGA TERKINI DARI API ──
  Widget _buildHargaList() {
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
          } else if (jenis.toLowerCase().contains('kertas') || jenis.toLowerCase().contains('karton')) {
            iconData = Icons.article_outlined;
            c = const Color(0xFF3B82F6);
          } else if (jenis.toLowerCase().contains('logam') || jenis.toLowerCase().contains('besi') || jenis.toLowerCase().contains('aluminium')) {
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconData, color: c, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jenis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kText),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            bank,
                            style: const TextStyle(fontSize: 10, color: kTextSoft),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${harga.toStringAsFixed(0)}/kg',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: c),
                    ),
                  ],
                ),
              ),
              if (i < _hargaList.length - 1)
                Divider(height: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}