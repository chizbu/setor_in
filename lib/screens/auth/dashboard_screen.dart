import 'dart:io';
import 'package:flutter/material.dart';
import 'edukasi_screen.dart';
import 'profil_screen.dart';
import 'target_sampah_screen.dart';
import 'user_data.dart';

const Color kPrimary = Color(0xFF26D077);
const Color kPrimaryDark = Color(0xFF1BAF60);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _showSaldo = false;
  final double _saldo = 0;
  final int _koin = 0;

  final UserData _userData = UserData();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _userData.load();
    if (mounted) setState(() => _isLoading = false);
  }

  void _onNavTap(int index) async {
    if (index == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const EdukasiScreen()));
      return;
    }
    if (index == 3) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ProfilScreen()));
      if (mounted) setState(() {});
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header hijau ──
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 1),
                                    child: Icon(Icons.recycling,
                                        color: Colors.white, size: 22),
                                  ),
                                ),
                                TextSpan(text: 'R.IN'),
                              ],
                            ),
                          ),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_outlined,
                                color: kPrimary, size: 22),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfilScreen()),
                          );
                          if (mounted) setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    !_isLoading && _userData.fotoProfil != null
                                        ? FileImage(_userData.fotoProfil!)
                                        : null,
                                child: (_isLoading ||
                                        _userData.fotoProfil == null)
                                    ? Icon(Icons.person,
                                        color: kPrimary, size: 20)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isLoading ? 'User' : _userData.nama,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: kPrimaryDark,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Colors.white70,
                                    size: 18),
                                const SizedBox(width: 6),
                                const Text('Saldomu',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => setState(
                                      () => _showSaldo = !_showSaldo),
                                  child: Icon(
                                    _showSaldo
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _showSaldo
                                  ? 'Rp ${_saldo.toStringAsFixed(0)}'
                                  : 'Rp ••••••••',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.monetization_on_outlined,
                                          color: Colors.white70, size: 16),
                                      SizedBox(width: 4),
                                      Text('Koinmu',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('$_koin',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.people_outline,
                                        size: 18, color: Colors.white),
                                    label: const Text('Tukarkan Koin',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Colors.white54),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.history,
                                        size: 18, color: Colors.white),
                                    label: const Text('History',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Colors.white54),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Menu icons ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMenuItem(Icons.recycling, 'Setor\nsampah', () {}),
                    // ✅ Targetkan Sampah → navigasi ke TargetSampahScreen
                    _buildMenuItem(
                      Icons.flag_outlined,
                      'Targetkan\nSampah',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TargetSampahScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                        Icons.location_on_outlined, 'Cek Bank\nSampah', () {}),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Aktivitas',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text('Belum ada aktivitas',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13)),
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // ── Bottom Navbar ──
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: kPrimaryDark,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withValues(alpha: 0.3),
              blurRadius: 20,
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
              _buildNavItem(Icons.monetization_on_outlined, 'Keuangan', 2),
              _buildNavItem(Icons.person_outline, 'Profil', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: kPrimary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
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
            Icon(icon,
                color: isActive ? kPrimary : Colors.white70, size: 22),
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