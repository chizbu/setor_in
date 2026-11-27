import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:math';
import 'app_theme.dart';

import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'user_data.dart'; // ← TAMBAHAN: import UserData
import '../../services/api_service.dart';
import 'buat_pin_screen.dart';

// ══════════════════════════════════════════════════════════════
//  MODEL RIWAYAT TRANSAKSI
// ══════════════════════════════════════════════════════════════

enum JenisTransaksi { transfer, cash }

class RiwayatTransaksi {
  final JenisTransaksi jenis;
  final String judul;
  final String subjudul;
  final String tanggal;
  final String nominal;
  final bool isPlus;
  final String status;
  final String? id;
  final String? metodeBayar;
  final String? noRekening;
  final DateTime? waktu;

  const RiwayatTransaksi({
    required this.jenis,
    required this.judul,
    required this.subjudul,
    required this.tanggal,
    required this.nominal,
    required this.isPlus,
    this.status = 'disetujui',
    this.id,
    this.metodeBayar,
    this.noRekening,
    this.waktu,
  });
}

// ══════════════════════════════════════════════════════════════
//  RIWAYAT GLOBAL
// ══════════════════════════════════════════════════════════════

class RiwayatStore {
  static final List<RiwayatTransaksi> data = [];

  static void tambah(RiwayatTransaksi r) => data.insert(0, r);

  static String _fmt(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  static String _nowStr() {
    final now = DateTime.now();
    const bln = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${now.day} ${bln[now.month]} ${now.year}, '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  static String _fmtDate(String tglStr) {
    if (tglStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(tglStr).toLocal();
      const bln = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
          'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${dt.day} ${bln[dt.month]} ${dt.year}, '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      // If parsing fails, try parsing manually from "YYYY-MM-DD HH:MM:SS"
      try {
        final cleaned = tglStr.trim();
        final parts = cleaned.split(' ');
        final dateParts = parts[0].split('-');
        final year = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final day = int.parse(dateParts[2]);
        int hour = 0;
        int minute = 0;
        if (parts.length > 1) {
          final timeParts = parts[1].split(':');
          hour = int.parse(timeParts[0]);
          minute = int.parse(timeParts[1]);
        }
        const bln = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
            'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
        return '$day ${bln[month]} $year, '
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      } catch (_) {
        return tglStr;
      }
    }
  }

  static void tambahTransfer(String metode, String penerima, int nominal, {JenisTransaksi jenis = JenisTransaksi.transfer}) {
    tambah(RiwayatTransaksi(
      jenis: jenis,
      judul: jenis == JenisTransaksi.cash ? 'Tarik tunai - $metode' : 'Top-up ke $metode',
      subjudul: penerima,
      tanggal: _nowStr(),
      nominal: '-Rp ${_fmt(nominal)}',
      isPlus: false,
      status: 'pending',
      id: 'TR-${DateTime.now().millisecondsSinceEpoch}',
      metodeBayar: metode,
      noRekening: penerima,
      waktu: DateTime.now(),
    ));
  }
}

// ══════════════════════════════════════════════════════════════
//  KEUANGAN SCREEN
  // Saldo Proyek 3 hanya berupa saldo rupiah.
// ══════════════════════════════════════════════════════════════

class KeuanganScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const KeuanganScreen({super.key, this.onBack});

  @override
  State<KeuanganScreen> createState() => _KeuanganScreenState();
}

class _KeuanganScreenState extends State<KeuanganScreen> {
  bool _showSaldo = false;

  // ── FIX: pakai UserData singleton, bukan final hardcoded ──
  final UserData _userData = UserData();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load Data dari API lalu rebuild UI
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService().getSaldo();
      if (res['success']) {
        final data = res['data'];

        // Parse jumlah saldo dengan aman
        dynamic jumlahSaldoRaw = data['saldo'] != null ? data['saldo']['jumlah_saldo'] : 0;
        double saldoParsed = 0;
        if (jumlahSaldoRaw is num) saldoParsed = jumlahSaldoRaw.toDouble();
        if (jumlahSaldoRaw is String) saldoParsed = double.tryParse(jumlahSaldoRaw) ?? 0;

        _userData.saldo = saldoParsed;

        // Parse saldo_tertahan dan has_pin
        dynamic tertahanRaw = data['saldo_tertahan'] ?? 0;
        if (tertahanRaw is num) _userData.saldoTertahan = tertahanRaw.toDouble();
        if (tertahanRaw is String) _userData.saldoTertahan = double.tryParse(tertahanRaw) ?? 0;
        _userData.hasPin = data['has_pin'] == true;

        await _userData.simpan(); // Sinkronisasi lokal

        if (data['riwayat_penarikan'] != null) {
          // Hapus riwayat transfer lokal sebelumnya agar tidak duplikat dengan API
          RiwayatStore.data.removeWhere((r) => r.jenis == JenisTransaksi.transfer);

          final listPenarikan = data['riwayat_penarikan'] as List;
          for (var p in listPenarikan) {
            final tglStr = p['tgl_pengajuan'] ?? p['created_at'] ?? '';
            final tgl = RiwayatStore._fmtDate(tglStr);
            final waktu = DateTime.tryParse(tglStr) ?? DateTime.now();
            RiwayatStore.data.add(RiwayatTransaksi(
              jenis: (p['metode_bayar'] ?? '').toString().toLowerCase().contains('tunai')
                  ? JenisTransaksi.cash
                  : JenisTransaksi.transfer,
              judul: (p['metode_bayar'] ?? '').toString().toLowerCase().contains('tunai')
                  ? 'Tarik tunai'
                  : 'Top-up ke ${p['metode_bayar']}',
              subjudul: p['no_rekening'] ?? '-',
              tanggal: tgl,
              nominal: '-Rp ${_fmtNominal(p['jumlah_tarik'] ?? 0)}',
              isPlus: false,
              status: p['status'] ?? 'pending',
              id: p['id']?.toString() ?? 'TR-${p['id']}',
              metodeBayar: p['metode_bayar'],
              noRekening: p['no_rekening'],
              waktu: waktu,
            ));
          }
        }
        // Urutkan riwayat berdasarkan waktu descending (terbaru di atas)
        RiwayatStore.data.sort((a, b) {
          final tA = a.waktu ?? DateTime.fromMillisecondsSinceEpoch(0);
          final tB = b.waktu ?? DateTime.fromMillisecondsSinceEpoch(0);
          return tB.compareTo(tA);
        });
      } else {
        // Fallback lokal jika API gagal
        _userData.resetLoadFlag();
        await _userData.load();
      }
    } catch (e) {
      // Jika terjadi error parsing, jangan biarkan loading berputar terus
      _userData.resetLoadFlag();
      await _userData.load();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  String _fmtNominal(dynamic val) {
    int v = 0;
    if (val is int) v = val;
    if (val is double) v = val.toInt();
    if (val is String) {
      v = int.tryParse(val) ?? (double.tryParse(val)?.toInt() ?? 0);
    }
    return RiwayatStore._fmt(v);
  }

  /// Dipanggil setiap kali kembali dari sub-screen agar data fresh
  Future<void> _reloadData() async {
    await _loadData();
  }

  // ── Getter shortcut ──────────────────────────────────────
  double get _saldo => _isLoading ? 0 : _userData.saldo;

  // ────────────────────────────────────────────────────────
  Widget _buildTopSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kartu saldo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: AppTheme.greenCardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.white70, size: AppIconSize.md),
                  const SizedBox(width: 6),
                  const Text('Saldomu',
                      style: TextStyle(color: Colors.white70, fontSize: AppTypography.bodySmall)),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => setState(() => _showSaldo = !_showSaldo),
                    child: Icon(
                      _showSaldo
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white70,
                      size: AppIconSize.md,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _isLoading
                    ? 'Memuat...'
                    : _showSaldo
                        ? 'Rp ${_saldo.toStringAsFixed(0)}'
                        : 'Rp ••••••••',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.title,
                    fontWeight: FontWeight.w700),
              ),
              // ── Saldo Tertahan (jika ada) ──
              if (!_isLoading && _userData.saldoTertahan > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: AppIconSize.sm),
                      const SizedBox(width: 4),
                      Text(
                        'Saldo diproses: Rp ${_userData.saldoTertahan.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.amber, fontSize: AppTypography.caption, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Menu aksi Proyek 3: saldo rupiah dipakai untuk e-wallet atau tunai.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMenuTile(
              icon: Icons.account_balance_wallet_outlined,
              label: 'E-wallet',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MetodePembayaranScreen(isTransfer: false),
                  ),
                );
                await _reloadData();
              },
            ),
            _buildMenuTile(
              icon: Icons.payments_outlined,
              label: 'Tarik Saldo',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CashWithdrawalScreen()),
                );
                await _reloadData();
              },
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildRiwayatTile(RiwayatTransaksi item) {
    final isCash = item.jenis == JenisTransaksi.cash;
    final iconData = isCash ? Icons.payments_outlined : Icons.account_balance_wallet_outlined;
    final iconColor = isCash ? kWarning : kPrimary;
    final iconBg = isCash ? const Color(0xFFFFF4E5) : kPrimaryLight;

    return InkWell(
      onTap: () => _showDetailTransaksi(context, item),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: AppIconSize.sm),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.judul,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: AppTypography.bodySmall),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subjudul,
                    style: TextStyle(color: kTextSoft, fontSize: AppTypography.overline),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.nominal,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppTypography.bodySmall,
                    color: item.isPlus ? kPrimary : kDanger,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: AppTypography.overline,
                    fontWeight: FontWeight.w700,
                    color: item.status == 'pending'
                        ? kWarning
                        : (item.status == 'ditolak' ? kDanger : kPrimary),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.tanggal.contains(',')
                      ? item.tanggal.split(',').last.trim()
                      : item.tanggal,
                  style: TextStyle(fontSize: AppTypography.overline, color: kTextSoft),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: kPrimary, size: AppIconSize.sm),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: AppTypography.overline, fontWeight: FontWeight.w700, color: kText)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final riwayat = RiwayatStore.data;

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar('Keuangan',
          showBack: true, context: context, onBack: widget.onBack),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kPrimary))
          : Stack(
              children: [
                // Konten atas: kartu saldo + menu
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 260),
                  child: _buildTopSection(),
                ),

                // Sheet riwayat yang bisa ditarik ke atas
                DraggableScrollableSheet(
                  initialChildSize: 0.38,
                  minChildSize: 0.38,
                  maxChildSize: 1.0,
                  snap: true,
                  snapSizes: const [0.38, 1.0],
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppRadius.lg)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Handle + header
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RiwayatScreen()),
                            ).then((_) => setState(() {})),
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Container(
                                  width: 36,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Riwayat transaksi',
                                        style: TextStyle(
                                          fontSize: AppTypography.subtitle,
                                          fontWeight: FontWeight.w700,
                                          color: kText,
                                        ),
                                      ),
                                      Text(
                                        'Lihat semua',
                                        style: TextStyle(
                                          fontSize: AppTypography.bodySmall,
                                          color: kPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Divider(
                                    height: 1, color: Colors.grey.shade100),
                              ],
                            ),
                          ),

                          // Isi riwayat
                          Expanded(
                            child: riwayat.isEmpty
                                ? Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.receipt_long_outlined,
                                          size: AppIconSize.md,
                                          color: kTextSoft),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Belum ada transaksi',
                                        style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: AppTypography.bodySmall),
                                      ),
                                    ],
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius:
                                          const BorderRadius.vertical(
                                              top: Radius.circular(24)),
                                    ),
                                    child: ListView.separated(
                                      controller: scrollController,
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 8, 20, 40),
                                      itemCount: riwayat.length,
                                      separatorBuilder: (_, __) => Divider(
                                          height: 1,
                                          color: Colors.grey.shade200,
                                          indent: 68),
                                      itemBuilder: (context, index) =>
                                          _buildRiwayatTile(riwayat[index]),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  RIWAYAT SCREEN (halaman penuh)
// ══════════════════════════════════════════════════════════════

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  int _filterIndex = 0; // 0=Semua, 1=Top-up Ewallet, 2=Tarik tunai
  int _totalMasuk = 0;
  int _totalKeluar = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  void _calculateTotals() {
    int masuk = 0;
    int keluar = 0;
    final list = _filtered;
    final reg = RegExp(r'[^\d]');
    for (final r in list) {
      final angka = r.nominal.replaceAll(reg, '');
      final val = int.tryParse(angka) ?? 0;
      if (r.isPlus) {
        masuk += val;
      } else {
        keluar += val;
      }
    }
    _totalMasuk = masuk;
    _totalKeluar = keluar;
  }

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  List<RiwayatTransaksi> get _filtered {
    if (_filterIndex == 1) {
      return RiwayatStore.data
          .where((r) => r.jenis == JenisTransaksi.transfer)
          .toList();
    } else if (_filterIndex == 2) {
      return RiwayatStore.data
          .where((r) => r.jenis == JenisTransaksi.cash)
          .toList();
    }
    return RiwayatStore.data;
  }

  Map<String, List<RiwayatTransaksi>> get _grouped {
    final map = <String, List<RiwayatTransaksi>>{};
    for (final item in _filtered) {
      final tgl = item.tanggal.split(',').first.trim();
      map.putIfAbsent(tgl, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final keys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar('Riwayat Transaksi',
          showBack: true, context: context),
      body: Column(
        children: [
          // Summary card
          if (RiwayatStore.data.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md, horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    _summaryCol('Total masuk',
                        '+Rp ${_fmt(_totalMasuk)}', kPrimary),
                    Container(
                        width: 1,
                        height: 32,
                        color: Colors.grey.shade200),
                    _summaryCol('Total keluar',
                        '-Rp ${_fmt(_totalKeluar)}', kDanger),
                    Container(
                        width: 1,
                        height: 32,
                        color: Colors.grey.shade200),
                    _summaryCol('Transaksi',
                        '${_filtered.length}x', Colors.black87),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 14),

          // Filter chips
          SizedBox(
            height: 28,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [
                _chip('Semua', 0),
                const SizedBox(width: AppSpacing.sm),
                _chip('Top-up Ewallet', 1),
                const SizedBox(width: 8),
                _chip('Tarik tunai', 2),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: AppIconSize.md, color: kTextSoft),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada transaksi',
                        style: TextStyle(
                            color: kTextSoft, fontSize: AppTypography.bodySmall),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    itemCount: keys.length,
                    itemBuilder: (context, groupIndex) {
                      final tgl = keys[groupIndex];
                      final items = grouped[tgl]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 16, bottom: 8),
                            child: Text(
                              tgl,
                              style: TextStyle(
                                fontSize: AppTypography.caption,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: items.asMap().entries.map((e) {
                                final isLast = e.key == items.length - 1;
                                return Column(
                                  children: [
                                    _buildTile(e.value),
                                    if (!isLast)
                                      Divider(
                                        height: 1,
                                        color: Colors.grey.shade200,
                                        indent: 68,
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, int index) {
    final active = _filterIndex == index;
    return GestureDetector(
      onTap: () {
        if (_filterIndex != index) {
          setState(() {
            _filterIndex = index;
            _calculateTotals();
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: active ? kPrimary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.bodySmall,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _summaryCol(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style:
                  TextStyle(fontSize: AppTypography.caption, color: Colors.grey.shade500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: AppTypography.caption,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildTile(RiwayatTransaksi item) {
    final isCash = item.jenis == JenisTransaksi.cash;
    return InkWell(
      onTap: () => _showDetailTransaksi(context, item),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCash ? const Color(0xFFFFF4E5) : kPrimaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCash ? Icons.payments_outlined : Icons.account_balance_wallet_outlined,
                color: isCash ? kWarning : kPrimary,
                size: AppIconSize.sm,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.judul,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: AppTypography.bodySmall)),
                  const SizedBox(height: 2),
                  Text(item.subjudul,
                      style: TextStyle(
                          color: kTextSoft, fontSize: AppTypography.overline)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.nominal,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppTypography.bodySmall,
                    color: item.isPlus ? kPrimary : kDanger,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: AppTypography.overline,
                    fontWeight: FontWeight.w700,
                    color: item.status == 'pending'
                        ? kWarning
                        : (item.status == 'ditolak' ? kDanger : kPrimary),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.tanggal.contains(',')
                      ? item.tanggal.split(',').last.trim()
                      : item.tanggal,
                  style: TextStyle(
                      fontSize: AppTypography.overline, color: kTextSoft),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  METODE PEMBAYARAN
// ══════════════════════════════════════════════════════════════

class MetodePembayaranScreen extends StatefulWidget {
  final bool isTransfer;
  const MetodePembayaranScreen({super.key, this.isTransfer = false});

  @override
  State<MetodePembayaranScreen> createState() =>
      _MetodePembayaranScreenState();
}

class _MetodePembayaranScreenState
    extends State<MetodePembayaranScreen> {
  String? _selected;
  final List<String> _metode = ['DANA', 'OVO', 'GoPay', 'ShopeePay'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar('Top-up Ewallet',
          showBack: true, context: context),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                children: _metode.asMap().entries.map((entry) {
                  final index = entry.key;
                  final name  = entry.value;
                  final isLast = index == _metode.length - 1;
                  return Column(
                    children: [
                      InkWell(
                        onTap: () =>
                            setState(() => _selected = name),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(name,
                                    style: const TextStyle(
                                        fontSize: AppTypography.bodySmall,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87)),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selected == name
                                        ? kPrimary
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  color: _selected == name
                                      ? kPrimary
                                      : Colors.transparent,
                                ),
                                child: _selected == name
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: AppIconSize.sm)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast)
                        Divider(
                            height: 1,
                            color: Colors.grey.shade200,
                            indent: 20,
                            endIndent: 20),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => TransferScreen(
                                  metode: _selected!)),
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text('Konfirmasi',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.button,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TRANSFER SCREEN
// ══════════════════════════════════════════════════════════════

class TransferScreen extends StatefulWidget {
  final String metode;
  const TransferScreen({super.key, required this.metode});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _searchController =
      TextEditingController();
  String _query = '';
  List<Contact> _contacts = [];
  bool _loadingContacts = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      if (await FlutterContacts.requestPermission(readonly: true)) {
        final contacts = await FlutterContacts.getContacts(
            withProperties: true, withPhoto: false);
        setState(() {
          _contacts = contacts;
          _loadingContacts = false;
        });
      } else {
        setState(() {
          _permissionDenied = true;
          _loadingContacts = false;
        });
      }
    } catch (_) {
      setState(() {
        _loadingContacts = false;
        _permissionDenied = true;
      });
    }
  }

  List<Contact> get _filtered {
    if (_query.isEmpty) return _contacts;
    return _contacts.where((c) {
      final nameMatch =
          c.displayName.toLowerCase().contains(_query.toLowerCase());
      final phoneMatch =
          c.phones.any((p) => p.number.contains(_query));
      return nameMatch || phoneMatch;
    }).toList();
  }

  String _getInitial(String name) =>
      name.isNotEmpty ? name[0].toUpperCase() : '?';

  void _goToNominal(String name, String phone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NominalTransferScreen(
          metode: widget.metode,
          namaPenerima: name,
          nomorPenerima: phone,
        ),
      ),
    );
  }
Color _avatarBg(String initial) {
  final list = [
    Colors.pink.shade100,
    kPrimaryLight,
    const Color(0xFFFFF4E5),
    Colors.purple.shade100,
    Colors.teal.shade100,
  ];

  return list[initial.codeUnitAt(0) % list.length];
}

Color _avatarFg(String initial) {
  final list = [
    Colors.pink.shade400,
    kPrimary,
    kWarning,
    Colors.purple.shade400,
    Colors.teal.shade400,
  ];

  return list[initial.codeUnitAt(0) % list.length];
}

  @override
  Widget build(BuildContext context) {
    final isManualPhone =
        _query.isNotEmpty && RegExp(r'^[0-9+]{6,}$').hasMatch(_query);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar('Ke ${widget.metode}',
          showBack: true, context: context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: [
                  Icon(Icons.search,
                      color: Colors.grey.shade500, size: AppIconSize.md),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Masukan no. handphone / nama',
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: TextStyle(
                            color: Colors.grey, fontSize: AppTypography.body),
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      child: Icon(Icons.close,
                          color: Colors.grey.shade500, size: AppIconSize.md),
                    ),
                ],
              ),
            ),
            if (isManualPhone) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _goToNominal('Nomor Manual', _query),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: kPrimary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: kPrimary.withValues(alpha: 0.2),
                            shape: BoxShape.circle),
                        child: const Icon(
                            Icons.send_to_mobile_outlined,
                            color: kPrimary,
                            size: AppIconSize.md),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('Kirim ke nomor ini',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppTypography.body,
                                  color: kPrimary)),
                          Text(_query,
                              style: TextStyle(
                                  fontSize: AppTypography.bodySmall,
                                  color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (!_permissionDenied)
              const Text('Kontak saya',
                  style: TextStyle(
                      fontSize: AppTypography.body,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            const SizedBox(height: 10),
            Expanded(
              child: _loadingContacts
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: kPrimary))
                  : _permissionDenied
                      ? Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.contacts_outlined,
                                  size: AppIconSize.md,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('Izin kontak ditolak',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600)),
                              const SizedBox(height: 8),
                              Text(
                                  'Ketik nomor HP secara manual\n'
                                  'di kolom pencarian',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: AppTypography.bodySmall)),
                            ],
                          ),
                        )
                      : _filtered.isEmpty
                          ? Center(
                              child: Text('Kontak tidak ditemukan',
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: AppTypography.body)))
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2))
                                ],
                              ),
                              child: ListView.separated(
                                itemCount: _filtered.length,
                                separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                    indent: 64),
                                itemBuilder: (context, index) {
                                  final c = _filtered[index];
                                  final phone = c.phones.isNotEmpty
                                      ? c.phones.first.number
                                      : '-';
                                  final initial =
                                      _getInitial(c.displayName);
                                  return InkWell(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    onTap: () => _goToNominal(
                                        c.displayName, phone),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor:
                                                _avatarBg(initial),
                                            child: Text(initial,
                                                style: TextStyle(
                                                    color: _avatarFg(
                                                        initial),
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    fontSize: AppTypography.bodyLarge)),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(c.displayName,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight
                                                              .w600,
                                                      fontSize: AppTypography.body)),
                                              Text(phone,
                                                  style: TextStyle(
                                                      color: Colors.grey
                                                          .shade500,
                                                      fontSize: AppTypography.caption)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  INPUT NOMINAL
// ══════════════════════════════════════════════════════════════

class NominalTransferScreen extends StatefulWidget {
  final String metode;
  final String namaPenerima;
  final String nomorPenerima;

  const NominalTransferScreen({
    super.key,
    required this.metode,
    required this.namaPenerima,
    required this.nomorPenerima,
  });

  @override
  State<NominalTransferScreen> createState() =>
      _NominalTransferScreenState();
}

class _NominalTransferScreenState
    extends State<NominalTransferScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String _nominal = '';

  String _maskName(String name) {
    if (name == 'Nomor Manual') return name;
    if (name.length <= 4) return name;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      final first = parts[0];
      final last  = parts.last;
      return '${first.substring(0, min(3, first.length))}***'
          '${last.substring(max(0, last.length - 2))}';
    }
    return '${name.substring(0, 3)}***'
        '${name.substring(max(3, name.length - 2))}';
  }

  String _fmt(int amount) => amount
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    final canProceed = _nominal.isNotEmpty &&
        int.tryParse(_nominal) != null &&
        int.parse(_nominal) > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar('Ke ${widget.metode}',
          showBack: true, context: context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.pink.shade100,
                    child: Text(
                      widget.namaPenerima.isNotEmpty
                          ? widget.namaPenerima[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          color: Colors.pink.shade400,
                          fontWeight: FontWeight.w700,
                          fontSize: AppTypography.body),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_maskName(widget.namaPenerima),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: AppTypography.body)),
                      Text(widget.nomorPenerima,
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: AppTypography.bodySmall)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Text(widget.metode,
                            style: TextStyle(
                                color: kPrimary,
                                fontSize: AppTypography.caption,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('Nominal Top-up Ewallet',
                style: TextStyle(
                    fontSize: AppTypography.body,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(height: 10),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) => setState(() => _nominal = v),
              decoration: InputDecoration(
                hintText: '0',
                prefixText: 'Rp  ',
                prefixStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: kPrimary, width: 2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300)),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [10000, 25000, 50000, 100000].map((amt) {
                return GestureDetector(
                  onTap: () {
                    _ctrl.text = amt.toString();
                    setState(() => _nominal = amt.toString());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                          color: kPrimary.withValues(alpha: 0.3)),
                    ),
                    child: Text('Rp ${_fmt(amt)}',
                        style: TextStyle(
                            color: kPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: AppTypography.bodySmall)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: canProceed
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PinScreen(
                              metode: widget.metode,
                              namaPenerima: widget.namaPenerima,
                              nomorPenerima: widget.nomorPenerima,
                              nominal: int.parse(_nominal),
                            ),
                          ),
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text('Lanjutkan',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.body,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PIN SCREEN
// ══════════════════════════════════════════════════════════════

class PinScreen extends StatefulWidget {
  final String metode;
  final String namaPenerima;
  final String nomorPenerima;
  final int    nominal;

  const PinScreen({
    super.key,
    required this.metode,
    required this.namaPenerima,
    required this.nomorPenerima,
    required this.nominal,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  static const int _pinLength = 6;

  void _onKey(String key) {
    if (key == 'DEL') {
      if (_pin.isNotEmpty)
        setState(() => _pin = _pin.substring(0, _pin.length - 1));
    } else if (_pin.length < _pinLength) {
      setState(() => _pin += key);
    }
  }

  bool _isLoading = false;

  Future<void> _konfirmasi() async {
    if (_pin.length < _pinLength) {
      _snack('Masukkan PIN 6 digit', kDanger);
      return;
    }

    setState(() => _isLoading = true);

    final res = await ApiService().ajukanPenarikan(
      jumlahTarik: widget.nominal.toDouble(),
      metodeBayar: widget.metode,
      noRekening: widget.nomorPenerima,
      pin: _pin,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (res['success']) {
      // Catat ke riwayat lokal sementara
      RiwayatStore.tambahTransfer(widget.metode, widget.namaPenerima, widget.nominal);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RincianTransaksiScreen(
            metode: widget.metode,
            namaPenerima: widget.namaPenerima,
            nomorPenerima: widget.nomorPenerima,
            nominal: widget.nominal,
          ),
        ),
      );
    } else {
      _snack(res['message'] ?? 'Penarikan gagal', kDanger);
      setState(() => _pin = '');
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          _buildAppBar('Keuangan', showBack: true, context: context),
      body: Column(
        children: [
          const Spacer(),
          const Text('Masukan PIN',
              style: TextStyle(
                  fontSize: AppTypography.body, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pinLength, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length
                      ? kPrimary
                      : Colors.grey.shade300,
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                _keyRow(['1', '2', '3']),
                const SizedBox(height: 12),
                _keyRow(['4', '5', '6']),
                const SizedBox(height: 12),
                _keyRow(['7', '8', '9']),
                const SizedBox(height: 12),
                _keyRow(['', '0', 'DEL']),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    (_pin.length == _pinLength && !_isLoading) ? _konfirmasi : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Konfirmasi',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTypography.bodyLarge,
                            fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _keyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty)
          return const SizedBox(width: 80, height: 60);
        return GestureDetector(
          onTap: () => _onKey(key),
          child: Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: key == 'DEL'
                  ? const Icon(Icons.backspace_outlined,
                      size: AppIconSize.lg, color: Colors.black87)
                  : Text(key,
                      style: const TextStyle(
                          fontSize: AppTypography.title,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  STRUK WIDGET
// ══════════════════════════════════════════════════════════════

class StrukWidget extends StatelessWidget {
  final String metode;
  final String namaPenerima;
  final String nomorPenerima;
  final int    nominal;
  final String idTrx;
  final String noTrx;
  final String tanggal;

  const StrukWidget({
    super.key,
    required this.metode,
    required this.namaPenerima,
    required this.nomorPenerima,
    required this.nominal,
    required this.idTrx,
    required this.noTrx,
    required this.tanggal,
  });

  String _fmt(int amount) =>
      'Rp. ' +
      amount
          .toString()
          .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      color: const Color(0xFFF5F5F5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                vertical: 28, horizontal: 24),
            decoration: const BoxDecoration(color: kPrimaryDark),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.compare_arrows_rounded,
                      color: Colors.white, size: AppIconSize.md),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _fmt(nominal),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.title,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Berhasil',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: AppTypography.body,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(width: 6),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: AppIconSize.sm),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(tanggal,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: AppTypography.caption)),
              ],
            ),
          ),
          _zigzagDivider(const Color(0xFFF5F5F5)),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              children: [
                _strutRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Penerima',
                    value: namaPenerima),
                const SizedBox(height: 14),
                _strutRow(
                    icon: Icons.phone_outlined,
                    label: 'Nomor',
                    value: nomorPenerima),
                const SizedBox(height: 14),
                _strutRow(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Metode',
                    value: metode,
                    valueColor: kPrimary),
                const SizedBox(height: 20),
                Row(
                  children: List.generate(
                    30,
                    (_) => Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey.shade200,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _strutRow(
                    icon: Icons.tag_rounded,
                    label: 'ID Transaksi',
                    value: idTrx),
                const SizedBox(height: 14),
                _strutRow(
                    icon: Icons.receipt_outlined,
                    label: 'No. Transaksi',
                    value: noTrx),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: kPrimary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Top-up Ewallet',
                          style: TextStyle(
                              fontSize: AppTypography.body,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                      Text(_fmt(nominal),
                          style: const TextStyle(
                              fontSize: AppTypography.bodyLarge,
                              fontWeight: FontWeight.w800,
                              color: kPrimary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _zigzagDivider(const Color(0xFFF5F5F5), flipY: true),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  'Simpan struk ini sebagai bukti transaksi',
                  style: TextStyle(
                      fontSize: AppTypography.caption,
                      color: Colors.grey.shade400,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: AppIconSize.sm, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text('Transaksi terenkripsi & aman',
                        style: TextStyle(
                            fontSize: AppTypography.caption,
                            color: Colors.grey.shade400)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _strutRow({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.black87,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: Colors.grey.shade500),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: AppTypography.caption,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w400)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      fontWeight: FontWeight.w600,
                      color: valueColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _zigzagDivider(Color bgColor, {bool flipY = false}) {
    return Transform.scale(
      scaleY: flipY ? -1 : 1,
      child: CustomPaint(
        size: const Size(double.infinity, 16),
        painter: _ZigzagPainter(bgColor: bgColor),
      ),
    );
  }
}

class _ZigzagPainter extends CustomPainter {
  final Color bgColor;
  const _ZigzagPainter({required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    const teethWidth = 12.0;
    final path = Path();
    path.moveTo(0, 0);
    double x = 0;
    while (x < size.width) {
      path.lineTo(x + teethWidth / 2, size.height);
      path.lineTo(x + teethWidth, 0);
      x += teethWidth;
    }
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════════
//  RINCIAN TRANSAKSI
//  FIX: Kurangi saldo di UserData saat transfer berhasil
// ══════════════════════════════════════════════════════════════

class RincianTransaksiScreen extends StatefulWidget {
  final String metode;
  final String namaPenerima;
  final String nomorPenerima;
  final int    nominal;

  const RincianTransaksiScreen({
    super.key,
    required this.metode,
    required this.namaPenerima,
    required this.nomorPenerima,
    required this.nominal,
  });

  @override
  State<RincianTransaksiScreen> createState() =>
      _RincianTransaksiScreenState();
}

class _RincianTransaksiScreenState
    extends State<RincianTransaksiScreen> {
  final ScreenshotController _screenshotController =
      ScreenshotController();
  bool _isProcessing = false;

  late final String _idTrx;
  late final String _noTrx;
  late final String _tanggal;
  late final String _maskedName;

  @override
  void initState() {
    super.initState();
    _idTrx       = _generateId();
    _noTrx       = _generateNoTrx();
    _tanggal     = _formatTanggal();
    _maskedName  = _maskName(widget.namaPenerima);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Catat riwayat
      RiwayatStore.tambahTransfer(
          widget.metode, _maskedName, widget.nominal);

      // FIX: Kurangi saldo di UserData setelah transfer
      final userData = UserData();
      await userData.load();
      final saldoBaru =
          (userData.saldo - widget.nominal).clamp(0.0, double.infinity);
      userData.saldo = saldoBaru;
      await userData.simpan();
    });
  }

  String _fmt(int amount) =>
      'Rp. ' +
      amount
          .toString()
          .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]}.');

  String _maskName(String name) {
    if (name == 'Nomor Manual') return name;
    if (name.length <= 4) return name;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      final first = parts[0];
      final last  = parts.last;
      return '${first.substring(0, min(3, first.length))}***'
          '${last.substring(max(0, last.length - 2))}';
    }
    return '${name.substring(0, 3)}***'
        '${name.substring(max(3, name.length - 2))}';
  }

  String _generateId() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.hour}${now.minute}${now.second}';
  }

  String _generateNoTrx() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final r = Random();
    return List.generate(8, (_) => chars[r.nextInt(chars.length)])
        .join();
  }

  String _formatTanggal() {
    final now = DateTime.now();
    const bln = [
      '', 'januari', 'februari', 'maret', 'april', 'mei', 'juni',
      'juli', 'agustus', 'september', 'oktober', 'november', 'desember'
    ];
    return '${now.day} ${bln[now.month]} ${now.year} - '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  Future<Uint8List?> _captureStruk() async {
    try {
      final image = await _screenshotController.captureFromLongWidget(
        InheritedTheme.captureAll(
          context,
          Material(
            color: Colors.transparent,
            child: StrukWidget(
              metode: widget.metode,
              namaPenerima: _maskedName,
              nomorPenerima: widget.nomorPenerima,
              nominal: widget.nominal,
              idTrx: _idTrx,
              noTrx: _noTrx,
              tanggal: _tanggal,
            ),
          ),
        ),
        pixelRatio: 3.0,
        context: context,
      );
      return image;
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

  Future<void> _unduhStruk() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final bytes = await _captureStruk();
      if (bytes == null) throw Exception('Gagal membuat gambar struk');
      final dir = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();
      if (!await dir.exists()) await dir.create(recursive: true);
      final fileName =
          'struk_${_noTrx}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: AppIconSize.md),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    'Struk disimpan ke '
                    '${Platform.isAndroid ? "Download" : "Dokumen"}',
                    style: const TextStyle(fontSize: AppTypography.bodySmall))),
          ]),
          backgroundColor: kPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal mengunduh struk: $e'),
          backgroundColor: kDanger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _berbagiStruk() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final bytes = await _captureStruk();
      if (bytes == null) throw Exception('Gagal membuat gambar struk');
      final tempDir = await getTemporaryDirectory();
      final fileName = 'struk_${_noTrx}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'Struk Top-up Ewallet ${widget.metode} — ${_fmt(widget.nominal)}\n'
            'Kepada: $_maskedName\n'
            'No. Transaksi: $_noTrx\n'
            'Tanggal: $_tanggal',
        subject: 'Struk Top-up Ewallet ${widget.metode}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal berbagi struk: $e'),
          backgroundColor: kDanger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          _buildAppBar('Keuangan', showBack: true, context: context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                            Icons.compare_arrows_rounded,
                            color: kPrimary,
                            size: AppIconSize.md),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(_fmt(widget.nominal),
                          style: const TextStyle(
                              fontSize: AppTypography.subtitle,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87)),
                      const SizedBox(height: 6),
                      Text('Top-up ke ${widget.metode}',
                          style: TextStyle(
                              fontSize: AppTypography.bodySmall,
                              color: Colors.grey.shade600)),
                      Text(_maskedName,
                          style: TextStyle(
                              fontSize: AppTypography.bodySmall,
                              color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text(_tanggal,
                          style: TextStyle(
                              fontSize: AppTypography.caption,
                              color: Colors.grey.shade500)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Berhasil',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppTypography.body)),
                          const SizedBox(width: 6),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                                color: kPrimary,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.check,
                                color: Colors.white, size: AppIconSize.sm),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Rincian Transaksi',
                            style: TextStyle(
                                fontSize: AppTypography.body,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 16),
                      _row('ID Transaksi', _idTrx),
                      const SizedBox(height: 10),
                      _row('Nomor Transaksi', _noTrx),
                      const SizedBox(height: 10),
                      _row('Nominal Transaksi', _fmt(widget.nominal)),
                      const SizedBox(height: 10),
                      _row('Total', _fmt(widget.nominal), bold: true),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionBtn(
                    icon: Icons.share_outlined,
                    label: 'Bagikan',
                    onTap: _berbagiStruk),
                const SizedBox(width: 16),
                _actionBtn(
                    icon: Icons.download_outlined,
                    label: 'Unduh',
                    onTap: _unduhStruk),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.popUntil(
                    context, (route) => route.isFirst),
                icon: const Icon(Icons.home_rounded,
                    color: Colors.white),
                label: const Text('Kembali ke Dashboard',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.button,
                        fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: AppTypography.bodySmall,
                color: Colors.grey.shade600,
                fontWeight:
                    bold ? FontWeight.w700 : FontWeight.w400)),
        Text(value,
            style: TextStyle(
                fontSize: AppTypography.bodySmall,
                fontWeight:
                    bold ? FontWeight.w800 : FontWeight.w500,
                color: Colors.black87)),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isProcessing ? null : onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _isProcessing
                  ? Colors.grey.shade200
                  : kPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _isProcessing
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: kPrimary),
                    ),
                  )
                : Icon(icon, color: kPrimary, size: AppIconSize.sm),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: AppTypography.caption,
                  color: _isProcessing ? Colors.grey : kPrimary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SHARED AppBar
// ══════════════════════════════════════════════════════════════

PreferredSizeWidget _buildAppBar(
  String title, {
  required bool showBack,
  required BuildContext context,
  VoidCallback? onBack,
}) {
  return AppBar(
    backgroundColor: kBg,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    leading: showBack
        ? IconButton(
            onPressed: () {
              if (onBack != null) {
                onBack();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            icon: const Icon(Icons.arrow_back, size: AppIconSize.lg, color: kText),
          )
        : null,
    title: Text(
      title,
      style: const TextStyle(
        color: kText,
        fontWeight: FontWeight.w800,
        fontSize: AppTypography.subtitle,
      ),
    ),
    centerTitle: false,
  );
}

// ══════════════════════════════════════════════════════════════
//  DETAIL TRANSAKSI MODAL
// ══════════════════════════════════════════════════════════════

void _showDetailTransaksi(BuildContext context, RiwayatTransaksi item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final isCash = item.jenis == JenisTransaksi.cash;
      final statusColor = item.status == 'pending'
          ? kWarning
          : (item.status == 'ditolak' ? kDanger : kPrimary);

      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Handle
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header: Receipt Title & Type
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCash ? const Color(0xFFFFF4E5) : kPrimaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isCash ? Icons.payments_outlined : Icons.account_balance_wallet_outlined,
                    color: isCash ? kWarning : kPrimaryDark,
                    size: AppIconSize.sm,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.judul,
                        style: const TextStyle(
                          fontSize: AppTypography.bodySmall,
                          fontWeight: FontWeight.w700,
                          color: kText,
                                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCash ? 'Tarik tunai Rumah Hijau' : 'Top-up Ewallet',
                        style: const TextStyle(
                          fontSize: AppTypography.caption,
                          color: kTextSoft,
                                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),

            // Detail List
            _buildDetailRow('Status', Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                item.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: AppTypography.caption,
                          letterSpacing: 0.5,
                ),
              ),
            )),

            if (item.id != null) ...[
              const SizedBox(height: 16),
              _buildDetailRow('ID Transaksi', Text(
                '#${item.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: kText,
                        ),
              )),
            ],

            const SizedBox(height: 16),
            _buildDetailRow('Tanggal', Text(
              item.tanggal,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: kText,
                    ),
            )),

            if (item.metodeBayar != null) ...[
              const SizedBox(height: 16),
              _buildDetailRow('Metode', Text(
                item.metodeBayar!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: kText,
                        ),
              )),
            ],

            if (item.noRekening != null) ...[
              const SizedBox(height: 16),
              _buildDetailRow(
                isCash ? 'Nomor ponsel' : 'No. Ewallet',
                Text(
                  item.noRekening!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: kText,
                            ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),

            // Nominal
            _buildDetailRow('Nominal', Text(
              item.nominal,
              style: TextStyle(
                fontSize: AppTypography.subtitle,
                fontWeight: FontWeight.w800,
                color: item.isPlus ? kPrimary : kDanger,
                    ),
            )),

            const SizedBox(height: 30),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildDetailRow(String label, Widget valueWidget) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: kTextSoft,
          fontSize: AppTypography.bodySmall,
          fontWeight: FontWeight.w500,
        ),
      ),
      valueWidget,
    ],
  );
}

// ============================================================================
// TARIK TUNAI RUMAH HIJAU - ALUR PROYEK 3
// ============================================================================
class CashWithdrawalScreen extends StatefulWidget {
  const CashWithdrawalScreen({super.key});

  @override
  State<CashWithdrawalScreen> createState() => _CashWithdrawalScreenState();
}

class _CashWithdrawalScreenState extends State<CashWithdrawalScreen> {
  static const _quickAmounts = [10000, 25000, 50000, 100000, 200000];
  final _controller = TextEditingController();
  double _balance = 0;
  String _phone = '-';
  String _amount = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = UserData();
    await user.load();
    if (!mounted) return;
    setState(() {
      _balance = user.saldo;
      _phone = user.noTelpon.trim().isEmpty ? '-' : user.noTelpon.trim();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _value => int.tryParse(_amount) ?? 0;

  String _money(num value) => value.round().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );

  void _continue() {
    final value = _value;
    if (value < 10000) {
      _message('Minimal penarikan tunai adalah Rp10.000.');
      return;
    }
    if (value > _balance) {
      _message('Nominal melebihi saldo yang tersedia.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CashReviewScreen(
          amount: value,
          phone: _phone,
        ),
      ),
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar('Tarik tunai', showBack: true, context: context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7EC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0DFC3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kPrimaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.eco_rounded, color: kPrimaryDark, size: AppIconSize.md),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('admin', style: TextStyle(color: kTextSoft, fontSize: AppTypography.overline)),
                        SizedBox(height: 2),
                        Text('Rumah Hijau', style: TextStyle(color: kText, fontSize: AppTypography.bodySmall, fontWeight: FontWeight.w800)),
                        SizedBox(height: 3),
                        Text('Penarikan uang tunai di lokasi mitra', style: TextStyle(color: kTextSoft, fontSize: AppTypography.overline)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Nominal tarik tunai', style: TextStyle(color: kText, fontSize: AppTypography.bodySmall, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: false,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => setState(() => _amount = value),
              decoration: InputDecoration(
                hintText: '0',
                prefixText: 'Rp  ',
                prefixStyle: const TextStyle(color: kText, fontWeight: FontWeight.w700),
                helperText: 'Minimal penarikan Rp10.000',
                helperStyle: const TextStyle(color: kTextSoft, fontSize: AppTypography.caption),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amount) {
                return ActionChip(
                  label: Text('Rp ${_money(amount)}'),
                  onPressed: () {
                    _controller.text = amount.toString();
                    setState(() => _amount = amount.toString());
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Saldo tersedia: Rp ${_money(_balance)}', style: const TextStyle(color: kTextSoft, fontSize: AppTypography.caption)),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Lanjutkan', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CashReviewScreen extends StatelessWidget {
  final int amount;
  final String phone;
  const CashReviewScreen({super.key, required this.amount, required this.phone});

  String _money(num value) => value.round().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );

  @override
  Widget build(BuildContext context) {
    const fee = 0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar('Periksa rincian', showBack: true, context: context),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Periksa rincian nominal dan biaya transaksi', style: TextStyle(color: kText, fontSize: AppTypography.subtitle, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Pastikan nominal dan nomor ponsel sudah benar sebelum konfirmasi.', style: TextStyle(color: kTextSoft, fontSize: AppTypography.caption)),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
              child: Column(
                children: [
                  _row('Tujuan', 'Rumah Hijau'),
                  _row('Nominal tarik tunai', 'Rp ${_money(amount)}'),
                  _row('Biaya transaksi', fee == 0 ? 'Gratis' : 'Rp ${_money(fee)}'),
                  const Divider(height: 26),
                  _row('Total', 'Rp ${_money(amount + fee)}', strong: true),
                  _row('Nomor ponsel terdaftar', phone),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CashPinScreen(amount: amount, phone: phone)),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('Konfirmasi', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool strong = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: kTextSoft, fontSize: AppTypography.caption))),
            Flexible(child: Text(value, textAlign: TextAlign.right, style: TextStyle(color: kText, fontSize: strong ? 16 : 12, fontWeight: strong ? FontWeight.w800 : FontWeight.w600))),
          ],
        ),
      );
}

class CashPinScreen extends StatefulWidget {
  final int amount;
  final String phone;
  const CashPinScreen({super.key, required this.amount, required this.phone});

  @override
  State<CashPinScreen> createState() => _CashPinScreenState();
}

class _CashPinScreenState extends State<CashPinScreen> {
  String _pin = '';
  bool _loading = false;
  static const _length = 6;

  void _key(String value) {
    if (value == 'DEL') {
      if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
    } else if (_pin.length < _length) {
      setState(() => _pin += value);
    }
  }

  Future<void> _submit() async {
    if (_pin.length != _length) return;
    setState(() => _loading = true);
    final result = await ApiService().ajukanPenarikan(
      jumlahTarik: widget.amount.toDouble(),
      metodeBayar: 'Tarik Tunai - Rumah Hijau',
      noRekening: widget.phone,
      pin: _pin,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result['success'] == true) {
      final token = (DateTime.now().millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0');
      RiwayatStore.tambahTransfer('Rumah Hijau', widget.phone, widget.amount, jenis: JenisTransaksi.cash);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CashTokenScreen(token: token, phone: widget.phone, amount: widget.amount)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Penarikan gagal'), behavior: SnackBarBehavior.floating));
      setState(() => _pin = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar('Masukkan PIN', showBack: true, context: context),
      body: Column(
        children: [
          const Spacer(),
          const Text('Masukkan PIN yang telah dibuat', style: TextStyle(color: kText, fontSize: AppTypography.body, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_length, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: i < _pin.length ? kPrimary : kBorder)))),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                _row(['1', '2', '3']),
                const SizedBox(height: 12),
                _row(['4', '5', '6']),
                const SizedBox(height: 12),
                _row(['7', '8', '9']),
                const SizedBox(height: 12),
                _row(['', '0', 'DEL']),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _pin.length == _length && !_loading ? _submit : null,
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary, disabledBackgroundColor: kBorder, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Konfirmasi', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(List<String> keys) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((value) {
          if (value.isEmpty) return const SizedBox(width: 80, height: 60);
          return GestureDetector(
            onTap: () => _key(value),
            child: Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Center(child: value == 'DEL' ? const Icon(Icons.backspace_outlined) : Text(value, style: const TextStyle(fontSize: AppTypography.title, fontWeight: FontWeight.w500))),
            ),
          );
        }).toList(),
      );
}

class CashTokenScreen extends StatelessWidget {
  final String token;
  final String phone;
  final int amount;
  const CashTokenScreen({super.key, required this.token, required this.phone, required this.amount});

  String _money(num value) => value.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar('Kode tarik tunai', showBack: false, context: context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
              decoration: BoxDecoration(color: kPrimaryDark, borderRadius: BorderRadius.circular(22)),
              child: Column(
                children: [
                  const Icon(Icons.verified_outlined, color: Colors.white, size: AppIconSize.lg),
                  const SizedBox(height: 10),
                  const Text('Kode tarik tunai', style: TextStyle(color: Colors.white70, fontSize: AppTypography.bodySmall)),
                  const SizedBox(height: 8),
                  SelectableText(token, style: const TextStyle(color: Colors.white, fontSize: AppTypography.display, fontWeight: FontWeight.w900, letterSpacing: 8)),
                  const SizedBox(height: 10),
                  const Text('Berlaku selama 60 menit', style: TextStyle(color: Color(0xFFDDE5C9), fontSize: AppTypography.caption, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sampaikan kepada admin Rumah Hijau', style: TextStyle(color: kText, fontSize: AppTypography.body, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text('Nomor ponsel terdaftar: $phone', style: const TextStyle(color: kText, fontSize: AppTypography.bodySmall)),
                  const SizedBox(height: 4),
                  Text('Nominal: Rp ${_money(amount)}', style: const TextStyle(color: kTextSoft, fontSize: AppTypography.caption)),
                  const SizedBox(height: 12),
                  const Text('Tunjukkan atau bacakan nomor ponsel dan kode ini kepada admin. Admin akan memproses transaksi dan menyerahkan uang tunai fisik.', style: TextStyle(color: kTextSoft, fontSize: AppTypography.caption, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
