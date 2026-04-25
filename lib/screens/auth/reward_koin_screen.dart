import 'package:flutter/material.dart';
import 'app_theme.dart';

class RewardKoinScreen extends StatefulWidget {
  const RewardKoinScreen({super.key});

  @override
  State<RewardKoinScreen> createState() => _RewardKoinScreenState();
}

class _RewardKoinScreenState extends State<RewardKoinScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final int _koinSaya = 320;

  final List<Map<String, dynamic>> _vouchers = [
    {'nama': 'Voucher Belanja Rp 10.000', 'brand': 'Tokopedia', 'koin': 100, 'icon': Icons.shopping_bag_outlined, 'color': Color(0xFF42A94B), 'kategori': 'Belanja', 'expired': '31 Des 2025'},
    {'nama': 'Voucher Makan Rp 15.000', 'brand': 'GrabFood', 'koin': 150, 'icon': Icons.fastfood_outlined, 'color': Color(0xFF00AED6), 'kategori': 'Makanan', 'expired': '30 Nov 2025'},
    {'nama': 'Pulsa Rp 5.000', 'brand': 'Semua Operator', 'koin': 80, 'icon': Icons.phone_android_outlined, 'color': Color(0xFF8B5CF6), 'kategori': 'Pulsa', 'expired': '31 Des 2025'},
    {'nama': 'Voucher Belanja Rp 25.000', 'brand': 'Shopee', 'koin': 250, 'icon': Icons.shopping_cart_outlined, 'color': Color(0xFFEE4D2D), 'kategori': 'Belanja', 'expired': '28 Feb 2026'},
    {'nama': 'Diskon Tagihan Listrik', 'brand': 'PLN Mobile', 'koin': 200, 'icon': Icons.bolt_outlined, 'color': Color(0xFFF59E0B), 'kategori': 'Tagihan', 'expired': '31 Jan 2026'},
    {'nama': 'Voucher Transportasi', 'brand': 'Gojek', 'koin': 120, 'icon': Icons.directions_bike_outlined, 'color': Color(0xFF00AED6), 'kategori': 'Transport', 'expired': '31 Des 2025'},
  ];

  final List<Map<String, dynamic>> _riwayatTukar = [
    {'nama': 'Voucher Belanja Rp 10.000', 'koin': -100, 'tanggal': '10 Apr 2025', 'status': 'Aktif'},
    {'nama': 'Pulsa Rp 5.000', 'koin': -80, 'tanggal': '2 Mar 2025', 'status': 'Digunakan'},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
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
        title: const Text('Reward Koin',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kText)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Column(children: [
        // koin banner
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Koin Kamu',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Text('$_koinSaya Koin',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                const Text('Tukarkan dengan hadiah menarik!',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
              ]),
            ),
          ]),
        ),

        // tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: TabBar(
            controller: _tabCtrl,
            indicator: BoxDecoration(
                color: kPrimary, borderRadius: BorderRadius.circular(10)),
            labelColor: Colors.white,
            unselectedLabelColor: kTextSoft,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Katalog Hadiah'),
              Tab(text: 'Riwayat Tukar'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildKatalog(),
              _buildRiwayat(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildKatalog() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: _vouchers.length,
      itemBuilder: (_, i) {
        final v = _vouchers[i];
        final bisa = _koinSaya >= (v['koin'] as int);
        return GestureDetector(
          onTap: () => _showDetailVoucher(v, bisa),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: (v['color'] as Color).withValues(alpha: 0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Center(
                    child: Icon(v['icon'] as IconData,
                        color: v['color'] as Color, size: 36)),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(v['brand'] as String,
                      style: TextStyle(
                          fontSize: 10,
                          color: v['color'] as Color,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(v['nama'] as String,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700, color: kText),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: bisa
                          ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.monetization_on_rounded,
                          size: 12,
                          color: bisa
                              ? const Color(0xFF8B5CF6)
                              : kTextSoft),
                      const SizedBox(width: 3),
                      Text('${v['koin']} koin',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: bisa ? const Color(0xFF8B5CF6) : kTextSoft,
                          )),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildRiwayat() {
    if (_riwayatTukar.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_outlined, color: kPrimary, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada penukaran',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
          const SizedBox(height: 4),
          const Text('Tukar koinmu dengan hadiah menarik!',
              style: TextStyle(fontSize: 12, color: kTextSoft)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: _riwayatTukar.length,
      itemBuilder: (_, i) {
        final r = _riwayatTukar[i];
        final aktif = r['status'] == 'Aktif';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.card_giftcard_rounded,
                  color: Color(0xFF8B5CF6), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r['nama'] as String,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
                const SizedBox(height: 3),
                Text(r['tanggal'] as String,
                    style: const TextStyle(fontSize: 11, color: kTextSoft)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${r['koin']} koin',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: kDanger)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: aktif
                      ? kPrimary.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(r['status'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: aktif ? kPrimary : kTextSoft,
                    )),
              ),
            ]),
          ]),
        );
      },
    );
  }

  void _showDetailVoucher(Map<String, dynamic> v, bool bisa) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),

          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: (v['color'] as Color).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(v['icon'] as IconData,
                color: v['color'] as Color, size: 40),
          ),
          const SizedBox(height: 14),
          Text(v['brand'] as String,
              style: TextStyle(
                  fontSize: 13,
                  color: v['color'] as Color,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(v['nama'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
          const SizedBox(height: 20),

          Container(
            decoration:
                BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              _detailRow('Kategori', v['kategori'] as String),
              Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade200),
              _detailRow('Berlaku hingga', v['expired'] as String),
              Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade200),
              _detailRow('Koin dibutuhkan', '${v['koin']} koin'),
              Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade200),
              _detailRow('Koin kamu', '$_koinSaya koin',
                  valColor: bisa ? kPrimary : kDanger),
            ]),
          ),
          const SizedBox(height: 20),

          if (!bisa) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kDanger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kDanger.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded, color: kDanger, size: 16),
                const SizedBox(width: 8),
                Text(
                    'Koin kurang ${(v['koin'] as int) - _koinSaya} lagi',
                    style: const TextStyle(
                        fontSize: 12,
                        color: kDanger,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: bisa
                  ? () {
                      Navigator.pop(context);
                      _showSuksesTukar(v);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                bisa ? 'Tukar ${v['koin']} Koin' : 'Koin Tidak Cukup',
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _showSuksesTukar(Map<String, dynamic> v) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (_, val, child) =>
                  Transform.scale(scale: val, child: child),
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.card_giftcard_rounded,
                    color: Color(0xFF8B5CF6), size: 44),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Penukaran Berhasil!',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: kText)),
            const SizedBox(height: 8),
            Text(
                '${v['nama']} berhasil ditukar dengan ${v['koin']} koin',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: kTextSoft)),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                Icon(v['icon'] as IconData, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(v['nama'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text('Berlaku hingga ${v['expired']}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 11)),
              ]),
            ),
            const SizedBox(height: 24),

            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _tabCtrl.animateTo(1);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5CF6),
                    side: const BorderSide(color: Color(0xFF8B5CF6)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Lihat Riwayat',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Tutup',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String val, {Color? valColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 13, color: kTextSoft)),
        const Spacer(),
        Text(val,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valColor ?? kText)),
      ]),
    );
  }
}