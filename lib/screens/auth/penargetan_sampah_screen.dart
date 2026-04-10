import 'package:flutter/material.dart';

const Color kPrimary = Color(0xFF26D077);
const Color kCardDark = Color(0xFF1E9E5E);

class PenargentanSampahScreen extends StatefulWidget {
  const PenargentanSampahScreen({super.key});

  @override
  State<PenargentanSampahScreen> createState() =>
      _PenargentanSampahScreenState();
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
      0,
      (sum, s) =>
          sum + ((s['jumlah'] as int) * (s['koinPerKg'] as int)));

  double get _totalSaldo => _sampahList.fold(
      0,
      (sum, s) =>
          sum +
          ((s['jumlah'] as int) * (s['hargaPerKg'] as int)).toDouble());

  void _ubahJumlah(int index, int delta) {
    setState(() {
      final newVal = (_sampahList[index]['jumlah'] as int) + delta;
      // ✅ Minimal 0, tidak bisa minus
      if (newVal >= 0) _sampahList[index]['jumlah'] = newVal;
    });
  }

  void _buatPenargetan() {
    if (_totalKg == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukan minimal 1 kg untuk membuat target'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.pop(context, {
      'totalKg': _totalKg,
      'totalKoin': _totalKoin,
      'totalSaldo': _totalSaldo,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.grey.shade300, width: 1.5),
                      ),
                      child: const Icon(Icons.chevron_left,
                          size: 24, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Targetkan Sampah',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87)),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    // ── Daftar Harga ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Daftar harga sampah perkilogram',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          ..._sampahList.map((s) => _buildHargaItem(s)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Input Jumlah ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Masukan jumlah kilogram sampah yang ingin di targetkan',
                            style: TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 14),
                          ..._sampahList
                              .asMap()
                              .entries
                              .map(
                                (entry) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 10),
                                  child: _buildCounterItem(
                                      entry.key, entry.value),
                                ),
                              ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Ringkasan Target ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Target bulan ini :',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14)),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              '${_totalKg.toStringAsFixed(0)}kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Estimasi koin yang di dapatkan : ${_totalKg == 0 ? '-' : '$_totalKoin'}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Estimasi saldo yang di dapatkan : ${_totalKg == 0 ? '-' : 'Rp ${_totalSaldo.toStringAsFixed(0)}'}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Tombol Buat Penargetan ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _buatPenargetan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Buat penargetan',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHargaItem(Map<String, dynamic> s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kCardDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s['nama'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const Text('1 kg',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const Divider(color: Colors.white24, height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${s['koinPerKg']} koin',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13)),
              Text('Rp.${s['hargaPerKg']}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13)),
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
        color: kCardDark,
        borderRadius: BorderRadius.circular(12),
      ),
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
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.remove, color: Colors.white, size: 18),
            ),
          ),
          Container(
            width: 40,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${s['jumlah']}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _ubahJumlah(index, 1),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Kg',
              style: TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}