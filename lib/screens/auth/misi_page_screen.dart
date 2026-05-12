import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'target_sampah_screen.dart';
import 'user_data.dart'; // ← TAMBAHAN

// ══════════════════════════════════════════════════════
//  CATATAN SETUP:
//  Tambahkan di pubspec.yaml dependencies:
//    shared_preferences: ^2.2.2
//  Lalu jalankan: flutter pub get
//
//  ENTRY POINT dari dashboard:
//  Navigator.push(context, MaterialPageRoute(
//    builder: (_) => const MisiPageScreen()));
// ══════════════════════════════════════════════════════

// ─── Key konstanta SharedPreferences ──────────────────
const String _kTargetKg        = 'misi_target_kg';
const String _kEstimasiKoin    = 'misi_estimasi_koin';
const String _kSudahBuatTarget = 'misi_sudah_buat_target';
const String _kTanggalTarget   = 'misi_tanggal_target';
const String _kHariSelesai     = 'misi_hari_selesai';
const String _kTotalKoin       = 'misi_total_koin';

// ══════════════════════════════════════════════════════
//  MisiPageScreen  –  Screen 1 & 3
// ══════════════════════════════════════════════════════
class MisiPageScreen extends StatefulWidget {
  const MisiPageScreen({super.key});

  @override
  State<MisiPageScreen> createState() => _MisiPageScreenState();
}

class _MisiPageScreenState extends State<MisiPageScreen> {
  double     _targetKg        = 0;
  int        _estimasiKoin    = 0;
  bool       _sudahBuatTarget = false;
  DateTime?  _tanggalTarget;
  List<bool> _hariSelesai     = [];
  int        _totalKoin       = 0;
  bool       _loading         = true;

  // ── Jumlah hari misi ────────────────────────────────
  int get _totalHariMisi {
    if (_tanggalTarget == null) return 0;
    final today      = DateTime.now();
    final todayOnly  = DateTime(today.year, today.month, today.day);
    final targetOnly = DateTime(
        _tanggalTarget!.year, _tanggalTarget!.month, _tanggalTarget!.day);
    final diff = targetOnly.difference(todayOnly).inDays;
    return (diff - 1).clamp(1, 365);
  }

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  // ── Persist: LOAD ────────────────────────────────────
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _targetKg        = prefs.getDouble(_kTargetKg) ?? 0;
      _estimasiKoin    = prefs.getInt(_kEstimasiKoin) ?? 0;
      _sudahBuatTarget = prefs.getBool(_kSudahBuatTarget) ?? false;
      _totalKoin       = prefs.getInt(_kTotalKoin) ?? 0;

      final tanggalStr = prefs.getString(_kTanggalTarget);
      if (tanggalStr != null) {
        _tanggalTarget = DateTime.tryParse(tanggalStr);
      }

      final hariJson = prefs.getString(_kHariSelesai);
      if (hariJson != null) {
        final list = jsonDecode(hariJson) as List;
        _hariSelesai = list.map((e) => e as bool).toList();
      } else if (_sudahBuatTarget && _tanggalTarget != null) {
        _hariSelesai = List.generate(_totalHariMisi, (_) => false);
      }

      _loading = false;
    });
  }

  // ── Persist: SAVE ────────────────────────────────────
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kTargetKg, _targetKg);
    await prefs.setInt(_kEstimasiKoin, _estimasiKoin);
    await prefs.setBool(_kSudahBuatTarget, _sudahBuatTarget);
    await prefs.setInt(_kTotalKoin, _totalKoin);
    if (_tanggalTarget != null) {
      await prefs.setString(
          _kTanggalTarget, _tanggalTarget!.toIso8601String());
    }
    await prefs.setString(_kHariSelesai, jsonEncode(_hariSelesai));
  }

  void _initHariSelesai() {
    _hariSelesai = List.generate(_totalHariMisi, (_) => false);
  }

  int get _nextUnlockedIndex {
    for (int i = 0; i < _hariSelesai.length; i++) {
      if (!_hariSelesai[i]) return i;
    }
    return -1;
  }

  // ── Pilih tanggal ────────────────────────────────────
  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalTarget ?? now.add(const Duration(days: 7)),
      firstDate: now.add(const Duration(days: 2)),
      lastDate: DateTime(now.year + 1),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF22C55E),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _tanggalTarget = picked;
        if (_sudahBuatTarget) _initHariSelesai();
      });
      await _saveState();
    }
  }

  // ── Buka Form Target ─────────────────────────────────
  Future<void> _bukaFormTarget() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const TargetSampahScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        _targetKg        = (result['totalKg'] as num).toDouble();
        _estimasiKoin    = result['totalKoin'] as int;
        _sudahBuatTarget = true;
        _tanggalTarget ??= DateTime.now().add(const Duration(days: 30));
        _initHariSelesai();
      });
      await _saveState();
    }
  }

  // ── Buka Jalankan Misi ───────────────────────────────
  Future<void> _bukaJalankanMisi(int index) async {
    if (!_sudahBuatTarget || _hariSelesai.isEmpty) return;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => JalankanMisiScreen(
          hariKe: index + 1,
          hariIndex: index,
          targetKgHariIni: _targetKg / _totalHariMisi,
        ),
      ),
    );

    if (result != null && mounted) {
      final selesai   = result['selesai'] as bool;
      final koinDapat = result['koinDapat'] as int? ?? 0;

      if (selesai && koinDapat > 0) {
        // ── KUNCI FIX: simpan koin ke UserData ──────────
        final userData = UserData();
        await userData.load();          // pastikan data terbaru
        userData.koin += koinDapat;     // tambah koin
        await userData.simpan();        // persist ke SharedPreferences
        // ─────────────────────────────────────────────────

        setState(() {
          _hariSelesai[index] = true;
          _totalKoin          += koinDapat;
        });
      }

      await _saveState();
    }
  }

  // ── Format tanggal ───────────────────────────────────
  String _fmtTanggal(DateTime? dt) {
    if (dt == null) return 'tanggal / bulan / tahun';
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  }

  // ── Build ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFF22C55E))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_sudahBuatTarget) _infoBanner(),
                    _jadwalCard(),
                    _targetCard(),
                    const SizedBox(height: 20),
                    _sectionTitle('Jalankan Misi'),
                    const SizedBox(height: 12),
                    _lockGrid(),
                    if (_totalKoin > 0) _koinBanner(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black87, width: 2),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Colors.black87),
            ),
          ),
          const Expanded(
            child: Text(
              'Targetkan Sampah',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.info_rounded, color: Color(0xFF1D4ED8), size: 16),
            SizedBox(width: 6),
            Flexible(
                child: Text('Fitur Misi Penargetan Sampah',
                    style: TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w700,
                        fontSize: 13))),
          ]),
          const SizedBox(height: 6),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                  color: Color(0xFF374151), fontSize: 12, height: 1.5),
              children: [
                TextSpan(
                    text: 'Fitur ini membantu Anda merencanakan dan '
                        'mengestimasi sampah yang akan disetor ke bank sampah. '
                        'Selesaikan misi harian untuk mendapatkan '),
                TextSpan(
                    text: 'koin reward',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: ' sebagai motivasi!\n\n'),
                TextSpan(text: '💡 '),
                TextSpan(
                    text: 'Tidak tahu estimasi berat?',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(
                    text:
                        ' Cek panduan estimasi berat di halaman penargetan.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _jadwalCard() {
    return GestureDetector(
      onTap: _pilihTanggal,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _tanggalTarget != null
                ? const Color(0xFF22C55E).withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: Color(0xFF22C55E), size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                      color: Color(0xFF374151), fontSize: 13, height: 1.4),
                  children: [
                    const TextSpan(
                        text:
                            'Jadwal penyetoran sampah berikutnya di tanggal : '),
                    TextSpan(
                      text: _fmtTanggal(_tanggalTarget),
                      style: TextStyle(
                        color: _tanggalTarget != null
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              _tanggalTarget != null
                  ? Icons.edit_calendar_rounded
                  : Icons.calendar_month_outlined,
              color: const Color(0xFF22C55E),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _targetCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: _sudahBuatTarget ? _targetFilled() : _targetEmpty(),
    );
  }

  Widget _targetEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Target bulan ini :',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        const Text('0kg',
            style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                height: 1)),
        const SizedBox(height: 6),
        const Text('Estimasi koin yang di dapatkan : 0',
            style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 12),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFFBBF24), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Anda belum membuat penargetan',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _bukaFormTarget,
                    child: const Text(
                      'Lakukan penargetan sampah',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _targetFilled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Target bulan ini :',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            GestureDetector(
              onTap: _bukaFormTarget,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(children: [
                  Icon(Icons.edit_rounded, color: Colors.white, size: 13),
                  SizedBox(width: 4),
                  Text('Ubah',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('${_targetKg.toStringAsFixed(0)}kg',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.w900,
                height: 1)),
        const SizedBox(height: 8),
        Text('Estimasi koin yang di dapatkan : $_estimasiKoin',
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.today_rounded, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text('Durasi misi : $_totalHariMisi hari',
              style:
                  const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ],
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(t,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade800)),
    );
  }

  Widget _koinBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        border: Border.all(color: const Color(0xFFFDE68A)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        const Icon(Icons.monetization_on_rounded,
            color: Color(0xFFF59E0B), size: 22),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF92400E)),
            children: [
              const TextSpan(text: 'Total koin dari misi : '),
              TextSpan(
                  text: '$_totalKoin koin',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF59E0B))),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _lockGrid() {
    final int previewCount =
        _tanggalTarget != null ? _totalHariMisi : 30;

    if (!_sudahBuatTarget || _hariSelesai.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: previewCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (_, index) => _DayCell(
            dayNumber: index + 1,
            isSelesai: false,
            isNextActive: false,
            isLocked: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                    'Buat target sampah terlebih dahulu'),
                backgroundColor: const Color(0xFFF59E0B),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 2),
              ));
            },
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _hariSelesai.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          final selesai = _hariSelesai[index];
          final isNext  = index == _nextUnlockedIndex;
          return _DayCell(
            dayNumber: index + 1,
            isSelesai: selesai,
            isNextActive: isNext,
            isLocked: false,
            onTap: isNext
                ? () => _bukaJalankanMisi(index)
                : selesai
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Selesaikan Hari ke-${_nextUnlockedIndex + 1} dulu'),
                            backgroundColor: const Color(0xFFF59E0B),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  Widget kotak hari
// ══════════════════════════════════════════════════════
class _DayCell extends StatelessWidget {
  final int dayNumber;
  final bool isSelesai, isNextActive, isLocked;
  final VoidCallback? onTap;

  const _DayCell({
    required this.dayNumber,
    required this.isSelesai,
    required this.isNextActive,
    required this.isLocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isNextActive
              ? Border.all(
                  color: const Color(0xFF22C55E), width: 2)
              : isSelesai
                  ? Border.all(
                      color: const Color(0xFF22C55E)
                          .withValues(alpha: 0.4),
                      width: 1.5)
                  : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _icon(),
            const SizedBox(height: 6),
            Text(
              'Hari ke-$dayNumber',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: (isSelesai || isNextActive)
                      ? const Color(0xFF22C55E)
                      : Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _icon() {
    if (isSelesai) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.check_circle_rounded,
            color: Color(0xFF22C55E), size: 28),
      );
    }
    if (isNextActive) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.gps_fixed_rounded,
            color: Color(0xFF22C55E), size: 26),
      );
    }
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.lock_rounded,
          color: Color(0xFFEF4444), size: 26),
    );
  }
}

// ══════════════════════════════════════════════════════
//  JalankanMisiScreen  –  Screen 4
// ══════════════════════════════════════════════════════
class JalankanMisiScreen extends StatefulWidget {
  final int hariKe;
  final int hariIndex;
  final double targetKgHariIni;

  const JalankanMisiScreen({
    super.key,
    required this.hariKe,
    required this.hariIndex,
    required this.targetKgHariIni,
  });

  @override
  State<JalankanMisiScreen> createState() => _JalankanMisiScreenState();
}

class _JalankanMisiScreenState extends State<JalankanMisiScreen> {
  String get _prefKey => 'misi_qty_hari_${widget.hariIndex}';

  final List<Map<String, dynamic>> _kategori = [
    {
      'nama': 'Plastik',
      'icon': '♻️',
      'items': [
        {'nama': 'Botol 200-330ml (kecil/sekali saji)',   'gram': 8},
        {'nama': 'Botol 500-600ml (air mineral standar)', 'gram': 16},
        {'nama': 'Botol 1 Liter',                         'gram': 30},
        {'nama': 'Botol 1.5-2 Liter (ukuran keluarga)',   'gram': 37},
        {'nama': 'Kantong Kresek Kecil',                  'gram': 4},
        {'nama': 'Kantong Kresek Sedang',                 'gram': 10},
        {'nama': 'Kantong Kresek Besar',                  'gram': 15},
        {'nama': 'Gelas Plastik',                         'gram': 5},
        {'nama': 'Kemasan Snack',                         'gram': 3},
      ],
    },
    {
      'nama': 'Karton',
      'icon': '📦',
      'items': [
        {'nama': 'Kardus Mi Instan',        'gram': 25},
        {'nama': 'Kardus Kecil (15×15cm)',  'gram': 75},
        {'nama': 'Kardus Sedang (30×30cm)', 'gram': 300},
        {'nama': 'Kardus Besar (50×50cm)',  'gram': 650},
        {'nama': 'Dus Sepatu',              'gram': 200},
      ],
    },
    {
      'nama': 'Kaca',
      'icon': '🍶',
      'items': [
        {'nama': 'Botol Sirup Kecil (250ml)', 'gram': 175},
        {'nama': 'Botol Kecap (300-350ml)',   'gram': 250},
        {'nama': 'Botol Bir (330ml)',          'gram': 225},
        {'nama': 'Botol Wine (750ml)',         'gram': 500},
        {'nama': 'Botol Besar (1L)',           'gram': 650},
        {'nama': 'Jar Selai',                  'gram': 200},
      ],
    },
    {
      'nama': 'Kertas',
      'icon': '📄',
      'items': [
        {'nama': 'Kertas HVS (per 10 lembar)', 'gram': 50},
        {'nama': 'Koran Harian',               'gram': 200},
        {'nama': 'Majalah',                    'gram': 300},
        {'nama': 'Buku Tipis (100 hal)',        'gram': 175},
        {'nama': 'Buku Sedang (300 hal)',       'gram': 500},
        {'nama': 'Buku Tebal (500 hal)',        'gram': 650},
      ],
    },
    {
      'nama': 'Kaleng',
      'icon': '🥫',
      'items': [
        {'nama': 'Kaleng Soda/Bir (330ml)',  'gram': 17},
        {'nama': 'Kaleng Minuman Energi',    'gram': 16},
        {'nama': 'Kaleng Kornet Kecil',      'gram': 50},
        {'nama': 'Kaleng Sarden',            'gram': 65},
        {'nama': 'Kaleng Susu Kental Manis', 'gram': 75},
      ],
    },
  ];

  late List<bool>      _expanded;
  late List<List<int>> _qty;
  bool _loadingProgress = true;

  @override
  void initState() {
    super.initState();
    _expanded = List.generate(_kategori.length, (_) => false);
    _qty = _kategori
        .map((k) => List<int>.filled((k['items'] as List).length, 0))
        .toList();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null) {
      final decoded = jsonDecode(saved) as List;
      setState(() {
        for (int ci = 0;
            ci < _qty.length && ci < decoded.length;
            ci++) {
          final catList = decoded[ci] as List;
          for (int ii = 0;
              ii < _qty[ci].length && ii < catList.length;
              ii++) {
            _qty[ci][ii] = catList[ii] as int;
          }
        }
      });
    }
    setState(() => _loadingProgress = false);
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(_qty));
  }

  Future<void> _clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  double get _terkumpulGram {
    double t = 0;
    for (int ci = 0; ci < _kategori.length; ci++) {
      final items = _kategori[ci]['items'] as List;
      for (int ii = 0; ii < items.length; ii++) {
        t += _qty[ci][ii] * (items[ii]['gram'] as int);
      }
    }
    return t;
  }

  int get _totalItem {
    int t = 0;
    for (final cat in _qty) for (final q in cat) t += q;
    return t;
  }

  double get _targetGram     => widget.targetKgHariIni * 1000;
  double get _progress       =>
      _targetGram > 0 ? (_terkumpulGram / _targetGram).clamp(0.0, 1.0) : 0;
  bool   get _targetTercapai => _terkumpulGram >= _targetGram;
  bool   get _bisaSubmit     => _totalItem >= 1;

  String _fmtKg(double gram) =>
      (gram / 1000).toStringAsFixed(1).replaceAll('.', ',') + 'kg';

  @override
  Widget build(BuildContext context) {
    if (_loadingProgress) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: CircularProgressIndicator(
                color: Color(0xFF22C55E))),
      );
    }

    final sisa =
        (_targetGram - _terkumpulGram).clamp(0.0, _targetGram);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(children: [
                  _progressCard(),
                  _caraBanner(),
                  ..._accordionList(),
                ]),
              ),
            ),
            _bottomBar(sisa),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              await _saveProgress();
              if (mounted) Navigator.pop(context, null);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black87, width: 2),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              'Jalankan Misi - Hari ke-${widget.hariKe}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _progressCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Target hari ini :',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(_fmtKg(_targetGram),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                ]),
            Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Terkumpul :',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(_fmtKg(_terkumpulGram),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                ]),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor:
                Colors.white.withValues(alpha: 0.25),
            valueColor:
                const AlwaysStoppedAnimation(Colors.white),
            minHeight: 7,
          ),
        ),
      ]),
    );
  }

  Widget _caraBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
              color: Color(0xFF374151), fontSize: 12, height: 1.5),
          children: [
            TextSpan(text: '🗑️ '),
            TextSpan(
                text: 'Cara Mengisi: ',
                style: TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w700)),
            TextSpan(
                text: 'Pilih kategori sampah, lalu pilih jenis spesifiknya '
                    'dan masukkan jumlahnya. Sistem akan menghitung berat total '
                    'otomatis. Setelah target tercapai, Anda akan mendapat koin reward!'),
          ],
        ),
      ),
    );
  }

  List<Widget> _accordionList() {
    return List.generate(_kategori.length, (ci) {
      final kat    = _kategori[ci];
      final items  = kat['items'] as List<Map<String, dynamic>>;
      final isOpen = _expanded[ci];
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          InkWell(
            onTap: () =>
                setState(() => _expanded[ci] = !isOpen),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(children: [
                Text(kat['icon'] as String,
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kat['nama'] as String,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    const Text('Ketuk untuk melihat pilihan',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280))),
                  ],
                )),
                Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF6B7280)),
              ]),
            ),
          ),
          if (isOpen)
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: Color(0xFFF0F0F0)))),
              child: Column(
                children: List.generate(items.length, (ii) {
                  final item = items[ii];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: ii < items.length - 1
                        ? const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Color(0xFFF5F5F5))))
                        : null,
                    child: Row(children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(item['nama'] as String,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87)),
                          Text(
                              '+${item['gram']} gram per item',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280))),
                        ],
                      )),
                      const SizedBox(width: 8),
                      _QtyButton(
                        icon: Icons.remove,
                        color: const Color(0xFFEF4444),
                        onTap: () {
                          if (_qty[ci][ii] > 0) {
                            setState(() => _qty[ci][ii]--);
                          }
                        },
                      ),
                      Container(
                        width: 36,
                        height: 30,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 6),
                        alignment: Alignment.center,
                        child: Text('${_qty[ci][ii]}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                      ),
                      _QtyButton(
                        icon: Icons.add,
                        color: const Color(0xFF22C55E),
                        onTap: () =>
                            setState(() => _qty[ci][ii]++),
                      ),
                    ]),
                  );
                }),
              ),
            ),
        ]),
      );
    });
  }

  Widget _bottomBar(double sisa) {
    final String btnLabel;
    final Color  btnColor;

    if (_targetTercapai) {
      btnLabel = 'Misi Terselesaikan ✓';
      btnColor  = const Color(0xFF16A34A);
    } else if (_bisaSubmit) {
      btnLabel =
          'Kumpulkan Seadanya  •  ${_fmtKg(_terkumpulGram)}';
      btnColor  = const Color(0xFF22C55E);
    } else {
      btnLabel = 'Kumpulkan Sampah Dulu';
      btnColor  = const Color(0xFFD1D5DB);
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _bisaSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFFD1D5DB),
                disabledForegroundColor:
                    const Color(0xFF6B7280),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(btnLabel,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '💡 Ini adalah estimasi untuk tracking. Jangan lupa setor sampah ke bank sampah untuk mendapat uang!',
            style: TextStyle(
                fontSize: 11, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Submit ───────────────────────────────────────────
  Future<void> _submit() async {
    const int koinReward = 100;

    if (_targetTercapai) {
      // Target penuh → popup + koin reward
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => MisiSelesaiDialog(
          terkumpulKg: _terkumpulGram / 1000,
          hariKe: widget.hariKe,
          koinDapat: koinReward,
          onTutup: () async {
            await _clearProgress();
            if (mounted) Navigator.pop(context); // tutup dialog
            if (mounted) {
              // ── Kembalikan koinDapat ke MisiPageScreen ──
              Navigator.pop(context, {
                'selesai': true,
                'koinDapat': koinReward, // ← diteruskan ke parent
              });
            }
          },
        ),
      );
    } else {
      // Belum penuh → simpan progress saja, tanpa koin
      await _saveProgress();
      if (mounted) {
        Navigator.pop(context, {
          'selesai': false,
          'koinDapat': 0,
        });
      }
    }
  }
}

// ══════════════════════════════════════════════════════
//  MisiSelesaiDialog
// ══════════════════════════════════════════════════════
class MisiSelesaiDialog extends StatelessWidget {
  final double terkumpulKg;
  final int    hariKe;
  final int    koinDapat;
  final VoidCallback onTutup;

  const MisiSelesaiDialog({
    super.key,
    required this.terkumpulKg,
    required this.hariKe,
    required this.koinDapat,
    required this.onTutup,
  });

  String _fmt(double kg) =>
      kg.toStringAsFixed(1).replaceAll('.', ',') + 'kg';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            padding:
                const EdgeInsets.fromLTRB(28, 52, 28, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 44),
                ),
                const SizedBox(height: 16),
                Text(
                  'Misi Hari ke-$hariKe Selesai!!',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(_fmt(terkumpulKg),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w900)),
                const Text('terkumpul hari ini',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on_rounded,
                          color: Color(0xFFFBBF24), size: 28),
                      const SizedBox(width: 10),
                      Text('+$koinDapat Koin',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text('ditambahkan ke total koinmu',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onTutup,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  Widget tombol qty + / -
// ══════════════════════════════════════════════════════
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QtyButton(
      {required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}