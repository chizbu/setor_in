import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../../services/api_service.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool _isLoading = true;
  List<_NotifItem> _notifications = [];
  String _activeFilter = 'semua';
  String _activeTab = 'belum';
  int? _confirmingTransaksiId;

  @override
  void initState() {
    super.initState();
    _loadNotifikasi();
  }

  Future<void> _loadNotifikasi() async {
    setState(() => _isLoading = true);
    final res = await ApiService().getNotifikasi();

    if (res['success'] == true && res['data'] != null) {
      final rawData = res['data'];
      // API returns paginated data with 'data' key inside
      final List items = rawData is Map ? (rawData['data'] ?? []) : (rawData is List ? rawData : []);
      
      _notifications = items.map((n) {
        final createdAt = n['created_at'] ?? '';
        final tipe = n['tipe']?.toString() ?? '';
        final idTransaksi = n['id_transaksi'];
        final perluKonfirmasi = n['memerlukan_konfirmasi'] == true ||
            n['memerlukan_konfirmasi'] == 1;

        return _NotifItem(
          id: n['id'] ?? 0,
          unread: (n['status_notifikasi'] ?? '') == 'belum_dibaca',
          cat: _categorizeByCat(n['judul'] ?? '', tipe: tipe),
          iconData: _iconForCat(_categorizeByCat(n['judul'] ?? '', tipe: tipe)),
          iconColor: _colorForCat(_categorizeByCat(n['judul'] ?? '', tipe: tipe)),
          title: n['judul'] ?? '',
          desc: n['pesan'] ?? '',
          time: _formatTime(createdAt),
          badgeLabel: _badgeLabelForCat(_categorizeByCat(n['judul'] ?? '', tipe: tipe)),
          badgeColor: _colorForCat(_categorizeByCat(n['judul'] ?? '', tipe: tipe)),
          group: _groupForTime(createdAt),
          idTransaksi: idTransaksi is int
              ? idTransaksi
              : int.tryParse(idTransaksi?.toString() ?? ''),
          memerlukanKonfirmasi: perluKonfirmasi && idTransaksi != null,
        );
      }).toList();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ── Helper: Kategorisasi otomatis dari judul notifikasi ──
  String _categorizeByCat(String judul, {String tipe = ''}) {
    if (tipe == 'transaksi') return 'setor';
    final lower = judul.toLowerCase();
    if (lower.contains('setor') || lower.contains('sampah')) return 'setor';
    if (lower.contains('koin') || lower.contains('saldo') || lower.contains('tukar')) return 'koin';
    if (lower.contains('misi') || lower.contains('hadiah') || lower.contains('reward')) return 'info';
    if (lower.contains('promo') || lower.contains('bonus')) return 'promo';
    return 'info';
  }

  IconData _iconForCat(String cat) {
    switch (cat) {
      case 'setor': return Icons.recycling_rounded;
      case 'koin': return Icons.monetization_on_outlined;
      case 'promo': return Icons.local_offer_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  Color _colorForCat(String cat) {
    switch (cat) {
      case 'setor': return kPrimary;
      case 'koin': return kWarning;
      case 'promo': return kDanger;
      default: return kInfo;
    }
  }

  String _badgeLabelForCat(String cat) {
    switch (cat) {
      case 'setor': return 'Setor';
      case 'koin': return 'Koin';
      case 'promo': return 'Promo';
      default: return 'Info';
    }
  }

  String _formatTime(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _groupForTime(String dateStr) {
    if (dateStr.isEmpty) return 'lalu';
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dtDay = DateTime(dt.year, dt.month, dt.day);
      if (dtDay == today) return 'hari-ini';
      if (dtDay == yesterday) return 'kemarin';
      return 'lalu';
    } catch (_) {
      return 'lalu';
    }
  }

  List<_NotifItem> get _filtered {
    var items = _notifications.where((n) {
      final matchCat = _activeFilter == 'semua' || n.cat == _activeFilter;
      final matchTab = _activeTab == 'semua' || n.unread || n.memerlukanKonfirmasi;
      return matchCat && matchTab;
    }).toList();
    return items;
  }

  int get _unreadCount =>
      _notifications.where((n) => n.unread || n.memerlukanKonfirmasi).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.unread = false;
      }
    });
  }

  void _readItem(int id) {
    setState(() {
      final n = _notifications.firstWhere((x) => x.id == id);
      if (!n.memerlukanKonfirmasi) {
        n.unread = false;
      }
    });
  }

  Future<void> _konfirmasiSetoran(_NotifItem item) async {
    final idTransaksi = item.idTransaksi;
    if (idTransaksi == null) return;

    setState(() => _confirmingTransaksiId = idTransaksi);

    final res = await ApiService().konfirmasiTransaksi(idTransaksi);

    if (!mounted) return;

    setState(() => _confirmingTransaksiId = null);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Setoran berhasil dikonfirmasi'),
          backgroundColor: kPrimary,
        ),
      );
      await _loadNotifikasi();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Gagal mengonfirmasi'),
          backgroundColor: kDanger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimary))
                : _buildBody(),
          ),
        ],
      ),
    );
  }

    Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black87, width: 2),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: Colors.black87),
              ),
            ),
            const Expanded(
              child: Text(
                'Notifikasi',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87),
              ),
            ),
                if (_unreadCount > 0)
                  GestureDetector(
                    onTap: _markAllRead,
                    child: const Text(
                      'Tandai semua dibaca',
                      style: TextStyle(
                        color: kPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 38),
              ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7F5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildFilterChips(),
          _buildTabs(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'semua', 'label': 'Semua'},
      {'key': 'setor', 'label': 'Setor'},
      {'key': 'koin', 'label': 'Koin & Saldo'},
      {'key': 'info', 'label': 'Info'},
      {'key': 'promo', 'label': 'Promo'},
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          final isActive = _activeFilter == f['key'];
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = f['key']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? kPrimary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? kPrimary : const Color(0xFFDDDDDD),
                  width: 0.5,
                ),
              ),
              child: Text(
                f['label']!,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.white : kTextSoft,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildTabButton(
              label: 'Belum dibaca',
              tab: 'belum',
              badge: _unreadCount,
            ),
            _buildTabButton(
              label: 'Semua',
              tab: 'semua',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required String tab,
    int? badge,
  }) {
    final isActive = _activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: isActive
                ? Border.all(color: const Color(0xFFDDDDDD), width: 0.5)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? kPrimary : kTextSoft,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (badge != null && badge > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 48, color: kTextSoft.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              _notifications.isEmpty
                  ? 'Belum ada notifikasi'
                  : _activeTab == 'belum'
                      ? 'Tidak ada notifikasi\nyang belum dibaca'
                      : 'Tidak ada notifikasi',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextSoft, fontSize: 13),
            ),
            if (_notifications.isEmpty) ...[
              const SizedBox(height: 4),
              const Text(
                'Notifikasi akan muncul saat ada\naktivitas di akunmu',
                textAlign: TextAlign.center,
                style: TextStyle(color: kTextSoft, fontSize: 11),
              ),
            ],
          ],
        ),
      );
    }

    final groups = [
      {'key': 'hari-ini', 'label': 'Hari ini'},
      {'key': 'kemarin', 'label': 'Kemarin'},
      {'key': 'lalu', 'label': 'Sebelumnya'},
    ];

    final List<Widget> widgets = [];
    for (final g in groups) {
      final grouped = items.where((n) => n.group == g['key']).toList();
      if (grouped.isEmpty) continue;
      widgets.add(_buildSectionLabel(g['label']!));
      for (int i = 0; i < grouped.length; i++) {
        widgets.add(_buildNotifItem(grouped[i]));
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: widgets,
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: kTextSoft,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotifItem(_NotifItem item) {
    final isConfirming = _confirmingTransaksiId == item.idTransaksi;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.unread || item.memerlukanKonfirmasi
            ? kPrimary.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.memerlukanKonfirmasi
              ? kPrimary.withValues(alpha: 0.35)
              : item.unread
                  ? kPrimary.withValues(alpha: 0.2)
                  : const Color(0xFFEEEEEE),
          width: item.memerlukanKonfirmasi ? 1.2 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => _readItem(item.id),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(item),
                const SizedBox(width: 12),
                Expanded(child: _buildContent(item)),
                if (item.unread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: kPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
          if (item.memerlukanKonfirmasi) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isConfirming ? null : () => _konfirmasiSetoran(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: isConfirming
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Konfirmasi Setoran',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(_NotifItem item) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: item.iconColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(item.iconData, color: item.iconColor, size: 22),
    );
  }

  Widget _buildContent(_NotifItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.desc,
          style: const TextStyle(fontSize: 12, color: kTextSoft, height: 1.5),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              item.time,
              style: const TextStyle(fontSize: 11, color: kTextSoft),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: item.badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.badgeLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: item.badgeColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotifItem {
  final int id;
  bool unread;
  final String cat;
  final IconData iconData;
  final Color iconColor;
  final String title;
  final String desc;
  final String time;
  final String badgeLabel;
  final Color badgeColor;
  final String group;
  final int? idTransaksi;
  final bool memerlukanKonfirmasi;

  _NotifItem({
    required this.id,
    required this.unread,
    required this.cat,
    required this.iconData,
    required this.iconColor,
    required this.title,
    required this.desc,
    required this.time,
    required this.badgeLabel,
    required this.badgeColor,
    required this.group,
    this.idTransaksi,
    this.memerlukanKonfirmasi = false,
  });
}