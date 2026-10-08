import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'edukasi_screen.dart';
import 'profil_screen.dart';
import 'notifikasi_screen.dart';
import 'aktivitas_screen.dart';
import 'prd_screens.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 0;
  bool _loading = true;
  bool _showBalance = true;
  String? _loadError;
  String _name = 'Nasabah';
  int? _available;
  int _held = 0;
  Map<String, dynamic> _location = {};
  List<Map<String, dynamic>> _recent = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted)
      setState(() {
        _loading = true;
        _loadError = null;
      });
    final results = await Future.wait([
      ApiService().getMe(),
      ApiService().getSaldoV1(),
      ApiService().getLokasi(),
      ApiService().getRiwayatV1(),
    ]);
    final me = results[0];
    final saldo = results[1];
    final loc = results[2];
    final history = results[3];
    if (me['success'] == true && me['data'] is Map) {
      final data = Map<String, dynamic>.from(me['data'] as Map);
      _name = (data['nama'] ?? 'Nasabah').toString();
    }
    if (saldo['success'] == true && saldo['data'] is Map) {
      final data = Map<String, dynamic>.from(saldo['data'] as Map);
      final available =
          data['tersedia'] ?? data['saldo_tersedia'] ?? data['saldo'];
      final held = data['ditahan'] ?? data['saldo_ditahan'] ?? 0;
      _available = _intValue(available);
      _held = _intValue(held);
    }
    if (loc['success'] == true && loc['data'] is Map) {
      _location = Map<String, dynamic>.from(loc['data'] as Map);
    }
    final raw = history['data'];
    final rows = raw is Map ? (raw['data'] ?? raw['items']) : raw;
    if (history['success'] == true && rows is List) {
      _recent = rows
          .whereType<Map>()
          .take(3)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    final errors = results
        .where((e) => e['success'] != true)
        .map((e) => e['message']?.toString())
        .whereType<String>()
        .toList();
    if (_available == null && errors.isNotEmpty) _loadError = errors.first;
    if (mounted)
      setState(() {
        _loading = false;
      });
  }

  int _intValue(dynamic value) {
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Widget _page() {
    switch (_index) {
      case 1:
        return const PriceScreen();
      case 2:
        return const QrNasabahScreen();
      case 3:
        return EdukasiScreen(onBack: () => setState(() => _index = 0));
      case 4:
        return ProfilScreen(onUpdate: _load);
      default:
        return _home();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: _page(),
    floatingActionButton: _index == 0
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()),
            ),
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text('Tanya asisten'),
          )
        : null,
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      backgroundColor: Colors.white,
      indicatorColor: kPrimaryLight,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Icon(Icons.sell_outlined),
          selectedIcon: Icon(Icons.sell_rounded),
          label: 'Harga',
        ),
        NavigationDestination(icon: Icon(Icons.qr_code_2_rounded), label: 'QR'),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book_rounded),
          label: 'Edukasi',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
    ),
  );

  Widget _home() => SafeArea(
    child: RefreshIndicator(
      onRefresh: _load,
      color: kPrimary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: kPrimaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.eco_rounded, color: kPrimary),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SETOR.IN  ·  RUMAH HIJAU',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w800,
                            color: kPrimary,
                          ),
                        ),
                        Text(
                          'Halo, $_name',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: kText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotifikasiScreen(),
                      ),
                    ),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: kText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
            sliver: SliverToBoxAdapter(child: _balanceCard()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            sliver: const SliverToBoxAdapter(
              child: Text(
                'Akses cepat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverToBoxAdapter(child: _quickActions()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            sliver: const SliverToBoxAdapter(
              child: Text(
                'Rumah Hijau',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverToBoxAdapter(child: _locationCard()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Setoran terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kText,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AktivitasScreen(),
                      ),
                    ),
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
            sliver: SliverToBoxAdapter(child: _recentCard()),
          ),
        ],
      ),
    ),
  );

  Widget _balanceCard() => Container(
    padding: const EdgeInsets.all(21),
    decoration: BoxDecoration(
      color: const Color(0xFF174B35),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF174B35).withValues(alpha: .16),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Saldo tersedia',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _showBalance = !_showBalance),
              icon: Icon(
                _showBalance
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          _loading
              ? 'Memuat saldo…'
              : _available == null
              ? '—'
              : _showBalance
              ? rupiah(_available)
              : 'Rp••••••',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
        ),
        if (_held > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Ditahan ${_showBalance ? rupiah(_held) : 'Rp••••••'}',
              style: const TextStyle(color: Color(0xFFD7E9D9), fontSize: 12),
            ),
          ),
        if (_loadError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white70, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _loadError!,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExchangeScreen()),
                ).then((_) => _load()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('Tukar saldo'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AktivitasScreen()),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Riwayat'),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _quickActions() => Row(
    children: [
      Expanded(
        child: _action(
          Icons.qr_code_2_rounded,
          'Tampilkan QR',
          'Untuk petugas',
          () => setState(() => _index = 2),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _action(
          Icons.sell_outlined,
          'Cek harga',
          'Harga per kg',
          () => setState(() => _index = 1),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _action(
          Icons.quiz_outlined,
          'FAQ',
          'Bantuan cepat',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FaqScreen()),
          ),
        ),
      ),
    ],
  );

  Widget _action(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.fromLTRB(12, 15, 8, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: kPrimaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kPrimary, size: 21),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: kTextSoft),
          ),
        ],
      ),
    ),
  );

  Widget _locationCard() {
    final isOpen = _location['status_buka'] == true;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LocationScreen()),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7ECE7)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_outlined, color: kPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rumah Hijau',
                    style: TextStyle(fontWeight: FontWeight.w700, color: kText),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _location['alamat']?.toString() ??
                        'Lihat alamat dan jadwal setor',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: kTextSoft),
                  ),
                ],
              ),
            ),
            if (_location.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: isOpen ? kPrimaryLight : const Color(0xFFF1F2F1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOpen ? 'BUKA' : 'TUTUP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isOpen ? kPrimary : kTextSoft,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right_rounded, color: kTextSoft),
          ],
        ),
      ),
    );
  }

  Widget _recentCard() {
    if (_loading && _recent.isEmpty)
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator(color: kPrimary)),
      );
    if (_recent.isEmpty)
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Icon(Icons.inbox_outlined, color: kTextSoft, size: 30),
            SizedBox(height: 8),
            Text(
              'Belum ada setoran',
              style: TextStyle(fontWeight: FontWeight.w700, color: kText),
            ),
            SizedBox(height: 4),
            Text(
              'Setoran yang sudah diverifikasi akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: kTextSoft),
            ),
          ],
        ),
      );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECE7)),
      ),
      child: Column(
        children: _recent.asMap().entries.map((entry) {
          final item = entry.value;
          final status = (item['status'] ?? 'MENUNGGU_VERIFIKASI').toString();
          final title = (item['kode'] ?? item['id'] ?? 'Setoran').toString();
          final date = (item['created_at'] ?? item['tanggal'] ?? '')
              .toString()
              .split('T')
              .first;
          return Column(
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: kPrimaryLight,
                  child: Icon(Icons.recycling_rounded, color: kPrimary),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  date.isEmpty ? 'Tanggal belum tersedia' : date,
                  style: const TextStyle(fontSize: 11, color: kTextSoft),
                ),
                trailing: Text(
                  status.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: status == 'SELESAI'
                        ? kPrimary
                        : const Color(0xFFAA7612),
                  ),
                ),
              ),
              if (entry.key < _recent.length - 1)
                const Divider(height: 1, indent: 64),
            ],
          );
        }).toList(),
      ),
    );
  }
}
