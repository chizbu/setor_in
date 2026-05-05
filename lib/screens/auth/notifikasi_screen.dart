import 'package:flutter/material.dart';
import 'app_theme.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  String _activeFilter = 'semua';
  String _activeTab = 'belum';

  final List<_NotifItem> _notifications = [
    _NotifItem(
      id: 1,
      unread: true,
      cat: 'setor',
      iconData: Icons.recycling_rounded,
      iconColor: kPrimary,
      title: 'Setor sampah berhasil!',
      desc: 'Kamu menyetor 2.3 kg plastik. Koin +46 ditambahkan ke akunmu.',
      highlight: ['2.3 kg plastik', '+46'],
      time: '2 menit lalu',
      badgeLabel: 'Setor',
      badgeColor: kPrimary,
      group: 'hari-ini',
    ),
    _NotifItem(
      id: 2,
      unread: true,
      cat: 'koin',
      iconData: Icons.monetization_on_outlined,
      iconColor: kWarning,
      title: 'Penukaran koin sukses',
      desc: '120 koin berhasil ditukar menjadi saldo Rp 6.000.',
      highlight: ['120 koin', 'Rp 6.000'],
      time: '1 jam lalu',
      badgeLabel: 'Koin',
      badgeColor: kWarning,
      group: 'hari-ini',
    ),
    _NotifItem(
      id: 3,
      unread: true,
      cat: 'info',
      iconData: Icons.flag_rounded,
      iconColor: kInfo,
      title: 'Target sampah hampir tercapai',
      desc: 'Kamu sudah mencapai 80% dari target bulan ini. Yuk setor lagi!',
      highlight: ['80%'],
      time: '3 jam lalu',
      badgeLabel: 'Target',
      badgeColor: kInfo,
      group: 'hari-ini',
    ),
    _NotifItem(
      id: 4,
      unread: false,
      cat: 'setor',
      iconData: Icons.recycling_rounded,
      iconColor: kPrimary,
      title: 'Setor kertas berhasil',
      desc: 'Kamu menyetor 1.0 kg kertas. Koin +15 ditambahkan.',
      highlight: ['1.0 kg kertas', '+15'],
      time: 'Kemarin, 10:30',
      badgeLabel: 'Setor',
      badgeColor: kPrimary,
      group: 'kemarin',
    ),
    _NotifItem(
      id: 5,
      unread: false,
      cat: 'promo',
      iconData: Icons.local_offer_rounded,
      iconColor: kDanger,
      title: 'Promo akhir bulan!',
      desc: 'Setor sampah plastik minggu ini dan dapatkan bonus 2x koin. Jangan lewatkan!',
      highlight: ['bonus 2x koin'],
      time: 'Kemarin, 08:00',
      badgeLabel: 'Promo',
      badgeColor: kDanger,
      group: 'kemarin',
    ),
    _NotifItem(
      id: 6,
      unread: false,
      cat: 'info',
      iconData: Icons.location_on_rounded,
      iconColor: const Color(0xFF888780),
      title: 'Bank Sampah terdekat dibuka',
      desc: 'Bank Sampah Maju Jaya buka hari Sabtu–Minggu 08.00–12.00.',
      highlight: [],
      time: '2 hari lalu',
      badgeLabel: 'Info',
      badgeColor: kInfo,
      group: 'lalu',
    ),
  ];

  List<_NotifItem> get _filtered {
    var items = _notifications.where((n) {
      final matchCat = _activeFilter == 'semua' || n.cat == _activeFilter;
      final matchTab = _activeTab == 'semua' || n.unread;
      return matchCat && matchTab;
    }).toList();
    return items;
  }

  int get _unreadCount => _notifications.where((n) => n.unread).length;

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
      n.unread = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: kGradientPrimary,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Notifikasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_unreadCount > 0)
                GestureDetector(
                  onTap: _markAllRead,
                  child: const Text(
                    'Tandai semua dibaca',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
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
              _activeTab == 'belum'
                  ? 'Tidak ada notifikasi\nyang belum dibaca'
                  : 'Tidak ada notifikasi',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextSoft, fontSize: 13),
            ),
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
    return GestureDetector(
      onTap: () => _readItem(item.id),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.unread
              ? kPrimary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.unread
                ? kPrimary.withValues(alpha: 0.2)
                : const Color(0xFFEEEEEE),
            width: 0.5,
          ),
        ),
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
        _buildHighlightedText(item.desc, item.highlight),
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

  Widget _buildHighlightedText(String text, List<String> highlights) {
    if (highlights.isEmpty) {
      return Text(
        text,
        style: const TextStyle(fontSize: 12, color: kTextSoft, height: 1.5),
      );
    }

    final spans = <TextSpan>[];
    String remaining = text;

    while (remaining.isNotEmpty) {
      int earliest = remaining.length;
      String? matched;

      for (final h in highlights) {
        final idx = remaining.indexOf(h);
        if (idx != -1 && idx < earliest) {
          earliest = idx;
          matched = h;
        }
      }

      if (matched == null) {
        spans.add(TextSpan(text: remaining));
        break;
      }

      if (earliest > 0) {
        spans.add(TextSpan(text: remaining.substring(0, earliest)));
      }
      spans.add(TextSpan(
        text: matched,
        style: const TextStyle(
          color: kPrimary,
          fontWeight: FontWeight.w600,
        ),
      ));
      remaining = remaining.substring(earliest + matched.length);
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: kTextSoft, height: 1.5),
        children: spans,
      ),
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
  final List<String> highlight;
  final String time;
  final String badgeLabel;
  final Color badgeColor;
  final String group;

  _NotifItem({
    required this.id,
    required this.unread,
    required this.cat,
    required this.iconData,
    required this.iconColor,
    required this.title,
    required this.desc,
    required this.highlight,
    required this.time,
    required this.badgeLabel,
    required this.badgeColor,
    required this.group,
  });
}