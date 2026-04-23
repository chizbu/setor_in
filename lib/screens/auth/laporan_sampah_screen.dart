import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────
class LaporanHarian {
  final String id;
  final DateTime tanggal;
  final Map<String, double> beratPerJenis; // {'Plastik': 1.2, 'Kertas': 0.5}
  final String catatan;
  final int koinDapat;

  LaporanHarian({
    required this.id,
    required this.tanggal,
    required this.beratPerJenis,
    required this.catatan,
    required this.koinDapat,
  });

  double get totalBerat => beratPerJenis.values.fold(0, (s, v) => s + v);

  String get tanggalFormatted {
    const bln = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${tanggal.day} ${bln[tanggal.month]} ${tanggal.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class LaporanSampahScreen extends StatefulWidget {
  const LaporanSampahScreen({super.key});

  @override
  State<LaporanSampahScreen> createState() => _LaporanSampahScreenState();
}

class _LaporanSampahScreenState extends State<LaporanSampahScreen> {
  final List<LaporanHarian> _riwayat = [
    LaporanHarian(
      id: 'l1',
      tanggal: DateTime.now().subtract(const Duration(days: 1)),
      beratPerJenis: {'Plastik': 1.2, 'Kertas': 0.5},
      catatan: 'Sampah dari dapur dan ruang tamu',
      koinDapat: 29,
    ),
    LaporanHarian(
      id: 'l2',
      tanggal: DateTime.now().subtract(const Duration(days: 2)),
      beratPerJenis: {'Logam': 0.8},
      catatan: '',
      koinDapat: 32,
    ),
    LaporanHarian(
      id: 'l3',
      tanggal: DateTime.now().subtract(const Duration(days: 4)),
      beratPerJenis: {'Plastik': 0.6, 'Kaca': 1.0, 'Organik': 2.0},
      catatan: 'Hasil bersih-bersih rumah',
      koinDapat: 32,
    ),
  ];

  // Form state
  final Map<String, TextEditingController> _beratCtrl = {
    'Plastik': TextEditingController(),
    'Kertas': TextEditingController(),
    'Logam': TextEditingController(),
    'Kaca': TextEditingController(),
    'Elektronik': TextEditingController(),
    'Organik': TextEditingController(),
  };
  final TextEditingController _catatanCtrl = TextEditingController();

  final Map<String, Color> _warnaSampah = {
    'Plastik': kPrimary,
    'Kertas': kInfo,
    'Logam': kWarning,
    'Kaca': const Color(0xFF8B5CF6),
    'Elektronik': kDanger,
    'Organik': const Color(0xFF059669),
  };

  final Map<String, IconData> _ikonSampah = {
    'Plastik': Icons.water_drop_outlined,
    'Kertas': Icons.article_outlined,
    'Logam': Icons.hardware_outlined,
    'Kaca': Icons.wine_bar_outlined,
    'Elektronik': Icons.devices_outlined,
    'Organik': Icons.compost_outlined,
  };

  final Map<String, int> _koinPerKg = {
    'Plastik': 20,
    'Kertas': 15,
    'Logam': 40,
    'Kaca': 25,
    'Elektronik': 60,
    'Organik': 5,
  };

  bool _formExpanded = false;

  @override
  void dispose() {
    for (final c in _beratCtrl.values) { c.dispose(); }
    _catatanCtrl.dispose();
    super.dispose();
  }

  double _getBerat(String jenis) =>
      double.tryParse(_beratCtrl[jenis]!.text.replaceAll(',', '.')) ?? 0;

  int get _estimasiKoin => _beratCtrl.entries.fold(0, (sum, e) {
        final berat = _getBerat(e.key);
        return sum + (berat * (_koinPerKg[e.key] ?? 0)).toInt();
      });

  double get _totalBerat =>
      _beratCtrl.keys.fold(0, (sum, k) => sum + _getBerat(k));

  bool get _adaInput => _totalBerat > 0;

  void _simpanLaporan() {
    if (!_adaInput) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Masukkan minimal 1 jenis sampah'),
        backgroundColor: kDanger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    HapticFeedback.mediumImpact();

    final beratMap = <String, double>{};
    for (final k in _beratCtrl.keys) {
      final b = _getBerat(k);
      if (b > 0) beratMap[k] = b;
    }

    final laporan = LaporanHarian(
      id: 'l${DateTime.now().millisecondsSinceEpoch}',
      tanggal: DateTime.now(),
      beratPerJenis: beratMap,
      catatan: _catatanCtrl.text.trim(),
      koinDapat: _estimasiKoin,
    );

    setState(() {
      _riwayat.insert(0, laporan);
      for (final c in _beratCtrl.values) { c.clear(); }
      _catatanCtrl.clear();
      _formExpanded = false;
    });

    _showSukses(laporan);
  }

  void _showSukses(LaporanHarian laporan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: kPrimary, size: 48),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Laporan Tersimpan!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kText)),
            const SizedBox(height: 8),
            Text('Total ${laporan.totalBerat.toStringAsFixed(1)} kg sampah tercatat hari ini.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: kTextSoft, fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on_rounded, color: kPrimary, size: 20),
                  const SizedBox(width: 6),
                  Text('+${laporan.koinDapat} Koin didapat',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: kPrimary, fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Oke', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
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
            width: 36, height: 36,
            decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: kText),
          ),
        ),
        title: const Text('Laporan Sampah Harian',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kText)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats strip ──
            _buildStatsStrip(),
            const SizedBox(height: 20),

            // ── Form Input ──
            _buildFormCard(),
            const SizedBox(height: 24),

            // ── Riwayat ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Riwayat Laporan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
                Text('${_riwayat.length} laporan',
                    style: const TextStyle(fontSize: 12, color: kTextSoft)),
              ],
            ),
            const SizedBox(height: 12),
            if (_riwayat.isEmpty)
              _buildEmptyRiwayat()
            else
              ..._riwayat.map((l) => _buildRiwayatCard(l)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsStrip() {
    final totalBerat = _riwayat.fold(0.0, (s, l) => s + l.totalBerat);
    final totalKoin = _riwayat.fold(0, (s, l) => s + l.koinDapat);
    final streak = _riwayat.length;

    return Row(
      children: [
        Expanded(child: _statCard(Icons.scale_rounded, '${totalBerat.toStringAsFixed(1)} kg', 'Total Berat', kInfo)),
        const SizedBox(width: 10),
        Expanded(child: _statCard(Icons.monetization_on_rounded, '$totalKoin', 'Total Koin', kWarning)),
        const SizedBox(width: 10),
        Expanded(child: _statCard(Icons.local_fire_department_rounded, '$streak hari', 'Streak', kDanger)),
      ],
    );
  }

  Widget _statCard(IconData icon, String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: kTextSoft)),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          // Header toggle
          GestureDetector(
            onTap: () => setState(() => _formExpanded = !_formExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.add_rounded, color: kPrimary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Isi Laporan Hari Ini',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kText)),
                        Text('Catat sampah yang kamu kumpulkan',
                            style: TextStyle(fontSize: 11, color: kTextSoft)),
                      ],
                    ),
                  ),
                  Icon(_formExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: kTextSoft),
                ],
              ),
            ),
          ),

          if (_formExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Berat per Jenis Sampah (kg)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.4,
                    ),
                    itemCount: _beratCtrl.length,
                    itemBuilder: (_, i) {
                      final jenis = _beratCtrl.keys.elementAt(i);
                      final color = _warnaSampah[jenis]!;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(_ikonSampah[jenis]!, color: color, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: TextField(
                                controller: _beratCtrl[jenis],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => setState(() {}),
                                style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700),
                                decoration: InputDecoration(
                                  hintText: jenis,
                                  hintStyle: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.5)),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  suffix: Text('kg', style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.6))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  if (_adaInput) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.calculate_outlined, color: kPrimary, size: 16),
                          const SizedBox(width: 8),
                          Text('Total: ${_totalBerat.toStringAsFixed(1)} kg',
                              style: const TextStyle(fontSize: 12, color: kPrimary, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.monetization_on_rounded, color: kPrimary, size: 14),
                              const SizedBox(width: 4),
                              Text('+$_estimasiKoin koin',
                                  style: const TextStyle(fontSize: 12, color: kPrimary, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Text('Catatan (Opsional)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _catatanCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Tambahkan catatan...',
                        hintStyle: TextStyle(color: kTextSoft, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _adaInput ? _simpanLaporan : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        disabledBackgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: kTextSoft,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Simpan Laporan', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(LaporanHarian l) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.assignment_turned_in_outlined, color: kPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.tanggalFormatted,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kText)),
                    Text('Total ${l.totalBerat.toStringAsFixed(1)} kg • ${l.beratPerJenis.length} jenis',
                        style: const TextStyle(fontSize: 12, color: kTextSoft)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: kPrimary, size: 13),
                    const SizedBox(width: 3),
                    Text('+${l.koinDapat}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kPrimary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: l.beratPerJenis.entries.map((e) {
              final color = _warnaSampah[e.key] ?? kPrimary;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('${e.key} ${e.value}kg',
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
              );
            }).toList(),
          ),
          if (l.catatan.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(l.catatan,
                style: const TextStyle(fontSize: 12, color: kTextSoft, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyRiwayat() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          const Icon(Icons.assignment_outlined, color: kTextSoft, size: 48),
          const SizedBox(height: 12),
          const Text('Belum ada laporan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
          const SizedBox(height: 4),
          const Text('Mulai catat sampah harianmu di atas',
              style: TextStyle(fontSize: 12, color: kTextSoft)),
        ],
      ),
    );
  }
}
