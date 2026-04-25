import 'package:flutter/material.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────
class JenisSampah {
  final String id;
  final String nama;
  final IconData icon;
  final Color color;
  final int koinPerKg;
  final int hargaPerKg;

  const JenisSampah({
    required this.id,
    required this.nama,
    required this.icon,
    required this.color,
    required this.koinPerKg,
    required this.hargaPerKg,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT — langsung ke Riwayat Nasabah
// ─────────────────────────────────────────────────────────────────────────────
class SetorSampahScreen extends StatelessWidget {
  const SetorSampahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RiwayatNasabahScreen();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RIWAYAT & NOTIFIKASI NASABAH
// ─────────────────────────────────────────────────────────────────────────────
class _RiwayatNasabahScreen extends StatelessWidget {
  const _RiwayatNasabahScreen();

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static final List<Map<String, dynamic>> _riwayat = [
    {
      'kode': 'STR-20250412-8821',
      'jenis': 'Plastik',
      'icon': Icons.water_drop_outlined,
      'color': const Color(0xFF26D077),
      'berat': 2.3,
      'koin': 46,
      'saldo': 4600,
      'tanggal': '12 Apr 2025, 10:23',
      'baru': true,
    },
    {
      'kode': 'STR-20250408-4412',
      'jenis': 'Kertas',
      'icon': Icons.article_outlined,
      'color': const Color(0xFF3B82F6),
      'berat': 1.0,
      'koin': 15,
      'saldo': 1500,
      'tanggal': '8 Apr 2025, 09:10',
      'baru': false,
    },
    {
      'kode': 'STR-20250401-7731',
      'jenis': 'Logam',
      'icon': Icons.hardware_outlined,
      'color': const Color(0xFFF59E0B),
      'berat': 0.8,
      'koin': 32,
      'saldo': 3200,
      'tanggal': '1 Apr 2025, 14:45',
      'baru': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final hasNew = _riwayat.any((r) => r['baru'] == true);

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
              color: kBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: kText,
            ),
          ),
        ),
        title: const Text(
          'Riwayat Setor',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: kText,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: kText),
              ),
              if (hasNew)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: kDanger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner notifikasi bill baru
          if (hasNew) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kPrimary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: kPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bill Baru Masuk!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Kamu punya 1 tagihan setor baru dari petugas.',
                          style: TextStyle(fontSize: 12, color: kTextSoft),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          const Text(
            'Riwayat Transaksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
          const SizedBox(height: 14),

          ..._riwayat.map(
            (r) => GestureDetector(
              onTap: () => _showBillDetail(context, r),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: (r['baru'] as bool)
                      ? Border.all(color: kPrimary, width: 1.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (r['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        r['icon'] as IconData,
                        color: r['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                r['jenis'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: kText,
                                ),
                              ),
                              if (r['baru'] as bool) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kPrimary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'BARU',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${r['berat']} kg • ${r['tanggal']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: kTextSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+${r['koin']} koin',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rp ${_fmt(r['saldo'] as int)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: kTextSoft,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBillDetail(BuildContext context, Map<String, dynamic> r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.82,
        maxChildSize: 0.95,
        minChildSize: 0.75,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  children: [
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: (r['color'] as Color).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          r['icon'] as IconData,
                          color: r['color'] as Color,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Detail Bill Setor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: kText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        r['tanggal'] as String,
                        style: const TextStyle(fontSize: 12, color: kTextSoft),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Kode transaksi
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: kPrimaryLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: kPrimary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Kode Transaksi',
                            style: TextStyle(fontSize: 11, color: kTextSoft),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r['kode'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: kPrimary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Detail transaksi
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _bRow('Jenis Sampah', r['jenis'] as String),
                          _bDiv(),
                          _bRow('Berat', '${r['berat']} kg'),
                          _bDiv(),
                          _bRow('Tanggal', r['tanggal'] as String),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Total
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: kGradientPrimary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Yang Kamu Dapat',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _totalItem(
                                Icons.monetization_on_rounded,
                                '+${r['koin']} Koin',
                                'Koin',
                              ),
                              Container(
                                width: 1,
                                height: 44,
                                color: Colors.white24,
                              ),
                              _totalItem(
                                Icons.account_balance_wallet_outlined,
                                'Rp ${_fmt(r['saldo'] as int)}',
                                'Saldo',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: kTextSoft),
          ),
          const Spacer(),
          Text(
            val,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bDiv() => Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: Colors.grey.shade200,
      );

  Widget _totalItem(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 6),
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }
}