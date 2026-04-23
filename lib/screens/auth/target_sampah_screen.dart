import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'penargetan_sampah_screen.dart';

class TargetSampahScreen extends StatefulWidget {
  const TargetSampahScreen({super.key});

  @override
  State<TargetSampahScreen> createState() => _TargetSampahScreenState();
}

class _TargetSampahScreenState extends State<TargetSampahScreen> {
  double _targetKg = 0;
  int _estimasiKoin = 0;
  double _estimasiSaldo = 0;
  bool _sudahBuatTarget = false;
  final int _totalHari = 30;
  late List<bool> _hariStatus;

  @override
  void initState() {
    super.initState();
    _hariStatus = List.generate(_totalHari, (_) => false);
  }

  int get _hariSelesai => _hariStatus.where((h) => h).length;

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
        title: const Text('Target Sampah',
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
            // ── Jadwal setor ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kInfo.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kInfo.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today_rounded, color: kInfo, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: kText),
                      children: [
                        const TextSpan(text: 'Jadwal setor berikutnya: '),
                        TextSpan(
                          text: '31 Maret 2026',
                          style: const TextStyle(
                              color: kPrimary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Target Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: kGradientPrimary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: kPrimary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Target Bulan Ini',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: _bukaFormTarget,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(children: [
                            Icon(
                              _sudahBuatTarget
                                  ? Icons.edit_rounded
                                  : Icons.add_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _sudahBuatTarget ? 'Ubah' : 'Buat Target',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (!_sudahBuatTarget)
                    // Belum ada target
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(children: [
                        const Icon(Icons.flag_outlined,
                            color: Colors.white70, size: 36),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Belum ada target',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(height: 2),
                              Text(
                                  'Buat target bulanan untuk memulai misi harian',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ]),
                    )
                  else
                    // Ada target
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_targetKg.toStringAsFixed(0)} kg',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    height: 1),
                              ),
                              const SizedBox(height: 4),
                              const Text('target terkumpul',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _targetChip(Icons.monetization_on_rounded,
                                '$_estimasiKoin koin'),
                            const SizedBox(height: 6),
                            _targetChip(Icons.account_balance_wallet_outlined,
                                'Rp ${_fmt(_estimasiSaldo.toInt())}'),
                          ],
                        ),
                      ],
                    ),

                  // Progress bar harian
                  if (_sudahBuatTarget) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$_hariSelesai/$_totalHari hari selesai',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        Text(
                            '${(_hariSelesai / _totalHari * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _hariSelesai / _totalHari,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor:
                            const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Stat strip (jika sudah ada target) ──
            if (_sudahBuatTarget) ...[
              Row(children: [
                Expanded(
                    child: _statCard(Icons.check_circle_outline_rounded,
                        '$_hariSelesai', 'Hari Selesai', kPrimary)),
                const SizedBox(width: 10),
                Expanded(
                    child: _statCard(Icons.lock_outline_rounded,
                        '${_totalHari - _hariSelesai}', 'Hari Tersisa', kWarning)),
                const SizedBox(width: 10),
                Expanded(
                    child: _statCard(
                        Icons.emoji_events_outlined,
                        '${(_hariSelesai / _totalHari * 100).toStringAsFixed(0)}%',
                        'Progres',
                        kInfo)),
              ]),
              const SizedBox(height: 24),
            ],

            // ── Grid Misi Harian ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _sudahBuatTarget ? 'Jalankan Misi' : 'Misi Harian',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kText),
                ),
                if (!_sudahBuatTarget)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kWarning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Buat target dulu',
                        style: TextStyle(
                            fontSize: 11,
                            color: kWarning,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _totalHari,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final isSelesai = _hariStatus[index];
                return GestureDetector(
                  onTap: () {
                    if (_sudahBuatTarget) {
                      setState(() => _hariStatus[index] = !_hariStatus[index]);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            const Text('Buat target sampah terlebih dahulu'),
                        backgroundColor: kWarning,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ));
                    }
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelesai
                              ? kPrimary.withValues(alpha: 0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelesai
                                ? kPrimary
                                : Colors.grey.shade200,
                            width: isSelesai ? 1.5 : 1,
                          ),
                          boxShadow: isSelesai
                              ? []
                              : [
                                  BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.04),
                                      blurRadius: 4)
                                ],
                        ),
                        child: Center(
                          child: isSelesai
                              ? const Icon(Icons.check_rounded,
                                  color: kPrimary, size: 22)
                              : Text('${index + 1}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _sudahBuatTarget
                                          ? kText
                                          : kTextSoft)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Hari',
                          style: const TextStyle(
                              fontSize: 9, color: kTextSoft)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _targetChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 13),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _statCard(IconData icon, String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: AppTheme.cardDecoration,
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(val,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 10, color: kTextSoft)),
      ]),
    );
  }

  Future<void> _bukaFormTarget() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PenargentanSampahScreen()),
    );
    if (result != null) {
      setState(() {
        _targetKg = result['totalKg'];
        _estimasiKoin = result['totalKoin'];
        _estimasiSaldo = result['totalSaldo'];
        _sudahBuatTarget = true;
      });
    }
  }
}