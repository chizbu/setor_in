import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:math';
import 'app_theme.dart';

import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'user_data.dart'; // ← TAMBAHAN: import UserData

// ══════════════════════════════════════════════════════════════
//  MODEL RIWAYAT TRANSAKSI
// ══════════════════════════════════════════════════════════════

enum JenisTransaksi { tukarKoin, transfer }

class RiwayatTransaksi {
  final JenisTransaksi jenis;
  final String judul;
  final String subjudul;
  final String tanggal;
  final String nominal;
  final bool isPlus;

  const RiwayatTransaksi({
    required this.jenis,
    required this.judul,
    required this.subjudul,
    required this.tanggal,
    required this.nominal,
    required this.isPlus,
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

  static void tambahTukarKoin(int koin, int saldo) {
    tambah(RiwayatTransaksi(
      jenis: JenisTransaksi.tukarKoin,
      judul: 'Tukar Koin',
      subjudul: '$koin koin → Rp ${_fmt(saldo)}',
      tanggal: _nowStr(),
      nominal: '+Rp ${_fmt(saldo)}',
      isPlus: true,
    ));
  }

  static void tambahTransfer(String metode, String penerima, int nominal) {
    tambah(RiwayatTransaksi(
      jenis: JenisTransaksi.transfer,
      judul: 'Transfer ke $metode',
      subjudul: penerima,
      tanggal: _nowStr(),
      nominal: '-Rp ${_fmt(nominal)}',
      isPlus: false,
    ));
  }
}

// ══════════════════════════════════════════════════════════════
//  KEUANGAN SCREEN
//  FIX: Baca koin & saldo dari UserData (bukan hardcoded 0)
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

  /// Load UserData lalu rebuild UI
  Future<void> _loadData() async {
    _userData.resetLoadFlag();
    await _userData.load();
    if (mounted) setState(() => _isLoading = false);
  }

  /// Dipanggil setiap kali kembali dari sub-screen agar data fresh
  Future<void> _reloadData() async {
    _userData.resetLoadFlag();
    await _userData.load();
    if (mounted) setState(() {});
  }

  // ── Getter shortcut ──────────────────────────────────────
  double get _saldo => _isLoading ? 0 : _userData.saldo;
  int    get _koin  => _isLoading ? 0 : _userData.koin;

  // ────────────────────────────────────────────────────────
  Widget _buildTopSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kartu saldo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kPrimaryDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  const Text('Saldomu',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _showSaldo = !_showSaldo),
                    child: Icon(
                      _showSaldo
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white70,
                      size: 18,
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
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.monetization_on_outlined,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  // FIX: tampilkan _koin dari UserData
                  Text(
                    _isLoading ? 'Koinmu  ...' : 'Koinmu  $_koin',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Menu aksi
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMenuTile(
              icon: Icons.swap_horiz,
              label: 'Tukar koin',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    // FIX: kirim _koin terbaru dari UserData
                    builder: (_) => TukarKoinScreen(koin: _koin),
                  ),
                );
                // FIX: reload setelah tukar koin agar UI update
                await _reloadData();
              },
            ),
            _buildMenuTile(
              icon: Icons.compare_arrows_rounded,
              label: 'Transfer',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const MetodePembayaranScreen(isTransfer: true)),
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
    final isTransfer = item.jenis == JenisTransaksi.transfer;
    final iconData =
        isTransfer ? Icons.compare_arrows_rounded : Icons.monetization_on_outlined;
    final iconColor = isTransfer ? Colors.blue.shade400 : kPrimary;
    final iconBg =
        isTransfer ? Colors.blue.shade50 : kPrimary.withOpacity(0.1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.judul,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subjudul,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
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
                  fontSize: 13,
                  color: item.isPlus ? kPrimary : Colors.red,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.tanggal.contains(',')
                    ? item.tanggal.split(',').last.trim()
                    : item.tanggal,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: kPrimary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final riwayat = RiwayatStore.data;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar('Keuangan',
          showBack: true, context: context, onBack: widget.onBack),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kPrimary))
          : Stack(
              children: [
                // Konten atas: kartu saldo + menu
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 260),
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
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
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
                                        'Riwayat',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Lihat semua',
                                        style: TextStyle(
                                          fontSize: 13,
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
                                          size: 48,
                                          color: Colors.grey.shade300),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Belum ada transaksi',
                                        style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 13),
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
  int _filterIndex = 0; // 0=Semua, 1=Tukar Koin, 2=Transfer

  String _fmt(int n) => n
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  List<RiwayatTransaksi> get _filtered {
    if (_filterIndex == 1) {
      return RiwayatStore.data
          .where((r) => r.jenis == JenisTransaksi.tukarKoin)
          .toList();
    } else if (_filterIndex == 2) {
      return RiwayatStore.data
          .where((r) => r.jenis == JenisTransaksi.transfer)
          .toList();
    }
    return RiwayatStore.data;
  }

  int get _totalMasuk =>
      _filtered.where((r) => r.isPlus).fold(0, (sum, r) {
        final angka = r.nominal.replaceAll(RegExp(r'[^\d]'), '');
        return sum + (int.tryParse(angka) ?? 0);
      });

  int get _totalKeluar =>
      _filtered.where((r) => !r.isPlus).fold(0, (sum, r) {
        final angka = r.nominal.replaceAll(RegExp(r'[^\d]'), '');
        return sum + (int.tryParse(angka) ?? 0);
      });

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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 20),
                child: Row(
                  children: [
                    _summaryCol('Total masuk',
                        '+Rp ${_fmt(_totalMasuk)}', kPrimary),
                    Container(
                        width: 1,
                        height: 32,
                        color: Colors.grey.shade200),
                    _summaryCol('Total keluar',
                        '-Rp ${_fmt(_totalKeluar)}', Colors.red),
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
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _chip('Semua', 0),
                const SizedBox(width: 8),
                _chip('Tukar Koin', 1),
                const SizedBox(width: 8),
                _chip('Transfer', 2),
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
                          size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada transaksi',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14),
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
                                fontSize: 12,
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
      onTap: () => setState(() => _filterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? kPrimary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
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
                  TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildTile(RiwayatTransaksi item) {
    final isTransfer = item.jenis == JenisTransaksi.transfer;
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isTransfer
                  ? Colors.blue.shade50
                  : kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isTransfer
                  ? Icons.compare_arrows_rounded
                  : Icons.monetization_on_outlined,
              color: isTransfer ? Colors.blue.shade400 : kPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.judul,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(item.subjudul,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 11)),
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
                  fontSize: 13,
                  color: item.isPlus ? kPrimary : Colors.red,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.tanggal.contains(',')
                    ? item.tanggal.split(',').last.trim()
                    : item.tanggal,
                style: TextStyle(
                    fontSize: 10, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TUKAR KOIN SCREEN
//  FIX: Kurangi koin di UserData dan tambah saldo setelah tukar
// ══════════════════════════════════════════════════════════════

class TukarKoinScreen extends StatefulWidget {
  final int koin;
  const TukarKoinScreen({super.key, required this.koin});

  @override
  State<TukarKoinScreen> createState() => _TukarKoinScreenState();
}

class _TukarKoinScreenState extends State<TukarKoinScreen> {
  final TextEditingController _ctrl = TextEditingController();
  int _jumlahKoin = 0;

  static const int _nilaiPerKoin = 100;

  int    get _saldoDidapat => _jumlahKoin * _nilaiPerKoin;
  bool   get _canProceed   =>
      _jumlahKoin > 0 && _jumlahKoin <= widget.koin;

  String _fmt(int amount) => amount
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          _buildAppBar('Tukar Koin', showBack: true, context: context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimaryDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on_rounded,
                      color: Colors.amber, size: 36),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Koin Kamu',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.koin} Koin',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kPrimary.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: kPrimary, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    '1 Koin = Rp ${_fmt(_nilaiPerKoin)}',
                    style: const TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Jumlah Koin yang Ditukar',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) =>
                  setState(() => _jumlahKoin = int.tryParse(v) ?? 0),
              decoration: InputDecoration(
                hintText: '0',
                suffixText: 'Koin',
                suffixStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54),
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
                errorText: _jumlahKoin > widget.koin
                    ? 'Koin tidak mencukupi'
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [10, 25, 50, 100]
                  .where((v) => v <= widget.koin)
                  .map((val) {
                return GestureDetector(
                  onTap: () {
                    _ctrl.text = val.toString();
                    setState(() => _jumlahKoin = val);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: kPrimary.withOpacity(0.3)),
                    ),
                    child: Text(
                      '$val Koin',
                      style: const TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            AnimatedOpacity(
              opacity: _canProceed ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _summaryRow('Koin ditukar', '$_jumlahKoin Koin'),
                    const SizedBox(height: 8),
                    _summaryRow(
                        'Saldo didapat',
                        'Rp ${_fmt(_saldoDidapat)}',
                        highlight: true),
                    const SizedBox(height: 8),
                    _summaryRow('Sisa koin',
                        '${widget.koin - _jumlahKoin} Koin'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _canProceed ? _tukarKoin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text(
                  'Tukar Sekarang',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── FIX: Simpan perubahan koin & saldo ke UserData ──────
  Future<void> _tukarKoin() async {
    // 1. Catat ke riwayat transaksi
    RiwayatStore.tambahTukarKoin(_jumlahKoin, _saldoDidapat);

    // 2. Update UserData (koin berkurang, saldo bertambah)
    final userData = UserData();
    await userData.load();
    userData.koin  -= _jumlahKoin;   // kurangi koin
    userData.saldo += _saldoDidapat; // tambah saldo rupiah
    await userData.simpan();         // persist ke SharedPreferences

    // 3. Tampilkan snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$_jumlahKoin koin berhasil ditukar menjadi '
            'Rp ${_fmt(_saldoDidapat)}',
          ),
          backgroundColor: kPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _summaryRow(String label, String value,
      {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade600)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                highlight ? FontWeight.w800 : FontWeight.w600,
            color: highlight ? kPrimary : Colors.black87,
          ),
        ),
      ],
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
  final List<String> _metode = ['Dana', 'OVO', 'Gopay', 'Shoopepay'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar('Keuangan',
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
                      color: Colors.black.withOpacity(0.04),
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
                                        fontSize: 15,
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
                                        color: Colors.white, size: 14)
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
                        fontSize: 16,
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
      Colors.blue.shade100,
      Colors.orange.shade100,
      Colors.purple.shade100,
      Colors.teal.shade100
    ];
    return list[initial.codeUnitAt(0) % list.length];
  }

  Color _avatarFg(String initial) {
    final list = [
      Colors.pink.shade400,
      Colors.blue.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400
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
                      color: Colors.grey.shade500, size: 20),
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
                            color: Colors.grey, fontSize: 14),
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
                          color: Colors.grey.shade500, size: 18),
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
                    color: kPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: kPrimary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.2),
                            shape: BoxShape.circle),
                        child: const Icon(
                            Icons.send_to_mobile_outlined,
                            color: kPrimary,
                            size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('Kirim ke nomor ini',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: kPrimary)),
                          Text(_query,
                              style: TextStyle(
                                  fontSize: 13,
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
                      fontSize: 14,
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
                                  size: 60,
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
                                      fontSize: 13)),
                            ],
                          ),
                        )
                      : _filtered.isEmpty
                          ? Center(
                              child: Text('Kontak tidak ditemukan',
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14)))
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
                                          .withOpacity(0.04),
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
                                                    fontSize: 16)),
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
                                                      fontSize: 14)),
                                              Text(phone,
                                                  style: TextStyle(
                                                      color: Colors.grey
                                                          .shade500,
                                                      fontSize: 12)),
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
                    radius: 24,
                    backgroundColor: Colors.pink.shade100,
                    child: Text(
                      widget.namaPenerima.isNotEmpty
                          ? widget.namaPenerima[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          color: Colors.pink.shade400,
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_maskName(widget.namaPenerima),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                      Text(widget.nomorPenerima,
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(widget.metode,
                            style: TextStyle(
                                color: kPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('Nominal Transfer',
                style: TextStyle(
                    fontSize: 15,
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
                      color: kPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: kPrimary.withOpacity(0.3)),
                    ),
                    child: Text('Rp ${_fmt(amt)}',
                        style: TextStyle(
                            color: kPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
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
                        fontSize: 16,
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

  void _konfirmasi() {
    if (_pin.length < _pinLength) {
      _snack('Masukkan PIN 6 digit', Colors.red);
      return;
    }
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
                  fontSize: 16, fontWeight: FontWeight.w600)),
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
                    _pin.length == _pinLength ? _konfirmasi : null,
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
                        fontSize: 16,
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
                      size: 22, color: Colors.black87)
                  : Text(key,
                      style: const TextStyle(
                          fontSize: 22,
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.compare_arrows_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  _fmt(nominal),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
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
                            fontSize: 14,
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
                          color: Colors.white, size: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(tanggal,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
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
                    color: kPrimary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: kPrimary.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Transfer',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                      Text(_fmt(nominal),
                          style: const TextStyle(
                              fontSize: 16,
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
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text('Transaksi terenkripsi & aman',
                        style: TextStyle(
                            fontSize: 11,
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
          child: Icon(icon, size: 16, color: Colors.grey.shade500),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w400)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
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
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    'Struk disimpan ke '
                    '${Platform.isAndroid ? "Download" : "Dokumen"}',
                    style: const TextStyle(fontSize: 13))),
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
          backgroundColor: Colors.red,
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
        text: 'Struk Transfer ${widget.metode} — ${_fmt(widget.nominal)}\n'
            'Kepada: $_maskedName\n'
            'No. Transaksi: $_noTrx\n'
            'Tanggal: $_tanggal',
        subject: 'Struk Transfer ${widget.metode}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal berbagi struk: $e'),
          backgroundColor: Colors.red,
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
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                            Icons.compare_arrows_rounded,
                            color: kPrimary,
                            size: 28),
                      ),
                      const SizedBox(height: 16),
                      Text(_fmt(widget.nominal),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87)),
                      const SizedBox(height: 6),
                      Text('Ditransfer ke ${widget.metode}',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600)),
                      Text(_maskedName,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text(_tanggal,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Berhasil',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                          const SizedBox(width: 6),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                                color: kPrimary,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.check,
                                color: Colors.white, size: 14),
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
                                fontSize: 15,
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
                        fontSize: 15,
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
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight:
                    bold ? FontWeight.w700 : FontWeight.w400)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
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
                  : kPrimary.withOpacity(0.12),
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
                : Icon(icon, color: kPrimary, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
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
    backgroundColor: Colors.white,
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
                Navigator.popUntil(
                    context, (route) => route.isFirst);
              }
            },
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black87, width: 2),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Colors.black87),
            ),
          )
        : null,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
    ),
    centerTitle: true,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Divider(height: 1, color: Colors.grey.shade200),
    ),
  );
}