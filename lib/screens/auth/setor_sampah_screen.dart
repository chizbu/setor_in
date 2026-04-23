import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────
class JenisSampah {
  final String id;
  final String nama;
  final String deskripsi;
  final IconData icon;
  final Color color;
  final int koinPerKg;
  final int hargaPerKg;

  const JenisSampah({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.icon,
    required this.color,
    required this.koinPerKg,
    required this.hargaPerKg,
  });
}

const List<JenisSampah> kDaftarJenis = [
  JenisSampah(
    id: 'plastik',
    nama: 'Plastik',
    deskripsi: 'Botol, kantong, ember, dll.',
    icon: Icons.water_drop_outlined,
    color: Color(0xFF26D077),
    koinPerKg: 20,
    hargaPerKg: 2000,
  ),
  JenisSampah(
    id: 'kertas',
    nama: 'Kertas',
    deskripsi: 'Koran, kardus, buku, dll.',
    icon: Icons.article_outlined,
    color: Color(0xFF3B82F6),
    koinPerKg: 15,
    hargaPerKg: 1500,
  ),
  JenisSampah(
    id: 'logam',
    nama: 'Logam',
    deskripsi: 'Kaleng, besi, aluminium, dll.',
    icon: Icons.hardware_outlined,
    color: Color(0xFFF59E0B),
    koinPerKg: 40,
    hargaPerKg: 4000,
  ),
  JenisSampah(
    id: 'kaca',
    nama: 'Kaca',
    deskripsi: 'Botol kaca, pecahan kaca, dll.',
    icon: Icons.wine_bar_outlined,
    color: Color(0xFF8B5CF6),
    koinPerKg: 25,
    hargaPerKg: 2500,
  ),
  JenisSampah(
    id: 'elektronik',
    nama: 'Elektronik',
    deskripsi: 'HP, laptop, kabel, dll.',
    icon: Icons.devices_outlined,
    color: Color(0xFFEF4444),
    koinPerKg: 60,
    hargaPerKg: 6000,
  ),
  JenisSampah(
    id: 'organik',
    nama: 'Organik',
    deskripsi: 'Sisa makanan, daun, dll.',
    icon: Icons.compost_outlined,
    color: Color(0xFF059669),
    koinPerKg: 5,
    hargaPerKg: 500,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class SetorSampahScreen extends StatefulWidget {
  const SetorSampahScreen({super.key});

  @override
  State<SetorSampahScreen> createState() => _SetorSampahScreenState();
}

class _SetorSampahScreenState extends State<SetorSampahScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  JenisSampah? _selectedJenis;
  final TextEditingController _beratCtrl = TextEditingController();
  final TextEditingController _catatanCtrl = TextEditingController();

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _slideAnim = Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _beratCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  double get _berat => double.tryParse(_beratCtrl.text.replaceAll(',', '.')) ?? 0;
  int get _estimasiKoin => _selectedJenis == null ? 0 : (_berat * _selectedJenis!.koinPerKg).toInt();
  int get _estimasiRupiah => _selectedJenis == null ? 0 : (_berat * _selectedJenis!.hargaPerKg).toInt();

  void _animate() {
    _slideCtrl.reset();
    _slideCtrl.forward();
  }

  void _next() {
    if (_step == 0 && _selectedJenis == null) {
      _snack('Pilih jenis sampah terlebih dahulu');
      return;
    }
    if (_step == 1 && _berat <= 0) {
      _snack('Masukkan berat yang valid');
      return;
    }
    _animate();
    setState(() => _step++);
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }
    _animate();
    setState(() => _step--);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: kDanger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    const steps = ['Pilih Jenis', 'Detail', 'Konfirmasi'];
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _back,
          icon: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: kText),
          ),
        ),
        title: const Text('Setor Sampah',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kText)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: List.generate(3, (i) {
                final active = i == _step;
                final done = i < _step;
                return Expanded(
                  child: Row(children: [
                    Expanded(
                      child: Column(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 4,
                          decoration: BoxDecoration(
                            color: (done || active) ? kPrimary : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(steps[i],
                            style: TextStyle(
                              fontSize: 10,
                              color: active ? kPrimary : done ? kPrimary.withValues(alpha: 0.5) : kTextSoft,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                            )),
                      ]),
                    ),
                    if (i < 2) const SizedBox(width: 6),
                  ]),
                );
              }),
            ),
          ),
        ),
      ),
      body: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              const SizedBox(height: 8),
              if (_step == 0) _buildStep0(),
              if (_step == 1) _buildStep1(),
              if (_step == 2) _buildStep2(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
        child: ElevatedButton(
          onPressed: _step < 2 ? _next : _showSuccess,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 0,
          ),
          child: Text(
            _step == 0 ? 'Lanjut — Isi Detail' : _step == 1 ? 'Lanjut — Konfirmasi' : 'Kirim Permintaan',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }

  // ── STEP 0 ─────────────────────────────────────────────────────────────────
  Widget _buildStep0() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mau setor sampah apa?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kText)),
          SizedBox(height: 4),
          Text('Pilih jenis sampah yang akan kamu setorkan',
              style: TextStyle(fontSize: 13, color: kTextSoft)),
        ]),
      ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.65,
        ),
        itemCount: kDaftarJenis.length,
        itemBuilder: (_, i) {
          final j = kDaftarJenis[i];
          final sel = _selectedJenis?.id == j.id;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedJenis = j);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: sel ? j.color.withValues(alpha: 0.09) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: sel ? j.color : Colors.grey.shade200, width: sel ? 2 : 1),
                boxShadow: sel ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: j.color.withValues(alpha: sel ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(j.icon, color: j.color, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(j.nama, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: sel ? j.color : kText)),
                    Text('${j.koinPerKg} koin/kg', style: TextStyle(fontSize: 11, color: sel ? j.color.withValues(alpha: 0.7) : kTextSoft)),
                  ],
                )),
                if (sel) Icon(Icons.check_circle_rounded, color: j.color, size: 18),
              ]),
            ),
          );
        },
      ),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kInfo.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kInfo.withValues(alpha: 0.18)),
          ),
          child: const Row(children: [
            Icon(Icons.info_outline_rounded, color: kInfo, size: 18),
            SizedBox(width: 10),
            Expanded(child: Text(
              'Tarif dihitung berdasarkan berat aktual yang diverifikasi petugas.',
              style: TextStyle(fontSize: 12, color: kInfo, height: 1.4),
            )),
          ]),
        ),
      ),
    ]);
  }

  // ── STEP 1 ─────────────────────────────────────────────────────────────────
  Widget _buildStep1() {
    final j = _selectedJenis!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Chip jenis terpilih
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(color: j.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(j.icon, color: j.color, size: 16),
              const SizedBox(width: 6),
              Text(j.nama, style: TextStyle(color: j.color, fontWeight: FontWeight.w700, fontSize: 13)),
            ]),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () { _animate(); setState(() => _step = 0); },
            child: const Text('Ganti', style: TextStyle(fontSize: 12, color: kPrimary, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 24),

        const Text('Perkiraan Berat', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
        const SizedBox(height: 10),
        Container(
          decoration: AppTheme.cardDecoration,
          child: Row(children: [
            const SizedBox(width: 16),
            Icon(Icons.scale_rounded, color: j.color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _beratCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kText),
                decoration: const InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(fontSize: 22, color: kTextSoft, fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
              child: const Text('kg', style: TextStyle(color: kTextSoft, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        Text(j.deskripsi, style: const TextStyle(fontSize: 12, color: kTextSoft)),
        const SizedBox(height: 20),

        // Estimasi
        AnimatedOpacity(
          opacity: _berat > 0 ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: j.color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: j.color.withValues(alpha: 0.2)),
            ),
            child: Column(children: [
              Row(children: [
                Icon(Icons.calculate_outlined, color: j.color, size: 15),
                const SizedBox(width: 6),
                Text('Estimasi untuk ${_berat > 0 ? _berat : '-'} kg',
                    style: TextStyle(fontSize: 12, color: j.color, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _estCard(Icons.monetization_on_rounded, '$_estimasiKoin koin', 'Koin didapat', kPrimary)),
                const SizedBox(width: 10),
                Expanded(child: _estCard(Icons.account_balance_wallet_outlined, 'Rp ${_fmt(_estimasiRupiah)}', 'Saldo didapat', kInfo)),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 22),

        // ── Info Metode: hanya Antar Sendiri ──
        const Text('Metode Pengumpulan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPrimary, width: 2),
          ),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.directions_walk_rounded, color: kPrimary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Antar Sendiri',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kPrimary)),
                SizedBox(height: 2),
                Text('Bawa sampah langsung ke bank sampah terdekat',
                    style: TextStyle(fontSize: 11, color: kTextSoft)),
              ]),
            ),
            const Icon(Icons.check_circle_rounded, color: kPrimary, size: 20),
          ]),
        ),
        const SizedBox(height: 22),

        const Text('Catatan (Opsional)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
        const SizedBox(height: 10),
        Container(
          decoration: AppTheme.cardDecoration,
          child: TextField(
            controller: _catatanCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Tambahkan catatan untuk petugas...',
              hintStyle: TextStyle(color: kTextSoft, fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _estCard(IconData icon, String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: kTextSoft)),
        ]),
      ]),
    );
  }

  // ── STEP 2 ─────────────────────────────────────────────────────────────────
  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Periksa Kembali',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kText)),
        const SizedBox(height: 4),
        const Text('Pastikan data sudah benar', style: TextStyle(fontSize: 13, color: kTextSoft)),
        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          decoration: AppTheme.cardDecoration,
          child: Column(children: [
            _konfRow('Jenis Sampah', _selectedJenis!.nama, icon: _selectedJenis!.icon, iColor: _selectedJenis!.color),
            _div(),
            _konfRow('Berat', '${_berat} kg'),
            _div(),
            _konfRow('Metode', 'Antar Sendiri'),
            if (_catatanCtrl.text.isNotEmpty) ...[_div(), _konfRow('Catatan', _catatanCtrl.text)],
          ]),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.greenCardDecoration,
          child: Column(children: [
            const Text('Estimasi yang Kamu Dapat',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _hasilItem(Icons.monetization_on_rounded, '$_estimasiKoin', 'Koin'),
              Container(width: 1, height: 40, color: Colors.white24),
              _hasilItem(Icons.account_balance_wallet_outlined, 'Rp ${_fmt(_estimasiRupiah)}', 'Saldo'),
              Container(width: 1, height: 40, color: Colors.white24),
              _hasilItem(Icons.scale_rounded, '${_berat} kg', 'Berat'),
            ]),
          ]),
        ),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kWarning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kWarning.withValues(alpha: 0.25)),
          ),
          child: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: kWarning, size: 18),
            SizedBox(width: 10),
            Expanded(child: Text(
              'Koin dan saldo final dihitung setelah petugas memverifikasi sampah.',
              style: TextStyle(fontSize: 12, color: kWarning, height: 1.4),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _konfRow(String label, String val, {IconData? icon, Color? iColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 13, color: kTextSoft)),
        const Spacer(),
        if (icon != null) ...[Icon(icon, size: 15, color: iColor), const SizedBox(width: 4)],
        Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
      ]),
    );
  }

  Widget _div() => const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0));

  Widget _hasilItem(IconData icon, String val, String label) {
    return Column(children: [
      Icon(icon, color: Colors.white70, size: 18),
      const SizedBox(height: 4),
      Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
    ]);
  }

  // ── SUCCESS SHEET ──────────────────────────────────────────────────────────
  void _showSuccess() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
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
            const SizedBox(height: 18),
            const Text('Permintaan Dikirim!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kText)),
            const SizedBox(height: 8),
            const Text(
              'Bawa sampah ke bank sampah terdekat dan tunjukkan kode berikut ke petugas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextSoft, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: kPrimaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kPrimary.withValues(alpha: 0.3)),
              ),
              child: Column(children: [
                const Text('Kode Setor', style: TextStyle(fontSize: 12, color: kTextSoft)),
                const SizedBox(height: 4),
                const Text('STR-20250412-8821',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kPrimary, letterSpacing: 2)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _badge(Icons.monetization_on_rounded, '$_estimasiKoin koin', kPrimary),
                  const SizedBox(width: 10),
                  _badge(Icons.payments_outlined, 'Rp ${_fmt(_estimasiRupiah)}', kInfo),
                ]),
              ]),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kPrimary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Beranda', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _animate();
                    setState(() { _step = 0; _selectedJenis = null; _beratCtrl.clear(); _catatanCtrl.clear(); });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Setor Lagi', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}