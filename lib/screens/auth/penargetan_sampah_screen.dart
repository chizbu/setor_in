import 'package:flutter/material.dart';
import 'app_theme.dart';

const Color kCardDark = Color(0xFF0A7A3A);

class PenargentanSampahScreen extends StatefulWidget {
  const PenargentanSampahScreen({super.key});

  @override
  State<PenargentanSampahScreen> createState() => _PenargentanSampahScreenState();
}

class _PenargentanSampahScreenState extends State<PenargentanSampahScreen> {
  final List<Map<String, dynamic>> _sampahList = [
    {'nama': 'Plastik', 'hargaPerKg': 2000, 'koinPerKg': 20, 'jumlah': 0},
    {'nama': 'Kertas', 'hargaPerKg': 1500, 'koinPerKg': 15, 'jumlah': 0},
    {'nama': 'Kaca', 'hargaPerKg': 1000, 'koinPerKg': 10, 'jumlah': 0},
    {'nama': 'Logam', 'hargaPerKg': 3000, 'koinPerKg': 30, 'jumlah': 0},
  ];

  double get _totalKg =>
      _sampahList.fold(0, (sum, s) => sum + (s['jumlah'] as int));

  int get _totalKoin => _sampahList.fold(
      0, (sum, s) => sum + ((s['jumlah'] as int) * (s['koinPerKg'] as int)));

  double get _totalSaldo => _sampahList.fold(
      0,
      (sum, s) =>
          sum + ((s['jumlah'] as int) * (s['hargaPerKg'] as int)).toDouble());

  void _ubahJumlah(int index, int delta) {
    setState(() {
      final newVal = (_sampahList[index]['jumlah'] as int) + delta;
      if (newVal >= 0) _sampahList[index]['jumlah'] = newVal;
    });
  }

  void _buatPenargetan() {
    if (_totalKg == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Masukan minimal 1 kg untuk membuat target'),
        backgroundColor: kDanger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    Navigator.pop(context, {
      'totalKg': _totalKg,
      'totalKoin': _totalKoin,
      'totalSaldo': _totalSaldo,
    });
  }

  String _fmt(int n) => n.toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: kBg, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: kText),
          ),
        ),
        title: const Text('Penargetan Sampah',
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 16, color: kText)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Daftar Harga ──
            const Text('Daftar Harga Sampah',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: kGradientPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Harga per kilogram sampah',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  ..._sampahList.map((s) => _buildHargaItem(s)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Input Jumlah ──
            const Text('Target Sampah per Jenis',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
            const SizedBox(height: 4),
            const Text('Masukkan jumlah kilogram yang ingin ditargetkan',
                style: TextStyle(fontSize: 12, color: kTextSoft)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: kGradientPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: _sampahList.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildCounterItem(entry.key, entry.value),
                    )).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ── Ringkasan Target ──
            const Text('Ringkasan Target',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  // Total kg
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                            color: kPrimaryLight,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.scale_rounded,
                            color: kPrimary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_totalKg.toStringAsFixed(0)} kg',
                            style: const TextStyle(
                                color: kPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.w800),
                          ),
                          const Text('Target bulan ini',
                              style: TextStyle(
                                  color: kTextSoft, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryItem(
                          Icons.monetization_on_rounded,
                          _totalKg == 0 ? '-' : '$_totalKoin koin',
                          'Estimasi Koin',
                          kWarning,
                        ),
                      ),
                      Container(
                          width: 1, height: 44, color: const Color(0xFFF0F0F0)),
                      Expanded(
                        child: _summaryItem(
                          Icons.account_balance_wallet_outlined,
                          _totalKg == 0
                              ? '-'
                              : 'Rp ${_fmt(_totalSaldo.toInt())}',
                          'Estimasi Saldo',
                          kInfo,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kInfo.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kInfo.withValues(alpha: 0.18)),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded, color: kInfo, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Estimasi dihitung berdasarkan harga saat ini. Nilai final ditentukan saat setor.',
                    style:
                        TextStyle(fontSize: 12, color: kInfo, height: 1.4),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
        child: ElevatedButton(
          onPressed: _totalKg > 0 ? _buatPenargetan : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            disabledBackgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.white,
            disabledForegroundColor: kTextSoft,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 0,
          ),
          child: Text(
            _totalKg > 0
                ? 'Buat Target ${_totalKg.toStringAsFixed(0)} kg'
                : 'Masukkan Target Dulu',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildHargaItem(Map<String, dynamic> s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: kCardDark, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Text(s['nama'],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${s['koinPerKg']} koin/kg',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('Rp ${_fmt(s['hargaPerKg'])}/kg',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterItem(int index, Map<String, dynamic> s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: kCardDark, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Text(s['nama'],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
          GestureDetector(
            onTap: () => _ubahJumlah(index, -1),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.remove, color: Colors.white, size: 18),
            ),
          ),
          Container(
            width: 44,
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text('${s['jumlah']}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
            ),
          ),
          GestureDetector(
            onTap: () => _ubahJumlah(index, 1),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          const Text('kg', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _summaryItem(
      IconData icon, String val, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(val,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: kTextSoft)),
      ],
    );
  }
}