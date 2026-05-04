import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'edukasi_screen.dart';
import 'profil_screen.dart';
import 'target_sampah_screen.dart';
import 'setor_sampah_screen.dart';
import 'keuangan_screen.dart';
import 'cek_bank_sampah_screen.dart';
import 'tukar_koin_screen.dart';
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
        return EdukasiScreen(
          onBack: () => setState(() => _currentIndex = 0),
        );
      case 2:
        return KeuanganScreen(
          onBack: () => setState(() => _currentIndex = 0),
        );
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
          // Hanya CO₂ Tersimpan, Total Koin dihapus
          _buildStatCard(
            icon: Icons.eco_rounded,
            label: 'CO₂ Tersimpan',
            value: '2.4 kg',
            color: kAccent,
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