import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────
enum MisiStatus { belum, selesai, diklaim }

class MisiItem {
  final String id;
  final String judul;
  final String deskripsi;
  final IconData icon;
  final Color color;
  final int koinReward;
  final int targetJumlah;
  int progressJumlah;
  MisiStatus status;
  final String kategori; // 'harian' | 'mingguan'

  MisiItem({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.icon,
    required this.color,
    required this.koinReward,
    required this.targetJumlah,
    required this.progressJumlah,
    required this.status,
    required this.kategori,
  });

  double get progress => targetJumlah == 0 ? 0 : (progressJumlah / targetJumlah).clamp(0.0, 1.0);
  bool get bisaDiklaim => progressJumlah >= targetJumlah && status == MisiStatus.selesai;
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class MisiHarianScreen extends StatefulWidget {
  final int koinAwal;
  const MisiHarianScreen({super.key, this.koinAwal = 0});

  @override
  State<MisiHarianScreen> createState() => _MisiHarianScreenState();
}

class _MisiHarianScreenState extends State<MisiHarianScreen>
    with SingleTickerProviderStateMixin {
  late int _koin;
  late TabController _tabCtrl;

  final List<MisiItem> _misi = [
    MisiItem(
      id: 'm1',
      judul: 'Setor Sampah Hari Ini',
      deskripsi: 'Lakukan 1 kali setor sampah apapun hari ini.',
      icon: Icons.recycling_rounded,
      color: kPrimary,
      koinReward: 10,
      targetJumlah: 1,
      progressJumlah: 1,
      status: MisiStatus.selesai,
      kategori: 'harian',
    ),
    MisiItem(
      id: 'm2',
      judul: 'Laporan Harian',
      deskripsi: 'Isi laporan sampah harian kamu.',
      icon: Icons.assignment_outlined,
      color: kInfo,
      koinReward: 5,
      targetJumlah: 1,
      progressJumlah: 0,
      status: MisiStatus.belum,
      kategori: 'harian',
    ),
    MisiItem(
      id: 'm3',
      judul: 'Baca Konten Edukasi',
      deskripsi: 'Baca minimal 1 artikel edukasi daur ulang.',
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF8B5CF6),
      koinReward: 5,
      targetJumlah: 1,
      progressJumlah: 1,
      status: MisiStatus.diklaim,
      kategori: 'harian',
    ),
    MisiItem(
      id: 'm4',
      judul: 'Setor 5 kg Plastik',
      deskripsi: 'Kumpulkan dan setor total 5 kg sampah plastik minggu ini.',
      icon: Icons.water_drop_outlined,
      color: kPrimary,
      koinReward: 50,
      targetJumlah: 5,
      progressJumlah: 2,
      status: MisiStatus.belum,
      kategori: 'mingguan',
    ),
    MisiItem(
      id: 'm5',
      judul: 'Setor 3 Jenis Sampah',
      deskripsi: 'Setor minimal 3 jenis sampah berbeda dalam seminggu.',
      icon: Icons.category_outlined,
      color: kWarning,
      koinReward: 30,
      targetJumlah: 3,
      progressJumlah: 1,
      status: MisiStatus.belum,
      kategori: 'mingguan',
    ),
    MisiItem(
      id: 'm6',
      judul: 'Laporan 7 Hari Berturut',
      deskripsi: 'Isi laporan harian selama 7 hari berturut-turut.',
      icon: Icons.calendar_today_rounded,
      color: kDanger,
      koinReward: 70,
      targetJumlah: 7,
      progressJumlah: 4,
      status: MisiStatus.belum,
      kategori: 'mingguan',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _koin = widget.koinAwal;
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<MisiItem> get _harian => _misi.where((m) => m.kategori == 'harian').toList();
  List<MisiItem> get _mingguan => _misi.where((m) => m.kategori == 'mingguan').toList();

  int get _totalKoinTersedia => _misi
      .where((m) => m.status == MisiStatus.selesai)
      .fold(0, (sum, m) => sum + m.koinReward);

  void _klaimMisi(MisiItem misi) {
    if (misi.status != MisiStatus.selesai) return;
    HapticFeedback.mediumImpact();
    setState(() {
      misi.status = MisiStatus.diklaim;
      _koin += misi.koinReward;
    });
    _showKlaimSuccess(misi);
  }

  void _showKlaimSuccess(MisiItem misi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                    color: misi.color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(Icons.emoji_events_rounded, color: misi.color, size: 44),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Misi Selesai!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kText)),
            const SizedBox(height: 8),
            Text(misi.judul,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: kTextSoft)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                  color: kPrimaryLight, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on_rounded, color: kPrimary, size: 24),
                  const SizedBox(width: 8),
                  Text('+${misi.koinReward} Koin',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800, color: kPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Lanjutkan', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Misi & Reward',
                style: TextStyle(fontWeight: FontWeight.w700)),
            centerTitle: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: kGradientPrimary),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Total Koinmu',
                                  style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('$_koin Koin',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                        if (_totalKoinTersedia > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.card_giftcard_rounded,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text('+$_totalKoinTersedia koin siap diklaim',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [Tab(text: 'Misi Harian'), Tab(text: 'Misi Mingguan')],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildMisiList(_harian),
            _buildMisiList(_mingguan),
          ],
        ),
      ),
    );
  }

  Widget _buildMisiList(List<MisiItem> list) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: list.length,
      itemBuilder: (_, i) => _buildMisiCard(list[i]),
    );
  }

  Widget _buildMisiCard(MisiItem misi) {
    final isDiklaim = misi.status == MisiStatus.diklaim;
    final isSelesai = misi.status == MisiStatus.selesai;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelesai ? Border.all(color: misi.color.withValues(alpha: 0.4), width: 1.5) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: isDiklaim
                      ? Colors.grey.shade100
                      : misi.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(misi.icon,
                    color: isDiklaim ? Colors.grey.shade400 : misi.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(misi.judul,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isDiklaim ? kTextSoft : kText)),
                    const SizedBox(height: 2),
                    Text(misi.deskripsi,
                        style: const TextStyle(fontSize: 11, color: kTextSoft),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _statusBadge(misi),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: misi.progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                            isDiklaim ? Colors.grey.shade400 : misi.color),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${misi.progressJumlah}/${misi.targetJumlah} selesai',
                        style: TextStyle(
                            fontSize: 11,
                            color: isDiklaimed ? kTextSoft : misi.color,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Reward chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDiklaim ? Colors.grey.shade100 : kPrimaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.monetization_on_rounded,
                        size: 13, color: isDiklaim ? Colors.grey.shade400 : kPrimary),
                    const SizedBox(width: 3),
                    Text('+${misi.koinReward}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDiklaim ? Colors.grey.shade400 : kPrimary)),
                  ],
                ),
              ),
            ],
          ),

          if (isSelesai) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _klaimMisi(misi),
                icon: const Icon(Icons.card_giftcard_rounded, size: 16),
                label: const Text('Klaim Koin',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: misi.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool get isDiklaimed => false;

  Widget _statusBadge(MisiItem misi) {
    switch (misi.status) {
      case MisiStatus.diklaim:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
          child: const Text('Diklaim',
              style: TextStyle(fontSize: 10, color: kTextSoft, fontWeight: FontWeight.w600)),
        );
      case MisiStatus.selesai:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration:
              BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(20)),
          child: const Text('Selesai!',
              style: TextStyle(fontSize: 10, color: kPrimary, fontWeight: FontWeight.w700)),
        );
      case MisiStatus.belum:
        return const SizedBox.shrink();
    }
  }
}