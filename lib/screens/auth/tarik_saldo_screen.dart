import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class TarikSaldoScreen extends StatefulWidget {
  final double saldoAwal;
  const TarikSaldoScreen({super.key, this.saldoAwal = 0});

  @override
  State<TarikSaldoScreen> createState() => _TarikSaldoScreenState();
}

class _TarikSaldoScreenState extends State<TarikSaldoScreen>
    with SingleTickerProviderStateMixin {
  late double _saldo;
  String _metodeSelected = '';
  final TextEditingController _nominalCtrl = TextEditingController();
  String _nominal = '';
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  final List<Map<String, dynamic>> _metode = [
    {'nama': 'Dana', 'icon': Icons.account_balance_wallet_rounded, 'color': const Color(0xFF118EEA)},
    {'nama': 'OVO', 'icon': Icons.account_balance_wallet_rounded, 'color': const Color(0xFF4C3494)},
    {'nama': 'GoPay', 'icon': Icons.account_balance_wallet_rounded, 'color': const Color(0xFF00AA5B)},
    {'nama': 'ShopeePay', 'icon': Icons.account_balance_wallet_rounded, 'color': const Color(0xFFEE4D2D)},
    {'nama': 'BCA', 'icon': Icons.account_balance_rounded, 'color': const Color(0xFF003D6B)},
    {'nama': 'Mandiri', 'icon': Icons.account_balance_rounded, 'color': const Color(0xFF003087)},
  ];

  final List<int> _nominalCepat = [10000, 25000, 50000, 100000, 200000];

  @override
  void initState() {
    super.initState();
    _saldo = widget.saldoAwal;
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _bounceAnim = CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut);
    _bounceCtrl.forward();
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _nominalCtrl.dispose();
    super.dispose();
  }

  int get _nominalInt => int.tryParse(_nominal) ?? 0;
  bool get _canWithdraw =>
      _metodeSelected.isNotEmpty && _nominalInt >= 10000 && _nominalInt <= _saldo;

  String _fmt(int n) => n.toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  void _konfirmasi() {
    if (!_canWithdraw) return;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Konfirmasi Penarikan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9146), Color(0xFF26D077)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 22),
                    const SizedBox(height: 4),
                    Text('Rp ${_fmt(_nominalInt)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    const Text('Nominal', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ]),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white54, size: 28),
                  Column(children: [
                    const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    const SizedBox(height: 4),
                    Text(_metodeSelected,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    const Text('Tujuan', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _konfRow('Saldo Saat Ini', 'Rp ${_fmt(_saldo.toInt())}'),
            _konfRow('Nominal Ditarik', 'Rp ${_fmt(_nominalInt)}'),
            _konfRow('Saldo Setelah', 'Rp ${_fmt((_saldo - _nominalInt).toInt())}', isHighlight: true),
            _konfRow('Metode', _metodeSelected),
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
                  onPressed: () { Navigator.pop(context); _lakukan(); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Ya, Tarik!', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
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
      _saldo -= _nominalInt;
      _nominalCtrl.clear();
      _nominal = '';
      _metodeSelected = '';
    });
    _bounceCtrl.reset();
    _bounceCtrl.forward();
    _showSukses();
  }

  void _showSukses() {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 16),
              const Text('Penarikan Berhasil!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kText)),
              const SizedBox(height: 8),
              const Text('Saldo akan masuk dalam 1x24 jam.',
                  style: TextStyle(color: kTextSoft, fontSize: 13)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: kPrimaryLight,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: kPrimary.withValues(alpha: 0.25))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, color: kPrimary, size: 20),
                    const SizedBox(width: 8),
                    Text('Saldo Tersisa: Rp ${_fmt(_saldo.toInt())}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kPrimary)),
                  ],
                ),
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
            ],
          ),
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
        title: const Text('Tarik Saldo',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kText)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Saldo Card ──
            ScaleTransition(
              scale: _bounceAnim,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D9146), Color(0xFF26D077)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: kPrimary.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(children: [
                  const Text('Saldo Tersedia', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text('Rp ${_fmt(_saldo.toInt())}',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
            const SizedBox(height: 24),

            // ── Info minimum ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kInfo.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kInfo.withValues(alpha: 0.2)),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded, color: kInfo, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Minimum penarikan Rp 10.000. Proses 1x24 jam.',
                      style: TextStyle(fontSize: 12, color: kInfo)),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Pilih Metode ──
            const Text('Pilih Metode Penarikan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kText)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.6,
              ),
              itemCount: _metode.length,
              itemBuilder: (_, i) {
                final m = _metode[i];
                final sel = _metodeSelected == m['nama'];
                return GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() => _metodeSelected = m['nama']); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: sel ? (m['color'] as Color).withValues(alpha: 0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sel ? m['color'] as Color : Colors.grey.shade200,
                        width: sel ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(m['icon'] as IconData,
                            color: sel ? m['color'] as Color : kTextSoft, size: 20),
                        const SizedBox(height: 4),
                        Text(m['nama'],
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                                color: sel ? m['color'] as Color : kTextSoft)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Input Nominal ──
            const Text('Nominal Penarikan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kText)),
            const SizedBox(height: 10),
            Container(
              decoration: AppTheme.cardDecoration,
              child: Row(children: [
                const SizedBox(width: 16),
                const Text('Rp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kText)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _nominalCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) => setState(() => _nominal = v),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kText),
                    decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(fontSize: 22, color: kTextSoft, fontWeight: FontWeight.w400),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                if (_nominal.isNotEmpty)
                  IconButton(
                    onPressed: () { setState(() { _nominalCtrl.clear(); _nominal = ''; }); },
                    icon: const Icon(Icons.close_rounded, color: kTextSoft, size: 18),
                  ),
              ]),
            ),

            if (_nominalInt > 0 && _nominalInt > _saldo)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Nominal melebihi saldo tersedia',
                    style: TextStyle(color: kDanger, fontSize: 12)),
              ),

            const SizedBox(height: 14),

            // Nominal cepat
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _nominalCepat.where((n) => n <= _saldo).map((n) {
                final sel = _nominalInt == n;
                return GestureDetector(
                  onTap: () {
                    _nominalCtrl.text = n.toString();
                    setState(() => _nominal = n.toString());
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? kPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? kPrimary : Colors.grey.shade300),
                    ),
                    child: Text('Rp ${_fmt(n)}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : kTextSoft)),
                  ),
                );
              }).toList(),
            ),

            if (_canWithdraw) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ringkasan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
                    const SizedBox(height: 12),
                    _konfRow('Nominal', 'Rp ${_fmt(_nominalInt)}'),
                    const SizedBox(height: 4),
                    _konfRow('Tujuan', _metodeSelected),
                    const Divider(height: 20),
                    _konfRow('Saldo Setelah', 'Rp ${_fmt((_saldo - _nominalInt).toInt())}', isHighlight: true),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
        child: ElevatedButton(
          onPressed: _canWithdraw ? _konfirmasi : null,
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
            _canWithdraw ? 'Tarik Rp ${_fmt(_nominalInt)} ke $_metodeSelected' : 'Pilih Metode & Nominal',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ),
    );
  }
}