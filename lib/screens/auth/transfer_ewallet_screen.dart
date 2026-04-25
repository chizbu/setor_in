import 'package:flutter/material.dart';
import 'app_theme.dart';

class TransferEwalletScreen extends StatefulWidget {
  const TransferEwalletScreen({super.key});

  @override
  State<TransferEwalletScreen> createState() => _TransferEwalletScreenState();
}

class _TransferEwalletScreenState extends State<TransferEwalletScreen> {
  String? _selectedEwallet;
  final TextEditingController _nomorCtrl = TextEditingController();
  final TextEditingController _nominalCtrl = TextEditingController();
  final double _saldoTersedia = 125000;

  final List<Map<String, dynamic>> _ewallets = [
    {'nama': 'Dana', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFF108EE9)},
    {'nama': 'OVO', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFF4C3494)},
    {'nama': 'GoPay', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFF00AED6)},
    {'nama': 'ShopeePay', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFFEE4D2D)},
  ];

  final List<int> _nominalCepat = [10000, 25000, 50000, 100000];

  String _fmt(int n) => n.toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  int get _nominal => int.tryParse(_nominalCtrl.text.replaceAll('.', '')) ?? 0;

  bool get _canProceed =>
      _selectedEwallet != null &&
      _nomorCtrl.text.length >= 10 &&
      _nominal > 0 &&
      _nominal <= _saldoTersedia;

  @override
  void dispose() {
    _nomorCtrl.dispose();
    _nominalCtrl.dispose();
    super.dispose();
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
        title: const Text('Transfer Saldo',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kText)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // saldo card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: kGradientPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 20),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Saldo Tersedia', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Text('Rp ${_fmt(_saldoTersedia.toInt())}',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              ]),
            ]),
          ),
          const SizedBox(height: 24),

          // pilih e-wallet
          const Text('Pilih E-Wallet',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
          const SizedBox(height: 12),
          Row(children: _ewallets.map((e) {
            final sel = _selectedEwallet == e['nama'];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedEwallet = e['nama']),
                child: Container(
                  margin: EdgeInsets.only(right: e == _ewallets.last ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: sel ? (e['color'] as Color).withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel ? e['color'] as Color : Colors.grey.shade200,
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: Column(children: [
                    Icon(e['icon'] as IconData, color: e['color'] as Color, size: 22),
                    const SizedBox(height: 4),
                    Text(e['nama'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                          color: sel ? e['color'] as Color : kTextSoft,
                        )),
                  ]),
                ),
              ),
            );
          }).toList()),
          const SizedBox(height: 22),

          // nomor tujuan
          const Text('Nomor Tujuan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: TextField(
              controller: _nomorCtrl,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Masukkan nomor ${_selectedEwallet ?? 'e-wallet'}',
                hintStyle: const TextStyle(color: kTextSoft, fontSize: 13),
                prefixIcon: const Icon(Icons.phone_android_rounded, color: kTextSoft, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // nominal
          const Text('Nominal Transfer',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: TextField(
              controller: _nominalCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kText),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(fontSize: 20, color: kTextSoft, fontWeight: FontWeight.w400),
                prefixText: 'Rp  ',
                prefixStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kText),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          if (_nominal > _saldoTersedia) ...[
            const SizedBox(height: 6),
            const Text('Saldo tidak mencukupi',
                style: TextStyle(fontSize: 12, color: kDanger)),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _nominalCepat.map((amt) => GestureDetector(
              onTap: () {
                _nominalCtrl.text = amt.toString();
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kPrimary.withValues(alpha: 0.3)),
                ),
                child: Text('Rp ${_fmt(amt)}',
                    style: const TextStyle(
                        color: kPrimary, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _canProceed ? _showKonfirmasi : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Lanjutkan',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showKonfirmasi() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Konfirmasi Transfer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              _konfRow('E-Wallet', _selectedEwallet!),
              _konfDiv(),
              _konfRow('Nomor Tujuan', _nomorCtrl.text),
              _konfDiv(),
              _konfRow('Nominal', 'Rp ${_fmt(_nominal)}'),
              _konfDiv(),
              _konfRow('Biaya Admin', 'Gratis', valColor: kPrimary),
              _konfDiv(),
              _konfRow('Total Dipotong', 'Rp ${_fmt(_nominal)}',
                  bold: true, valColor: kDanger),
            ]),
          ),
          const SizedBox(height: 24),

          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showBerhasil();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Transfer', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  void _showBerhasil() {
    final now = DateTime.now();
    const bln = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final tanggal =
        '${now.day} ${bln[now.month]} ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      isScrollControlled: true,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: kPrimary, size: 44),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Transfer Berhasil!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kText)),
            const SizedBox(height: 6),
            Text(tanggal, style: const TextStyle(fontSize: 12, color: kTextSoft)),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: kGradientPrimary, borderRadius: BorderRadius.circular(18)),
              child: Column(children: [
                Text('Rp ${_fmt(_nominal)}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Dikirim ke $_selectedEwallet • ${_nomorCtrl.text}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Kembali ke Beranda',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _konfRow(String label, String val, {bool bold = false, Color? valColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 13, color: kTextSoft)),
        const Spacer(),
        Text(val,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: valColor ?? kText,
            )),
      ]),
    );
  }

  Widget _konfDiv() =>
      Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade200);
}