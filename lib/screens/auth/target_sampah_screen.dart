import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════
//  TargetSampahScreen  –  Form penargetan sampah
//  Mockup: image 2 (form target) & image 2.1 (panduan estimasi)
// ══════════════════════════════════════════════════════
class TargetSampahScreen extends StatefulWidget {
  const TargetSampahScreen({super.key});

  @override
  State<TargetSampahScreen> createState() => _TargetSampahScreenState();
}

class _TargetSampahScreenState extends State<TargetSampahScreen> {
  bool _panduanOpen = false;

  // ── Daftar Harga statis (harga bank sampah per 1 kg) ─
  // [2] Data ini adalah referensi harga tetap, tidak mengikuti input jumlah
  static const List<Map<String, dynamic>> _daftarHarga = [
    {'nama': 'Plastik', 'icon': '♻️',  'harga': 4000,  'koin': 4000},
    {'nama': 'Karton',  'icon': '📦',  'harga': 3000,  'koin': 3000},
    {'nama': 'Kaca',    'icon': '🍶',  'harga': 1000,  'koin': 1000},
    {'nama': 'Kertas',  'icon': '📄',  'harga': 3000,  'koin': 3000},
    {'nama': 'Kaleng',  'icon': '🥫',  'harga': 10000, 'koin': 10000},
  ];

  // [5] Harga & koin per kg sesuai ketentuan
  final List<Map<String, dynamic>> _sampahList = [
    {'nama': 'Plastik', 'icon': '♻️',  'harga': 4000,  'koin': 4000,  'jumlah': 0},
    {'nama': 'Karton',  'icon': '📦',  'harga': 3000,  'koin': 3000,  'jumlah': 0},
    {'nama': 'Kaca',    'icon': '🍶',  'harga': 1000,  'koin': 1000,  'jumlah': 0},
    {'nama': 'Kertas',  'icon': '📄',  'harga': 3000,  'koin': 3000,  'jumlah': 0},
    {'nama': 'Kaleng',  'icon': '🥫',  'harga': 10000, 'koin': 10000, 'jumlah': 0},
  ];

  // ── Computed ─────────────────────────────────────────
  double get _totalKg =>
      _sampahList.fold(0, (s, e) => s + (e['jumlah'] as int));

  int get _totalKoin => _sampahList.fold(
      0, (s, e) => s + ((e['jumlah'] as int) * (e['koin'] as int)));

  double get _totalSaldo => _sampahList.fold(
      0,
      (s, e) => s + ((e['jumlah'] as int) * (e['harga'] as int)).toDouble());

  String _rupiah(num n) {
    final s = n.toInt().toString();
    return 'Rp ${s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  void _ubahJumlah(int index, int delta) {
    setState(() {
      final nv = (_sampahList[index]['jumlah'] as int) + delta;
      if (nv >= 0) _sampahList[index]['jumlah'] = nv;
    });
  }

  void _buatPenargetan() {
    if (_totalKg == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Masukan minimal 1 kg untuk membuat target'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  // ── Build ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildPanduanDropdown(),
                    const SizedBox(height: 16),
                    _buildSectionLabel('Daftar harga sampah perkilogram'),
                    _buildDaftarHargaCard(),
                    const SizedBox(height: 16),
                    _buildSectionLabel('Masukan jumlah kilogram sampah yang\ningin di targetkan'),
                    _buildCounterCard(),
                    const SizedBox(height: 16),
                    _buildRingkasanCard(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────
  Widget _buildAppBar() {
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
                  fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  // ── Panduan dropdown ─────────────────────────────────
  Widget _buildPanduanDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _panduanOpen = !_panduanOpen),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFF374151), size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Panduan Estimasi Berat Sampah',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
                    ),
                  ),
                  Icon(
                    _panduanOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),
          if (_panduanOpen)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _buildPanduanContent(),
            ),
        ],
      ),
    );
  }

  Widget _buildPanduanContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _panduanSection('♻️ Plastik', [
          'Botol Plastik:',
          '  • 200-330ml: ±6-10 gram (botol kecil/sekali saji)',
          '  • 500-600ml: ±12-20 gram (air mineral standar)',
          '  • 1 Liter: ±20-40 gram',
          '  • 1.5-2 Liter: ±30-45 gram (ukuran keluarga)',
          'Kantong Plastik:',
          '  • Kresek kecil: ±3-5 gram',
          '  • Kresek sedang: ±8-12 gram',
          '  • Kresek besar: ±15-25 gram',
          'Kemasan Plastik:',
          '  • Gelas plastik: ±3-8 gram',
          '  • Kemasan snack: ±2-5 gram',
          '  • Sedotan: ±0.5-1 gram',
        ], '💡 Referensi: 50-100 botol plastik 600ml ≈ 1 kg'),
        _panduanSection('📦 Karton', [
          'Kardus/Karton:',
          '  • Kardus mi instan: ±20-30 gram',
          '  • Kardus kecil (15×15 cm): ±50-100 gram',
          '  • Kardus sedang (30×30 cm): ±200-400 gram',
          '  • Kardus besar (50×50 cm): ±500-800 gram',
          'Dus Tebal:',
          '  • Dus sepatu: ±150-250 gram',
          '  • Dus TV/elektronik: ±1-3 kg',
        ], '💡 Referensi: 3-5 kardus mi instan ≈ 0.1 kg'),
        _panduanSection('🍶 Kaca', [
          'Botol Kaca:',
          '  • Botol sirup kecil (250 ml): ±150-200 gram',
          '  • Botol kecap (300-350ml): ±200-300 gram',
          '  • Botol bir (330ml): ±200-250 gram',
          '  • Botol wine (750ml): ±400-600 gram',
          '  • Botol besar (1 L): ±500-800 gram',
          'Kaca Lainnya:',
          '  • Gelas kaca kecil: ±100-150 gram',
          '  • Toples kaca sedang: ±300-500 gram',
          '  • Jar selai: ±150-250 gram',
        ], '💡 Referensi: 4-6 botol kecap ≈ 1 kg'),
        _panduanSection('📄 Kertas', [
          'Kertas HVS/Putih:',
          '  • 1 lembar kertas A4: ±5 gram',
          '  • 1 rim (500 lembar): ±2.5 kg',
          'Koran/Majalah:',
          '  • 1 koran harian: ±150-250 gram',
          '  • 1 majalah: ±200-400 gram',
          'Buku:',
          '  • Buku tipis (100 hal): ±150-200 gram',
          '  • Buku sedang (300 hal): ±400-600 gram',
          '  • Buku tebal (500 hal): ±700-1000 gram',
        ], '💡 Referensi: 200 lembar A4 ≈ 1 kg'),
        _panduanSection('🥫 Kaleng', [
          'Kaleng Minuman:',
          '  • Kaleng soda/bir (330 ml): ±15-20 gram',
          '  • Kaleng minuman energi: ±15-18 gram',
          'Kaleng Makanan:',
          '  • Kaleng kornet kecil: ±40-60 gram',
          '  • Kaleng sarden: ±50-80 gram',
          '  • Kaleng susu kental manis: ±60-90 gram',
          '  • Kaleng buah/sayur: ±80-150 gram',
        ], '💡 Referensi: 50-60 kaleng minuman 330ml ≈ 1 kg'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            border: Border.all(color: const Color(0xFFFDE68A)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '⚠️ Catatan: Angka di atas adalah estimasi. Berat aktual dapat bervariasi tergantung merek, ketebalan material, dan kondisi sampah. Gunakan sebagai panduan untuk menentukan target Anda.',
            style: TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _panduanSection(String title, List<String> lines, String referensi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 4),
          ...lines.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(l,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.4)),
            ),
          ),
          const SizedBox(height: 4),
          Text(referensi,
              style: const TextStyle(fontSize: 11, color: Color(0xFFD97706), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Text(text,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
    );
  }

  // ── [2] Daftar Harga Card – selalu tampilkan 1 kg (statis) ─
  Widget _buildDaftarHargaCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: _daftarHarga.map((s) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF0F5C2A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(s['icon'] as String,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s['nama'] as String,
                      style: const TextStyle(color: Colors.white,
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('1 kg',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text('${s['koin']} koin',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(_rupiah((s['harga'] as num).toInt()),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Counter Card ─────────────────────────────────────
  Widget _buildCounterCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: List.generate(_sampahList.length, (i) {
          final s = _sampahList[i];
          return Container(
            margin: EdgeInsets.only(bottom: i < _sampahList.length - 1 ? 8.0 : 0.0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F5C2A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(s['icon'] as String, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s['nama'] as String,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                _CounterButton(
                  icon: Icons.remove,
                  onTap: () => _ubahJumlah(i, -1),
                ),
                Container(
                  width: 40,
                  height: 32,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${s['jumlah']}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                ),
                _CounterButton(
                  icon: Icons.add,
                  onTap: () => _ubahJumlah(i, 1),
                ),
                const SizedBox(width: 8),
                const Text('Kg', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Ringkasan Card ───────────────────────────────────
  Widget _buildRingkasanCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Target bulan ini :',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          const SizedBox(height: 4),
          Text(
            '${_totalKg.toStringAsFixed(0)}kg',
            style: const TextStyle(
                color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimasi koin yang di dapatkan : ${_totalKg > 0 ? _totalKoin : '-'}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Estimasi saldo yang di dapatkan : ${_totalKg > 0 ? _rupiah(_totalSaldo) : '-'}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bottom Button ────────────────────────────────────
  Widget _buildBottomButton() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _buatPenargetan,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF22C55E),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text(
            'Buat penargetan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  _CounterButton  –  Tombol + / - di form penargetan
// ══════════════════════════════════════════════════════
class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}