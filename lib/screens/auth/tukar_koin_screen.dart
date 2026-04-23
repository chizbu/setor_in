import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────
class PaketTukar {
  final String id;
  final int koin;
  final int rupiah;
  final String label;
  final bool isPopular;

  const PaketTukar({
    required this.id,
    required this.koin,
    required this.rupiah,
    required this.label,
    this.isPopular = false,
  });

  String get rupPerKoin {
    final r = (rupiah / koin).toStringAsFixed(0);
    return r;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────────────────────
const List<PaketTukar> kPaket = [
  PaketTukar(id: 'p1', koin: 50, rupiah: 4500, label: 'Starter'),
  PaketTukar(id: 'p2', koin: 100, rupiah: 9500, label: 'Reguler', isPopular: true),
  PaketTukar(id: 'p3', koin: 200, rupiah: 20000, label: 'Hemat'),
  PaketTukar(id: 'p4', koin: 500, rupiah: 52500, label: 'Besar'),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class TukarKoinScreen extends StatefulWidget {
  final int koinAwal;
  final double saldoAwal;
  const TukarKoinScreen({
    super.key,
    this.koinAwal = 120,
    this.saldoAwal = 35000,
  });

  @override
  State<TukarKoinScreen> createState() => _TukarKoinScreenState();
}

class _TukarKoinScreenState extends State<TukarKoinScreen>
    with SingleTickerProviderStateMixin {
  late int _koin;
  late double _saldo;
  PaketTukar? _selectedPaket;
  int _customKoin = 0;
  bool _useCustom = false;
  final TextEditingController _customCtrl = TextEditingController();
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  // Rate: 1 koin = 95 rupiah (custom mode)
  static const int kRatePerKoin = 95;

  @override
  void initState() {
    super.initState();
    _koin = widget.koinAwal;
    _saldo = widget.saldoAwal;
    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _bounceAnim = CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut);
    _bounceCtrl.forward();
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _customCtrl.dispose();
    super.dispose();
  }

  int get _koinYangDipakai {
    if (_useCustom) return _customKoin;
    return _selectedPaket?.koin ?? 0;
  }

  int get _rupiahDidapat {
    if (_useCustom) return _customKoin * kRatePerKoin;
    return _selectedPaket?.rupiah ?? 0;
  }

  bool get _canExchange =>
      _koinYangDipakai > 0 && _koinYangDipakai <= _koin;

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  void _selectPaket(PaketTukar p) {
    if (p.koin > _koin) {
      _snack('Koin tidak cukup untuk paket ini');
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _selectedPaket = p;
      _useCustom = false;
      _customCtrl.clear();
      _customKoin = 0;
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: kDanger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _konfirmasi() {
    if (!_canExchange) {
      _snack('Pilih paket atau masukkan jumlah koin yang valid');
      return;
    }
    HapticFeedback.mediumImpact();
    _showKonfirmasiSheet();
  }

  void _showKonfirmasiSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Konfirmasi Penukaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
          const SizedBox(height: 20),

          // Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1BAF60), Color(0xFF26D077)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _summaryItem(Icons.monetization_on_rounded, '-$_koinYangDipakai koin', 'Koin Berkurang', true),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white54, size: 28),
              _summaryItem(Icons.account_balance_wallet_outlined, '+Rp ${_fmt(_rupiahDidapat)}', 'Saldo Bertambah', false),
            ]),
          ),
          const SizedBox(height: 20),

          // Detail rows
          _konfRow('Koin Saat Ini', '$_koin koin'),
          _konfRow('Koin Dipakai', '$_koinYangDipakai koin'),
          _konfRow('Koin Sisa', '${_koin - _koinYangDipakai} koin'),
          _konfRow('Saldo Sebelum', 'Rp ${_fmt(_saldo.toInt())}'),
          _konfRow('Saldo Setelah', 'Rp ${_fmt((_saldo + _rupiahDidapat).toInt())}', isHighlight: true),
          const SizedBox(height: 20),

          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Batal', style: TextStyle(color: kTextSoft, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _lakukan();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Ya, Tukarkan!', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _summaryItem(IconData icon, String val, String label, bool isKoin) {
    return Column(children: [
      Icon(icon, color: Colors.white, size: 24),
      const SizedBox(height: 6),
      Text(val, style: TextStyle(
          color: isKoin ? Colors.red.shade200 : Colors.white,
          fontWeight: FontWeight.w800, fontSize: 16)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ]);
  }

  Widget _konfRow(String label, String val, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 13, color: kTextSoft)),
        const Spacer(),
        Text(val, style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight ? kPrimary : kText)),
      ]),
    );
  }

  void _lakukan() {
    setState(() {
      _koin -= _koinYangDipakai;
      _saldo += _rupiahDidapat;
      _selectedPaket = null;
      _useCustom = false;
      _customCtrl.clear();
      _customKoin = 0;
    });
    _bounceCtrl.reset();
    _bounceCtrl.forward();
    _showSuccessSheet();
  }

  void _showSuccessSheet() {
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
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: kPrimary, size: 48),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Penukaran Berhasil!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kText)),
            const SizedBox(height: 8),
            const Text('Saldo kamu telah diperbarui.', style: TextStyle(color: kTextSoft, fontSize: 13)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kPrimary.withValues(alpha: 0.25))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _resultItem('Koin Sisa', '$_koin koin', kWarning, Icons.monetization_on_rounded),
                Container(width: 1, height: 44, color: kPrimary.withValues(alpha: 0.2)),
                _resultItem('Saldo Baru', 'Rp ${_fmt(_saldo.toInt())}', kPrimary, Icons.account_balance_wallet_outlined),
              ]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _resultItem(String label, String val, Color color, IconData icon) {
    return Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: kTextSoft)),
      const SizedBox(height: 2),
      Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
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
        title: const Text('Tukar Koin', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kText)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Balance Card ──
          ScaleTransition(
            scale: _bounceAnim,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1BAF60), Color(0xFF26D077)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: kPrimary.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(children: [
                const Text('Aset Kamu', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _assetItem(Icons.monetization_on_rounded, '$_koin', 'Koin', koinColor: true),
                  Container(width: 1, height: 48, color: Colors.white24),
                  _assetItem(Icons.account_balance_wallet_outlined, 'Rp ${_fmt(_saldo.toInt())}', 'Saldo'),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 28),

          // ── Kurs info ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kWarning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kWarning.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: kWarning.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Icon(Icons.currency_exchange_rounded, color: kWarning, size: 18),
              ),
              const SizedBox(width: 10),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Kurs Penukaran', style: TextStyle(fontSize: 12, color: kTextSoft)),
                Text('1 Koin = Rp 95 – Rp 105', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kText)),
              ]),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Pilih Paket ──
          const Text('Pilih Paket Penukaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 4),
          const Text('Paket memberikan nilai lebih baik dari penukaran manual',
              style: TextStyle(fontSize: 12, color: kTextSoft)),
          const SizedBox(height: 14),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: kPaket.length,
            itemBuilder: (_, i) => _buildPaketCard(kPaket[i]),
          ),
          const SizedBox(height: 24),

          // ── Custom jumlah ──
          Row(children: [
            const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('atau masukkan sendiri',
                  style: TextStyle(fontSize: 12, color: kTextSoft.withValues(alpha: 0.7))),
            ),
            const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
          ]),
          const SizedBox(height: 18),

          Container(
            decoration: AppTheme.cardDecoration,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(children: [
                  Checkbox(
                    value: _useCustom,
                    onChanged: (v) => setState(() {
                      _useCustom = v!;
                      if (_useCustom) _selectedPaket = null;
                    }),
                    activeColor: kPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  const Text('Jumlah Kustom', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
                ]),
              ),
              if (_useCustom) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    const Icon(Icons.monetization_on_rounded, color: kPrimary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _customCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (v) => setState(() => _customKoin = int.tryParse(v) ?? 0),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kText),
                        decoration: const InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(fontSize: 20, color: kTextSoft, fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const Text('koin', style: TextStyle(fontSize: 14, color: kTextSoft, fontWeight: FontWeight.w600)),
                  ]),
                ),
                if (_customKoin > 0 && _customKoin <= _koin)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Icons.account_balance_wallet_outlined, color: kPrimary, size: 16),
                        const SizedBox(width: 8),
                        Text('Dapat: Rp ${_fmt(_customKoin * kRatePerKoin)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kPrimary)),
                      ]),
                    ),
                  ),
                if (_customKoin > _koin)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: kDanger.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                      child: const Row(children: [
                        Icon(Icons.warning_amber_rounded, color: kDanger, size: 16),
                        SizedBox(width: 8),
                        Text('Koin tidak cukup', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDanger)),
                      ]),
                    ),
                  ),
              ],
            ]),
          ),
          const SizedBox(height: 24),

          // ── Ringkasan ──
          if (_canExchange) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.cardDecoration,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Ringkasan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
                const SizedBox(height: 12),
                _summaryRow('Koin Digunakan', '$_koinYangDipakai koin', kWarning),
                const SizedBox(height: 8),
                _summaryRow('Saldo Didapat', 'Rp ${_fmt(_rupiahDidapat)}', kPrimary),
                const Divider(height: 20),
                _summaryRow('Koin Tersisa', '${_koin - _koinYangDipakai} koin', kTextSoft),
              ]),
            ),
            const SizedBox(height: 16),
          ],

          // ── History ──
          const Text('Riwayat Penukaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 12),
          ..._buildHistory(),
        ]),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
        child: ElevatedButton(
          onPressed: _canExchange ? _konfirmasi : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            disabledBackgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.white,
            disabledForegroundColor: kTextSoft,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 0,
          ),
          child: Text(
            _canExchange
                ? 'Tukar $_koinYangDipakai Koin → Rp ${_fmt(_rupiahDidapat)}'
                : 'Pilih Paket atau Masukkan Koin',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _assetItem(IconData icon, String val, String label, {bool koinColor = false}) {
    return Column(children: [
      Icon(icon, color: Colors.white, size: 22),
      const SizedBox(height: 4),
      Text(val, style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w800,
          fontSize: 18,
          shadows: koinColor ? [] : [])),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]);
  }

  Widget _buildPaketCard(PaketTukar p) {
    final sel = _selectedPaket?.id == p.id;
    final cukup = p.koin <= _koin;
    return GestureDetector(
      onTap: cukup ? () => _selectPaket(p) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: !cukup ? Colors.grey.shade50 : sel ? kPrimary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: sel ? kPrimary : cukup ? Colors.grey.shade200 : Colors.grey.shade100,
            width: sel ? 2 : 1,
          ),
          boxShadow: sel ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Stack(children: [
          // Popular badge
          if (p.isPopular)
            Positioned(
              top: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: kWarning,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(18), bottomLeft: Radius.circular(12)),
                ),
                child: const Text('Terlaris', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ),

          // Not enough
          if (!cukup)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(children: [
                Text(p.label, style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: sel ? kPrimary : cukup ? kTextSoft : Colors.grey.shade400)),
                if (sel) ...[const Spacer(), const Icon(Icons.check_circle_rounded, color: kPrimary, size: 18)],
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.monetization_on_rounded, color: sel ? kPrimary : cukup ? kWarning : Colors.grey.shade400, size: 18),
                const SizedBox(width: 4),
                Text('${p.koin} koin', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: sel ? kPrimary : cukup ? kText : Colors.grey.shade400)),
              ]),
              const SizedBox(height: 4),
              Text('Rp ${_fmt(p.rupiah)}', style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: sel ? kPrimary : cukup ? kPrimary : Colors.grey.shade400)),
              Text('≈ ${p.rupPerKoin} rp/koin', style: TextStyle(
                  fontSize: 10, color: sel ? kPrimary.withValues(alpha: 0.6) : kTextSoft)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _summaryRow(String label, String val, Color color) {
    return Row(children: [
      Text(label, style: const TextStyle(fontSize: 13, color: kTextSoft)),
      const Spacer(),
      Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ]);
  }

  List<Widget> _buildHistory() {
    final history = [
      _HistoryItem('10 Apr 2025', 100, 9500),
      _HistoryItem('2 Apr 2025', 50, 4500),
      _HistoryItem('25 Mar 2025', 200, 20000),
    ];
    return history.map((h) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration,
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.swap_horiz_rounded, color: kPrimary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${h.koin} Koin → Rp ${_fmt(h.rupiah)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kText)),
          Text(h.tanggal, style: const TextStyle(fontSize: 11, color: kTextSoft)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(10)),
          child: const Text('Selesai', style: TextStyle(fontSize: 11, color: kPrimary, fontWeight: FontWeight.w600)),
        ),
      ]),
    )).toList();
  }
}

class _HistoryItem {
  final String tanggal;
  final int koin;
  final int rupiah;
  const _HistoryItem(this.tanggal, this.koin, this.rupiah);
}