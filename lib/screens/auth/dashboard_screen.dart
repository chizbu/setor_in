import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'activity_screen.dart';
import 'aktivitas_screen.dart';
import 'app_theme.dart';
import 'chatbot_screen.dart';
import 'edukasi_screen.dart';
import 'harga_sampah_screen.dart';
import 'login_screen.dart';
import 'notifikasi_screen.dart';
import 'profil_screen.dart';
import 'rumah_hijau_screen.dart';
import 'setor_sampah_screen.dart';
import 'keuangan_screen.dart';
import 'ui_components.dart';
import 'user_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _showBalance = true;
  bool _loading = true;
  bool _loggingOut = false;
  String? _error;
  String _name = '';
  Uint8List? _profilePhoto;
  double? _available;
  List<Map<String, dynamic>> _recent = [];
  final List<ActivityEntry> _openedPages = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _loading = true);
    final cachedUser = UserData();
    await cachedUser.load();
    if (!mounted) return;
    setState(() {
      _profilePhoto = cachedUser.fotoProfil;
      if (cachedUser.profileNeedsSync && cachedUser.nama.trim().isNotEmpty) {
        _name = cachedUser.nama;
      }
    });
    final result = await ApiService().getDashboardData();
    if (!mounted) return;
    if (result['success'] == true && result['data'] is Map) {
      final data = Map<String, dynamic>.from(result['data'] as Map);
      final user = data['user'] is Map
          ? Map<String, dynamic>.from(data['user'] as Map)
          : <String, dynamic>{};
      if (!cachedUser.profileNeedsSync || cachedUser.nama.trim().isEmpty) {
        _name = (user['nama'] ?? '').toString();
      }
      final finance = data['keuangan'] is Map
          ? Map<String, dynamic>.from(data['keuangan'] as Map)
          : <String, dynamic>{};
      // Only use the dedicated `saldo`/`tersedia` field. Never fall back to
      // Proyek 2's `jumlah_saldo` or coin balance.
      _available = _parseBalance(finance['saldo']);
      final rows = data['aktivitas'];
      _recent = rows is List
          ? rows.whereType<Map>().take(3)
              .map((row) => Map<String, dynamic>.from(row)).toList()
          : [];
      final partial = data['partial_errors'];
      _error = _available == null
          ? 'Saldo Rupiah belum tersedia dari backend. Saldo lama tidak ditampilkan sebagai tabungan Proyek 3.'
          : partial is List && partial.isNotEmpty && _recent.isEmpty
              ? 'Aktivitas terakhir belum dapat dimuat. Tarik layar untuk mencoba lagi.'
              : null;
    } else {
      _name = cachedUser.nama;
      _available = null;
      _recent = [];
      _error = (result['message'] ?? 'Data akun belum dapat dimuat.').toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  void _recordOpen(String title, String subtitle, IconData icon) {
    setState(() {
      _openedPages.insert(0, ActivityEntry(title: title, subtitle: subtitle, icon: icon, when: DateTime.now()));
      if (_openedPages.length > 50) _openedPages.removeLast();
    });
  }

  void _selectTab(int index) {
    const names = ['Membuka Beranda', 'Membuka Keuangan', '', 'Membuka Edukasi', 'Membuka Profil'];
    const details = ['Ringkasan akun nasabah', 'Mengelola saldo dan penarikan', '', 'Membaca edukasi lingkungan', 'Melihat informasi akun'];
    const icons = [Icons.home_outlined, Icons.account_balance_wallet_outlined, Icons.qr_code_2_rounded, Icons.menu_book_outlined, Icons.person_outline_rounded];
    if (index != 2) _recordOpen(names[index], details[index], icons[index]);
    if (index == 2) {
      _recordOpen('Membuka QR nasabah', 'Menampilkan kartu nasabah', Icons.qr_code_2_rounded);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SetorSampahScreen()));
      return;
    }
    setState(() => _currentIndex = index == 3 ? 2 : index == 4 ? 3 : index);
  }

  Future<void> _openActivity() async {
    _recordOpen('Membuka Aktivitas', 'Melihat semua aktivitas akun', Icons.history_rounded);
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => AktivitasScreen(entries: List<ActivityEntry>.unmodifiable(_openedPages)),
    ));
  }

  Future<void> _openTransactionHistory() async {
    _recordOpen('Membuka Riwayat transaksi', 'Melihat rincian setoran', Icons.receipt_long_outlined);
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatTransaksiScreen()));
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    await ApiService().logoutServer();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _openWithdraw() async {
    _recordOpen('Membuka Keuangan', 'Mengelola saldo, top-up, dan tarik tunai', Icons.account_balance_wallet_outlined);
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => KeuanganScreen(onBack: () => Navigator.pop(context)),
    ));
  }

  Future<void> _openChatbot() async {
    _recordOpen('Membuka SetoBot', 'Menggunakan asisten Setor.in', Icons.chat_bubble_outline_rounded);
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        IndexedStack(
          index: _currentIndex,
          children: [
            _homePage(),
            KeuanganScreen(onBack: () => _selectTab(0)),
            EdukasiScreen(onBack: () => _selectTab(0)),
            ProfilScreen(onUpdate: _loadData),
          ],
        ),
        if (_currentIndex == 0)
          Positioned(
            right: 11,
            bottom: 5,
            child: Material(
              color: kBg,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: _openChatbot,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    ClipOval(child: Image.asset('assets/images/setobot-icon.png', width: 26, height: 26, fit: BoxFit.cover)),
                    const SizedBox(height: 1),
                    const Text('SetoBot', style: TextStyle(color: kPrimaryDark, fontSize: AppTypography.caption, fontWeight: FontWeight.w800)),
                  ]),
                ),
              ),
            ),
          ),
      ]),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  Widget _homePage() => SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: kPrimary,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 36),
                children: [
                  _header(),
                  const SizedBox(height: AppSpacing.lg),
                  _balanceCard(),
                  const SizedBox(height: 12),
                  _dashboardShortcuts(),
                  if (_error != null) ...[
                    const SizedBox(height: 9),
                    _errorNotice(_error!),
                  ],
                  const SizedBox(height: 18),
                  _activityHeading(),
                  const SizedBox(height: 6),
                  _activityCard(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _header() {
    final parts = _name.trim().split(RegExp(r'\s+'));
    final firstName = parts.isEmpty || parts.first.isEmpty ? 'nasabah' : parts.first;
    return Row(children: [
      CircleAvatar(
        radius: 13,
        backgroundColor: kPrimaryLight,
        backgroundImage: _profilePhoto == null || _profilePhoto!.isEmpty
            ? null
            : MemoryImage(_profilePhoto!),
        child: _profilePhoto == null || _profilePhoto!.isEmpty
            ? const Icon(Icons.person_outline_rounded, color: kPrimaryDark, size: AppIconSize.md)
            : null,
      ),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('SETOR.IN  /  RUMAH HIJAU', style: TextStyle(color: kTextSoft, fontSize: AppTypography.overline, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
        const SizedBox(height: 1),
        Text('Halo, $firstName', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kText, fontSize: AppTypography.bodyLarge, fontWeight: FontWeight.w800)),
      ])),
      _headerButton(Icons.notifications_none_rounded, 'Notifikasi', () {
        _recordOpen('Membuka Notifikasi', 'Melihat pembaruan akun', Icons.notifications_none_rounded);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiScreen()));
      }),
      const SizedBox(width: 4),
      _headerButton(Icons.logout_rounded, 'Keluar', _logout),
    ]);
  }

  Widget _headerButton(IconData icon, String tooltip, VoidCallback onTap) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: kPrimaryLight.withValues(alpha: .7), borderRadius: BorderRadius.circular(9)),
        child: IconButton(
          tooltip: tooltip,
          onPressed: tooltip == 'Keluar' && _loggingOut ? null : onTap,
          padding: EdgeInsets.zero,
          iconSize: 17.7,
          icon: Icon(icon, color: kText),
        ),
      );

  Widget _balanceCard() => Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: kPrimaryDark, borderRadius: BorderRadius.circular(15)),
        child: Stack(children: [
          Positioned(
            right: -5,
            bottom: -19,
            width: 112,
            height: 100,
            child: Opacity(opacity: .78, child: Image.asset('assets/images/setor_story_illustration.webp', fit: BoxFit.contain, alignment: Alignment.bottomRight)),
          ),
          Positioned(
            top: -32,
            right: -25,
            child: Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: .08)))),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
            child: LayoutBuilder(builder: (context, constraints) => SizedBox(
              width: constraints.maxWidth * .66,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('TABUNGAN NASABAH', style: TextStyle(color: Color(0xFFDDE5C9), fontSize: AppTypography.overline, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
              const SizedBox(height: 8),
              Row(children: [
                const Expanded(child: Text('Saldo tersedia', style: TextStyle(color: Color(0xFFDDE5C9), fontSize: AppTypography.caption, fontWeight: FontWeight.w600))),
                IconButton(
                  tooltip: _showBalance ? 'Sembunyikan saldo' : 'Tampilkan saldo',
                  onPressed: () => setState(() => _showBalance = !_showBalance),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 22, height: 22),
                  icon: Icon(_showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: AppIconSize.sm, color: Colors.white),
                ),
              ]),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: Text(
                  key: ValueKey('$_available-$_showBalance-$_loading'),
                  _loading
                      ? 'Memuat…'
                      : _showBalance
                          ? 'Rp${_formatRupiah(_available ?? 0)}'
                          : 'Rp••••••',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: AppTypography.title, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -.4),
                ),
              ),
              const SizedBox(height: 7),
              Row(children: [
                Expanded(child: _balanceAction(Icons.receipt_long_outlined, 'Riwayat', _openTransactionHistory)),
                const SizedBox(width: 5),
                Expanded(child: _balanceAction(Icons.swap_horiz_rounded, 'Tarik Saldo', _openWithdraw)),
              ]),
              const SizedBox(height: 10),
              const Text('Tabungan hasil setoran terverifikasi', style: TextStyle(color: Color(0xFFE1E5D8), fontSize: AppTypography.overline, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(height: 1, color: Colors.white.withValues(alpha: .16)),
              const SizedBox(height: 4),
              const Row(children: [
                Icon(Icons.eco_outlined, size: 13, color: Color(0xFFDDE5C9)),
                SizedBox(width: 4),
                Text('Nilai baik, dimulai dari rumah', style: TextStyle(color: Color(0xFFDDE5C9), fontSize: AppTypography.overline)),
              ]),
            ]),
            )),
          ),
        ]),
      );

  Widget _balanceAction(IconData icon, String label, VoidCallback onTap) => Material(
        color: Colors.white.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(height: 40, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 3),
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: AppTypography.overline, fontWeight: FontWeight.w700))),
          ])),
        ),
      );

  Widget _dashboardShortcuts() => Row(
        children: [
          Expanded(
            child: _dashboardShortcut(
              icon: Icons.sell_outlined,
              title: 'Harga',
              subtitle: 'Harga sampah terbaru',
              onTap: () {
                _recordOpen('Membuka Harga', 'Melihat harga sampah', Icons.sell_outlined);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HargaSampahScreen()));
              },
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _dashboardShortcut(
              icon: Icons.place_outlined,
              title: 'Lokasi & jadwal',
              subtitle: 'Setor ke Rumah Hijau',
              onTap: () {
                _recordOpen('Membuka Rumah Hijau', 'Melihat lokasi dan jadwal setor', Icons.place_outlined);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RumahHijauScreen()));
              },
            ),
          ),
        ],
      );

  Widget _dashboardShortcut({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => Material(
        color: kSurface,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: kPrimaryDark, size: AppIconSize.md),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kText, fontSize: AppTypography.caption, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kTextSoft, fontSize: AppTypography.overline)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: kPrimaryDark, size: AppIconSize.md),
              ],
            ),
          ),
        ),
      );

  Widget _errorNotice(String message) => Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 5),
        decoration: BoxDecoration(color: const Color(0xFFF4EEDF), borderRadius: BorderRadius.circular(11), border: Border.all(color: const Color(0xFFE5DDC9))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(padding: EdgeInsets.only(top: 1), child: Icon(Icons.info_outline_rounded, color: kWarning, size: AppIconSize.sm)),
            const SizedBox(width: 6),
            Expanded(child: Text(message, style: const TextStyle(color: kTextSoft, fontSize: AppTypography.overline, height: 1.35))),
          ]),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 13),
              label: const Text('Coba lagi', style: TextStyle(fontSize: AppTypography.caption, fontWeight: FontWeight.w800)),
              style: TextButton.styleFrom(
                foregroundColor: kPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ]),
      );

  Widget _activityHeading() => Row(children: [
        const Expanded(
          child: Text('Aktivitas terakhir',
              style: TextStyle(color: kText, fontSize: AppTypography.body, fontWeight: FontWeight.w800)),
        ),
        TextButton(
          onPressed: _openActivity,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Lihat semua',
              style: TextStyle(color: kPrimaryDark, fontSize: AppTypography.caption, fontWeight: FontWeight.w700)),
        ),
      ]);

  Widget _activityCard() {
    if (_openedPages.isNotEmpty) {
      final items = _openedPages.take(3).toList();
      return AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        child: Column(children: items.asMap().entries.map((entry) {
          final item = entry.value;
          return Column(children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 30,
              leading: Container(width: 28, height: 28, decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(9)), child: Icon(item.icon, size: AppIconSize.sm, color: kPrimaryDark)),
              title: Text(item.title, style: const TextStyle(color: kText, fontSize: AppTypography.caption, fontWeight: FontWeight.w800)),
              subtitle: Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kTextSoft, fontSize: AppTypography.overline)),
              trailing: Text(_relativeTime(item.when), style: const TextStyle(color: kTextSoft, fontSize: AppTypography.overline)),
            ),
            if (entry.key != items.length - 1) const Divider(height: 1),
          ]);
        }).toList()),
      );
    }
    if (_loading) {
      return const AppCard(child: SizedBox(height: 42, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: kPrimary))));
    }
    if (_recent.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          const Icon(Icons.touch_app_outlined, color: kPrimary, size: AppIconSize.md),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Belum ada aktivitas', style: TextStyle(color: kText, fontSize: AppTypography.caption, fontWeight: FontWeight.w800)),
            SizedBox(height: 2),
            Text('Aktivitas penggunaan aplikasi akan muncul di sini. Transaksi uang ada di menu Riwayat.', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: kTextSoft, fontSize: AppTypography.overline, height: 1.3)),
          ])),
        ]),
      );
    }
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: Column(children: _recent.asMap().entries.map((entry) {
        final row = entry.value;
        return Column(children: [
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            minLeadingWidth: 30,
            leading: Container(width: 28, height: 28, decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.recycling_rounded, size: AppIconSize.sm, color: kPrimaryDark)),
            title: Text((row['title'] ?? 'Setoran').toString(), style: const TextStyle(color: kText, fontSize: AppTypography.caption, fontWeight: FontWeight.w800)),
            subtitle: Text((row['subtitle'] ?? row['status'] ?? 'Rincian belum tersedia').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kTextSoft, fontSize: AppTypography.overline)),
            trailing: Text((row['date'] ?? '').toString(), style: const TextStyle(color: kTextSoft, fontSize: AppTypography.overline)),
            onTap: _openTransactionHistory,
          ),
          if (entry.key != _recent.length - 1) const Divider(height: 1),
        ]);
      }).toList()),
    );
  }


  Widget _bottomNavigation() => SafeArea(
        top: false,
        child: Container(
              height: 64,
          decoration: const BoxDecoration(color: kSurface, border: Border(top: BorderSide(color: kBorder))),
          child: Row(children: [
            _navItem('Beranda', Icons.home_outlined, 0),
            _navItem('Keuangan', Icons.account_balance_wallet_outlined, 1),
            Expanded(child: Center(child: InkResponse(
              onTap: () => _selectTab(2),
              radius: 25,
              child: Container(width: 48, height: 48, decoration: BoxDecoration(color: kPrimaryDark, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: AppIconSize.md)),
            ))),
            _navItem('Edukasi', Icons.menu_book_outlined, 3),
            _navItem('Profil', Icons.person_outline_rounded, 4),
          ]),
        ),
      );

  Widget _navItem(String label, IconData icon, int index) {
    final pageIndex = index == 3 ? 2 : index == 4 ? 3 : index;
    final active = _currentIndex == pageIndex;
    return Expanded(child: Semantics(
      button: true,
      selected: active,
      label: label,
      child: InkWell(
        onTap: () => _selectTab(index),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: AppIconSize.sm, color: active ? kPrimaryDark : kTextSoft),
          const SizedBox(height: 1),
          Text(label, style: TextStyle(color: active ? kPrimaryDark : kTextSoft, fontSize: AppTypography.overline, fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
        ]),
      ),
    ));
  }

  double? _parseBalance(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final raw = value.trim().replaceAll(RegExp(r'[^0-9,.-]'), '');
      if (RegExp(r'^\d{1,3}(\.\d{3})+(,\d+)?$').hasMatch(raw)) {
        return double.tryParse(raw.replaceAll('.', '').replaceAll(',', '.'));
      }
      if (raw.contains(',') && raw.contains('.')) {
        return double.tryParse(raw.replaceAll('.', '').replaceAll(',', '.'));
      }
      return double.tryParse(raw.replaceAll(',', '.'));
    }
    return null;
  }

  String _formatRupiah(double value) => value.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');

  String _relativeTime(DateTime value) {
    final difference = DateTime.now().difference(value);
    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inHours < 1) return '${difference.inMinutes} menit lalu';
    if (difference.inDays < 1) return '${difference.inHours} jam lalu';
    return '${difference.inDays} hari lalu';
  }
}
