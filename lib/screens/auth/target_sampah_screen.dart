import 'package:flutter/material.dart';
import 'penargetan_sampah_screen.dart';

const Color kPrimary = Color(0xFF26D077);
const Color kPrimaryDark = Color(0xFF1BAF60);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Jadwal penyetoran ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                          children: [
                            const TextSpan(
                                text:
                                    'Jadwal penyetoran sampah berikutnya di tanggal : '),
                            TextSpan(
                              text: '31 maret 2026',
                              style: TextStyle(
                                  color: kPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Card Target ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
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
                              '${_targetKg.toStringAsFixed(0)}kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Estimasi koin yang di dapatkan : $_estimasiKoin',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _sudahBuatTarget
                                ? 'Target sudah diset ✓'
                                : 'Anda belum membuat penargetan',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          // ✅ Tombol lakukan penargetan
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PenargentanSampahScreen(),
                                ),
                              );
                              // Terima hasil dari halaman penargetan
                              if (result != null) {
                                setState(() {
                                  _targetKg = result['totalKg'];
                                  _estimasiKoin = result['totalKoin'];
                                  _estimasiSaldo = result['totalSaldo'];
                                  _sudahBuatTarget = true;
                                });
                              }
                            },
                            child: Text(
                              _sudahBuatTarget
                                  ? 'Ubah penargetan sampah'
                                  : 'Lakukan penargetan sampah',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Grid hari ──
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _totalHari,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final isSelesai = _hariStatus[index];
                        return GestureDetector(
                          onTap: () {
                            if (_sudahBuatTarget) {
                              setState(() {
                                _hariStatus[index] = !_hariStatus[index];
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Lakukan penargetan sampah dulu'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    isSelesai
                                        ? Icons.check_circle
                                        : Icons.lock,
                                    color: isSelesai
                                        ? kPrimary
                                        : Colors.red,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Hari ke-${index + 1}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black87),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}