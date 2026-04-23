import 'package:flutter/material.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────
enum NotifType { setor, koin, misi, info, promo }

class NotifItem {
  final String id;
  final NotifType type;
  final String judul;
  final String pesan;
  final String waktu;
  bool sudahDibaca;

  NotifItem({
    required this.id,
    required this.type,
    required this.judul,
    required this.pesan,
    required this.waktu,
    this.sudahDibaca = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final List<NotifItem> _notifs = [
    NotifItem(
      id: 'n1',
      type: NotifType.setor,
      judul: 'Setor Sampah Dikonfirmasi',
      pesan: 'Penyetoran plastik 2.3 kg kamu telah diverifikasi oleh petugas. Koin dan saldo sudah masuk.',
      waktu: '2 menit lalu',
      sudahDibaca: false,
    ),
    NotifItem(
      id: 'n2',
      type: NotifType.koin,
      judul: 'Koin Berhasil Ditukar',
      pesan: 'Penukaran 100 koin menjadi Rp 9.500 telah berhasil. Saldo kamu telah diperbarui.',
      waktu: '1 jam lalu',
      sudahDibaca: false,
    ),
    NotifItem(
      id: 'n3',
      type: NotifType.misi,
      judul: 'Misi Baru Tersedia!',
      pesan: 'Misi "Setor 5 kg Plastik Minggu Ini" sudah tersedia. Selesaikan dan dapatkan 50 koin bonus!',
      waktu: '3 jam lalu',
      sudahDibaca: false,
    ),
    NotifItem(
      id: 'n4',
      type: NotifType.promo,
      judul: 'Promo Koin 2x Lipat!',
      pesan: 'Setor sampah kertas hari ini dan dapatkan koin 2x lipat. Promo berlaku s/d pukul 18.00.',
      waktu: 'Kemarin',
      sudahDibaca: true,
    ),
    NotifItem(
      id: 'n5',
      type: NotifType.info,
      judul: 'Jadwal Bank Sampah Berubah',
      pesan: 'Bank Sampah Berseri akan tutup pada Sabtu, 26 April 2025 karena hari libur nasional.',
      waktu: 'Kemarin',
      sudahDibaca: true,
    ),
    NotifItem(
      id: 'n6',
      type: NotifType.misi,
      judul: 'Misi Selesai!',
      pesan: 'Selamat! Kamu berhasil menyelesaikan misi "Laporan Harian 7 Hari Berturut-turut". +30 koin.',
      waktu: '2 hari lalu',
      sudahDibaca: true,
    ),
    NotifItem(
      id: 'n7',
      type: NotifType.setor,
      judul: 'Permintaan Setor Diterima',
      pesan: 'Permintaan setor sampah logam kamu telah diterima. Petugas akan datang dalam 1-2 jam.',
      waktu: '3 hari lalu',
      sudahDibaca: true,
    ),
  ];

  int get _belumDibaca => _notifs.where((n) => !n.sudahDibaca).length;

  void _bacaSemua() {
    setState(() {
      for (final n in _notifs) { n.sudahDibaca = true; }
    });
  }

  void _bacaNotif(NotifItem notif) {
    setState(() => notif.sudahDibaca = true);
  }

  void _hapusNotif(NotifItem notif) {
    setState(() => _notifs.remove(notif));
  }

  IconData _getIcon(NotifType type) {
    switch (type) {
      case NotifType.setor: return Icons.recycling_rounded;
      case NotifType.koin: return Icons.monetization_on_rounded;
      case NotifType.misi: return Icons.emoji_events_rounded;
      case NotifType.info: return Icons.info_outline_rounded;
      case NotifType.promo: return Icons.local_offer_rounded;
    }
  }

  Color _getColor(NotifType type) {
    switch (type) {
      case NotifType.setor: return kPrimary;
      case NotifType.koin: return kWarning;
      case NotifType.misi: return const Color(0xFF8B5CF6);
      case NotifType.info: return kInfo;
      case NotifType.promo: return kDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final belumDibaca = _notifs.where((n) => !n.sudahDibaca).toList();
    final sudahDibaca = _notifs.where((n) => n.sudahDibaca).toList();

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
        title: Row(
          children: [
            const Text('Notifikasi',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kText)),
            if (_belumDibaca > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: kDanger, borderRadius: BorderRadius.circular(20)),
                child: Text('$_belumDibaca baru',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
        actions: [
          if (_belumDibaca > 0)
            TextButton(
              onPressed: _bacaSemua,
              child: const Text('Baca Semua',
                  style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: _notifs.isEmpty
          ? _buildEmpty()
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (belumDibaca.isNotEmpty) ...[
                  _buildSectionHeader('Baru'),
                  ...belumDibaca.map((n) => _buildNotifCard(n)),
                ],
                if (sudahDibaca.isNotEmpty) ...[
                  _buildSectionHeader('Sebelumnya'),
                  ...sudahDibaca.map((n) => _buildNotifCard(n)),
                ],
                const SizedBox(height: 80),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kTextSoft)),
    );
  }

  Widget _buildNotifCard(NotifItem notif) {
    final color = _getColor(notif.type);
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _hapusNotif(notif),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: kDanger,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: () => _bacaNotif(notif),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notif.sudahDibaca ? Colors.white : color.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: notif.sudahDibaca
                ? null
                : Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(_getIcon(notif.type), color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(notif.judul,
                              style: TextStyle(
                                  fontWeight: notif.sudahDibaca ? FontWeight.w600 : FontWeight.w700,
                                  fontSize: 13,
                                  color: kText)),
                        ),
                        if (!notif.sudahDibaca)
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notif.pesan,
                        style: const TextStyle(fontSize: 12, color: kTextSoft, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(notif.waktu,
                        style: TextStyle(
                            fontSize: 11,
                            color: notif.sudahDibaca ? kTextSoft : color,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_off_outlined, color: kPrimary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Tidak ada notifikasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 6),
          const Text('Semua notifikasi kamu akan muncul di sini',
              style: TextStyle(fontSize: 13, color: kTextSoft)),
        ],
      ),
    );
  }
}