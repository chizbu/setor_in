import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'edukasi_screen.dart';
import 'profil_screen.dart';
import 'target_sampah_screen.dart';
import 'setor_sampah_screen.dart';
import 'keuangan_screen.dart';
import 'cek_bank_sampah_screen.dart';
import 'tukar_koin_screen.dart';
import 'transfer_ewallet_screen.dart';
import 'reward_koin_screen.dart';
import 'user_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showSaldo = false;
  final UserData _userData = UserData();
  bool _isLoading = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadData();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _userData.load();
    if (mounted) {
      setState(() => _isLoading = false);
      _animCtrl.forward();
    }
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 1:
        return const EdukasiScreen();
      case 2:
        return const KeuanganScreen();
      case 3:
        return ProfilScreen(onUpdate: () => setState(() {}));
      default:
        return _buildHomeBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeBody() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildQuickMenu(),
              const SizedBox(height: 24),
              _buildStatCards(),
              const SizedBox(height: 24),
              _buildAktivitas(),
              const SizedBox(height: 24),
              _buildTipsCard(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: kGradientPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLogo(),
                _buildNotifButton(),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() => _currentIndex = 3),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      backgroundImage: !_isLoading && _userData.fotoProfil != null
                          ? FileImage(_userData.fotoProfil!)
                          : null,
                      child: (_isLoading || _userData.fotoProfil == null)
                          ? const Icon(Icons.person, color: kPrimary, size: 20)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selamat datang 👋',
                            style: TextStyle(color: Colors.white70, fontSize: 11)),
                        Text(
                          _isLoading ? 'Loading...' : _userData.nama,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSaldoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 1,
        ),
        children: [
          TextSpan(text: 'SET'),
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1),
              child: Icon(Icons.recycling, color: Colors.white, size: 22),
            ),
          ),
          TextSpan(text: 'R.IN'),
        ],
      ),
    );
  }

  Widget _buildNotifButton() {
    return Stack(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.notifications_outlined, color: kPrimary, size: 22),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: kDanger,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaldoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        const Text('Saldo',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _showSaldo = !_showSaldo),
                          child: Icon(
                            _showSaldo
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _showSaldo
                          ? 'Rp ${_userData.saldo.toStringAsFixed(0)}'
                          : 'Rp ••••••',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.monetization_on_outlined,
                            color: Colors.white70, size: 14),
                        SizedBox(width: 4),
                        Text('Koin',
                            style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_userData.koin}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSaldoButton(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Tukarkan Koin',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TukarKoinScreen(
                                koinAwal: _userData.koin,
                                saldoAwal: _userData.saldo,
                              ))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSaldoButton(
                  icon: Icons.history_rounded,
                  label: 'Riwayat',
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSaldoButton(
                  icon: Icons.send_rounded,
                  label: 'Transfer',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const TransferEwalletScreen())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaldoButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMenu() {
    final menus = [
      _MenuItem(Icons.recycling_rounded, 'Setor\nSampah', kPrimary, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SetorSampahScreen()));
      }),
      _MenuItem(Icons.flag_rounded, 'Target\nSampah', kInfo, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TargetSampahScreen()));
      }),
      _MenuItem(Icons.location_on_rounded, 'Cek Bank\nSampah', kWarning, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CekBankSampahScreen()));
      }),
      _MenuItem(Icons.emoji_events_rounded, 'Reward\nKoin',
          const Color(0xFF8B5CF6), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const RewardKoinScreen()));
      }),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Menu Utama',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: menus.map((m) => _buildMenuCard(m)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(_MenuItem m) {
    return GestureDetector(
      onTap: m.onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: m.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(m.icon, color: m.color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(m.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, color: kText, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.recycling_rounded,
                  label: 'Total Setor',
                  value: '${_userData.totalSetor}x',
                  color: kPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.scale_rounded,
                  label: 'Berat Total',
                  value: '${_userData.beratTotal} kg',
                  color: kInfo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.monetization_on_rounded,
                  label: 'Total Koin',
                  value: '${_userData.koin} koin',
                  color: kWarning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.eco_rounded,
                  label: 'CO₂ Tersimpan',
                  value: '2.4 kg',
                  color: kAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: kTextSoft)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAktivitas() {
    final aktivitas = [
      _AktivitasItem('Setor Plastik', '2.3 kg • +46 koin', '12 Apr', kPrimary),
      _AktivitasItem('Setor Kertas', '1.0 kg • +15 koin', '8 Apr', kInfo),
      _AktivitasItem('Setor Logam', '0.8 kg • +32 koin', '1 Apr', kWarning),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Aktivitas Terakhir',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 2),
                child: const Text('Lihat semua',
                    style: TextStyle(
                        fontSize: 12,
                        color: kPrimary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: aktivitas.asMap().entries.map((e) {
                final isLast = e.key == aktivitas.length - 1;
                return _buildAktivitasItem(e.value, isLast);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAktivitasItem(_AktivitasItem item, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.recycling_rounded, color: item.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: kText)),
                    const SizedBox(height: 2),
                    Text(item.subtitle,
                        style: const TextStyle(fontSize: 12, color: kTextSoft)),
                  ],
                ),
              ),
              Text(item.date,
                  style: const TextStyle(fontSize: 11, color: kTextSoft)),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 72, color: Color(0xFFF0F0F0)),
      ],
    );
  }

  Widget _buildTipsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = 1),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D9146), Color(0xFF26D077)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('💡 Tips Daur Ulang',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    SizedBox(height: 6),
                    Text(
                      'Pisahkan sampah organik & anorganik untuk mendapatkan lebih banyak koin!',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(height: 10),
                    Text('Pelajari lebih lanjut →',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: kPrimaryDark,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 'Beranda', 0),
            _buildNavItem(Icons.menu_book_outlined, 'Edukasi', 1),
            _buildNavItem(Icons.account_balance_wallet_outlined, 'Keuangan', 2),
            _buildNavItem(Icons.person_outline, 'Profil', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? kPrimary : Colors.white70, size: 22),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.color, this.onTap);
}

class _AktivitasItem {
  final String title;
  final String subtitle;
  final String date;
  final Color color;
  const _AktivitasItem(this.title, this.subtitle, this.date, this.color);
}

// ═══════════════════════════════════════════════════════════════
//  TRANSFER E-WALLET SCREEN
// ═══════════════════════════════════════════════════════════════

class TransferEwalletScreen extends StatefulWidget {
  const TransferEwalletScreen({super.key});

  @override
  State<TransferEwalletScreen> createState() => _TransferEwalletScreenState();
}

class _TransferEwalletScreenState extends State<TransferEwalletScreen> {
  String? _selectedEwallet;
  final TextEditingController _nomorCtrl = TextEditingController();
  final TextEditingController _nominalCtrl = TextEditingController();
  final double _saldoTersedia = 125000;

  final List<Map<String, dynamic>> _ewallets = [
    {'nama': 'Dana', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFF108EE9)},
    {'nama': 'OVO', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFF4C3494)},
    {'nama': 'GoPay', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFF00AED6)},
    {'nama': 'ShopeePay', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFFEE4D2D)},
  ];

  final List<int> _nominalCepat = [10000, 25000, 50000, 100000];

  String _fmt(int n) => n.toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  int get _nominal => int.tryParse(_nominalCtrl.text.replaceAll('.', '')) ?? 0;

  bool get _canProceed =>
      _selectedEwallet != null &&
      _nomorCtrl.text.length >= 10 &&
      _nominal > 0 &&
      _nominal <= _saldoTersedia;

  @override
  void dispose() {
    _nomorCtrl.dispose();
    _nominalCtrl.dispose();
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
        title: const Text('Transfer Saldo',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kText)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // saldo card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: kGradientPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 20),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Saldo Tersedia', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Text('Rp ${_fmt(_saldoTersedia.toInt())}',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              ]),
            ]),
          ),
          const SizedBox(height: 24),

          // pilih e-wallet
          const Text('Pilih E-Wallet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
          const SizedBox(height: 12),
          Row(children: _ewallets.map((e) {
            final sel = _selectedEwallet == e['nama'];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedEwallet = e['nama']),
                child: Container(
                  margin: EdgeInsets.only(right: e == _ewallets.last ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: sel ? (e['color'] as Color).withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel ? e['color'] as Color : Colors.grey.shade200,
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: Column(children: [
                    Icon(e['icon'] as IconData, color: e['color'] as Color, size: 22),
                    const SizedBox(height: 4),
                    Text(e['nama'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                          color: sel ? e['color'] as Color : kTextSoft,
                        )),
                  ]),
                ),
              ),
            );
          }).toList()),
          const SizedBox(height: 22),

          // nomor tujuan
          const Text('Nomor Tujuan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: TextField(
              controller: _nomorCtrl,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Masukkan nomor ${_selectedEwallet ?? 'e-wallet'}',
                hintStyle: const TextStyle(color: kTextSoft, fontSize: 13),
                prefixIcon: const Icon(Icons.phone_android_rounded, color: kTextSoft, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // nominal
          const Text('Nominal Transfer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: TextField(
              controller: _nominalCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kText),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(fontSize: 20, color: kTextSoft, fontWeight: FontWeight.w400),
                prefixText: 'Rp  ',
                prefixStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kText),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          if (_nominal > _saldoTersedia) ...[
            const SizedBox(height: 6),
            const Text('Saldo tidak mencukupi', style: TextStyle(fontSize: 12, color: kDanger)),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _nominalCepat.map((amt) => GestureDetector(
              onTap: () {
                _nominalCtrl.text = amt.toString();
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kPrimary.withValues(alpha: 0.3)),
                ),
                child: Text('Rp ${_fmt(amt)}',
                    style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _canProceed ? _showKonfirmasi : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Lanjutkan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showKonfirmasi() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Konfirmasi Transfer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              _konfRow('E-Wallet', _selectedEwallet!),
              _konfDiv(),
              _konfRow('Nomor Tujuan', _nomorCtrl.text),
              _konfDiv(),
              _konfRow('Nominal', 'Rp ${_fmt(_nominal)}'),
              _konfDiv(),
              _konfRow('Biaya Admin', 'Gratis', valColor: kPrimary),
              _konfDiv(),
              _konfRow('Total Dipotong', 'Rp ${_fmt(_nominal)}',
                  bold: true, valColor: kDanger),
            ]),
          ),
          const SizedBox(height: 24),

          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showBerhasil();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Transfer', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  void _showBerhasil() {
    final now = DateTime.now();
    const bln = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final tanggal = '${now.day} ${bln[now.month]} ${now.year}, ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      isScrollControlled: true,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: kPrimary, size: 44),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Transfer Berhasil!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kText)),
            const SizedBox(height: 6),
            Text(tanggal, style: const TextStyle(fontSize: 12, color: kTextSoft)),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: kGradientPrimary, borderRadius: BorderRadius.circular(18)),
              child: Column(children: [
                Text('Rp ${_fmt(_nominal)}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Dikirim ke $_selectedEwallet • ${_nomorCtrl.text}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _konfRow(String label, String val, {bool bold = false, Color? valColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 13, color: kTextSoft)),
        const Spacer(),
        Text(val, style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          color: valColor ?? kText,
        )),
      ]),
    );
  }

  Widget _konfDiv() => Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade200);
}

// ═══════════════════════════════════════════════════════════════
//  REWARD KOIN SCREEN
// ═══════════════════════════════════════════════════════════════

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
    {
      'nama': 'Voucher Belanja Rp 10.000',
      'brand': 'Tokopedia',
      'koin': 100,
      'icon': Icons.shopping_bag_outlined,
      'color': Color(0xFF42A94B),
      'kategori': 'Belanja',
      'expired': '31 Des 2025',
    },
    {
      'nama': 'Voucher Makan Rp 15.000',
      'brand': 'GrabFood',
      'koin': 150,
      'icon': Icons.fastfood_outlined,
      'color': Color(0xFF00AED6),
      'kategori': 'Makanan',
      'expired': '30 Nov 2025',
    },
    {
      'nama': 'Pulsa Rp 5.000',
      'brand': 'Semua Operator',
      'koin': 80,
      'icon': Icons.phone_android_outlined,
      'color': Color(0xFF8B5CF6),
      'kategori': 'Pulsa',
      'expired': '31 Des 2025',
    },
    {
      'nama': 'Voucher Belanja Rp 25.000',
      'brand': 'Shopee',
      'koin': 250,
      'icon': Icons.shopping_cart_outlined,
      'color': Color(0xFFEE4D2D),
      'kategori': 'Belanja',
      'expired': '28 Feb 2026',
    },
    {
      'nama': 'Diskon Tagihan Listrik',
      'brand': 'PLN Mobile',
      'koin': 200,
      'icon': Icons.bolt_outlined,
      'color': Color(0xFFF59E0B),
      'kategori': 'Tagihan',
      'expired': '31 Jan 2026',
    },
    {
      'nama': 'Voucher Transportasi',
      'brand': 'Gojek',
      'koin': 120,
      'icon': Icons.directions_bike_outlined,
      'color': Color(0xFF00AED6),
      'kategori': 'Transport',
      'expired': '31 Des 2025',
    },
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
            boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Koin Kamu', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 2),
              Text('$_koinSaya Koin', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              const Text('Tukarkan dengan hadiah menarik!', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ])),
          ]),
        ),

        // tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: TabBar(
            controller: _tabCtrl,
            indicator: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(10)),
            labelColor: Colors.white,
            unselectedLabelColor: kTextSoft,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
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
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // header warna
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: (v['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Center(child: Icon(v['icon'] as IconData, color: v['color'] as Color, size: 36)),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(v['brand'] as String,
                      style: TextStyle(fontSize: 10, color: v['color'] as Color, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(v['nama'] as String,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kText),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: bisa ? const Color(0xFF8B5CF6).withValues(alpha: 0.1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.monetization_on_rounded,
                          size: 12, color: bisa ? const Color(0xFF8B5CF6) : kTextSoft),
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
            decoration: BoxDecoration(color: kPrimary.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_outlined, color: kPrimary, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada penukaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
          const SizedBox(height: 4),
          const Text('Tukar koinmu dengan hadiah menarik!', style: TextStyle(fontSize: 12, color: kTextSoft)),
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.card_giftcard_rounded, color: Color(0xFF8B5CF6), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r['nama'] as String,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
              const SizedBox(height: 3),
              Text(r['tanggal'] as String, style: const TextStyle(fontSize: 11, color: kTextSoft)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${r['koin']} koin',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDanger)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: aktif ? kPrimary.withValues(alpha: 0.1) : Colors.grey.shade100,
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
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),

          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: (v['color'] as Color).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(v['icon'] as IconData, color: v['color'] as Color, size: 40),
          ),
          const SizedBox(height: 14),
          Text(v['brand'] as String,
              style: TextStyle(fontSize: 13, color: v['color'] as Color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(v['nama'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(14)),
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
                Text('Koin kurang ${(v['koin'] as int) - _koinSaya} lagi',
                    style: const TextStyle(fontSize: 12, color: kDanger, fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: bisa ? () { Navigator.pop(context); _showSuksesTukar(v); } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                bisa ? 'Tukar ${v['koin']} Koin' : 'Koin Tidak Cukup',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (_, val, child) => Transform.scale(scale: val, child: child),
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.card_giftcard_rounded, color: Color(0xFF8B5CF6), size: 44),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Penukaran Berhasil!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kText)),
            const SizedBox(height: 8),
            Text('${v['nama']} berhasil ditukar dengan ${v['koin']} koin',
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
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text('Berlaku hingga ${v['expired']}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Lihat Riwayat', style: TextStyle(fontWeight: FontWeight.w600)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
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
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valColor ?? kText)),
      ]),
    );
  }
}