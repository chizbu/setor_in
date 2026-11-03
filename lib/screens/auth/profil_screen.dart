import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'aktivitas_screen.dart';
import 'app_theme.dart';
import 'bantuan_screen.dart';
import 'edit_profil_screen.dart';
import 'login_screen.dart';
import 'notifikasi_screen.dart';
import 'rumah_hijau_screen.dart';
import 'ui_components.dart';
import 'user_data.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key, this.onUpdate});
  final VoidCallback? onUpdate;

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final UserData _userData = UserData();
  bool _loading = true;
  String? _loadError;
  String _nama = '';
  String _email = '';
  String _noTelpon = '';
  String _alamat = '';

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    if (mounted) setState(() => _loading = true);
    await _userData.load();
    if (!mounted) return;
    final result = await ApiService().getProfil();
    if (!mounted) return;
    if (result['success'] == true && result['data'] is Map) {
      final data = Map<String, dynamic>.from(result['data'] as Map);
      if (_userData.profileNeedsSync) {
        _nama = _userData.nama;
        _email = _userData.email;
        _noTelpon = _userData.noTelpon;
        _alamat = _userData.alamat;
        _loadError = 'Perubahan profil tersimpan di perangkat dan menunggu sinkronisasi.';
      } else {
        _nama = (data['nama'] ?? '').toString();
        _email = (data['email'] ?? '').toString();
        _noTelpon = (data['no_telepon'] ?? '').toString();
        _alamat = (data['alamat'] ?? '').toString();
        _userData
          ..nama = _nama
          ..email = _email
          ..noTelpon = _noTelpon
          ..alamat = _alamat;
        await _userData.simpan();
        if (!mounted) return;
        _loadError = null;
      }
    } else {
      await _userData.load();
      if (!mounted) return;
      _nama = _userData.nama;
      _email = _userData.email;
      _noTelpon = _userData.noTelpon;
      _alamat = _userData.alamat;
      _loadError = (result['message'] ?? 'Profil belum dapat diperbarui.').toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _editProfile() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfilScreen(userData: _userData)));
    if (!mounted) return;
    setState(() {
      _nama = _userData.nama;
      _email = _userData.email;
      _noTelpon = _userData.noTelpon;
      _alamat = _userData.alamat;
      _loadError = _userData.profileNeedsSync
          ? 'Perubahan profil tersimpan di perangkat dan menunggu sinkronisasi.'
          : null;
    });
    widget.onUpdate?.call();
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await ApiService().logoutServer();
    if (!mounted) return;
    navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadProfil,
            color: kPrimary,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 82),
                  children: [
                    const Text('AKUN NASABAH', style: TextStyle(color: kPrimary, fontSize: AppTypography.overline, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                    const SizedBox(height: 3),
                    const Text('Profil', style: TextStyle(color: kText, fontSize: AppTypography.subtitle, fontWeight: FontWeight.w800, letterSpacing: -.2)),
                    const SizedBox(height: 11),
                    _profileCard(),
                    if (_loadError != null) ...[
                      const SizedBox(height: 8),
                      InlineNotice(message: _loadError!),
                    ],
                    const SizedBox(height: 15),
                    const SectionHeading('Informasi akun'),
                    const SizedBox(height: 7),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(children: [
                        _infoRow('NAMA LENGKAP', _nama),
                        const Divider(height: 1),
                        _infoRow('EMAIL', _email, footnote: 'Email tidak dapat diubah'),
                        const Divider(height: 1),
                        _infoRow('NOMOR HP', _noTelpon),
                        const Divider(height: 1),
                        _infoRow('ALAMAT', _alamat),
                      ]),
                    ),
                    const SizedBox(height: 15),
                    const SectionHeading('Layanan Setor.in'),
                    const SizedBox(height: 7),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(children: [
                        _menuRow(Icons.receipt_long_outlined, 'Riwayat transaksi', 'Rincian dan status transaksi', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatTransaksiScreen()))),
                        const Divider(height: 1),
                        _menuRow(Icons.place_outlined, 'Rumah Hijau', 'Lokasi dan jadwal mitra', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RumahHijauScreen()))),
                        const Divider(height: 1),
                        _menuRow(Icons.notifications_none_rounded, 'Notifikasi', 'Pembaruan akun dan aktivitas', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiScreen()))),
                        const Divider(height: 1),
                        _menuRow(Icons.help_outline_rounded, 'Panduan & FAQ', 'Cara pilah dan setor sampah', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BantuanScreen()))),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _loading ? null : _logout,
                      icon: const Icon(Icons.logout_rounded, size: AppIconSize.sm),
                      label: const Text('Keluar dari akun', style: TextStyle(fontSize: AppTypography.caption)),
                      style: OutlinedButton.styleFrom(foregroundColor: kDanger, backgroundColor: kSurface, side: const BorderSide(color: Color(0xFFE4D2CD)), minimumSize: const Size.fromHeight(34)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _profileCard() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: kPrimaryDark, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: kBg,
            backgroundImage: _userData.fotoProfil == null ? null : MemoryImage(_userData.fotoProfil!),
            child: _userData.fotoProfil == null ? const Icon(Icons.person_outline_rounded, color: kPrimaryDark, size: AppIconSize.lg) : null,
          ),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ANGGOTA RUMAH HIJAU', style: TextStyle(color: Color(0xFFDDE5C9), fontSize: AppTypography.overline, fontWeight: FontWeight.w800, letterSpacing: .8)),
            const SizedBox(height: 2),
            Text(_loading ? 'Memuat profil…' : _nama.isEmpty ? 'Nasabah' : _nama, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: AppTypography.bodySmall, fontWeight: FontWeight.w800)),
            Text(_email.isEmpty ? 'Email belum tersedia' : _email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFDDE5C9), fontSize: AppTypography.overline)),
          ])),
          const SizedBox(width: 6),
          Material(color: Colors.white.withValues(alpha: .15), shape: const CircleBorder(), child: IconButton(
            tooltip: 'Edit profil',
            onPressed: _loading ? null : _editProfile,
            visualDensity: VisualDensity.compact,
            iconSize: 17.7,
            color: Colors.white,
            icon: const Icon(Icons.edit_outlined),
          )),
        ]),
      );

  Widget _infoRow(String label, String value, {String? footnote}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          width: double.infinity,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, textAlign: TextAlign.left, style: const TextStyle(color: kTextSoft, fontSize: AppTypography.overline, fontWeight: FontWeight.w800, letterSpacing: .7)),
            const SizedBox(height: 2),
            Text(_loading ? 'Memuat…' : value.isEmpty ? 'Belum dilengkapi' : value, textAlign: TextAlign.left, style: const TextStyle(color: kText, fontSize: AppTypography.caption, fontWeight: FontWeight.w600)),
            if (footnote != null) ...[
              const SizedBox(height: 1),
              Text(footnote, textAlign: TextAlign.left, style: const TextStyle(color: kTextSoft, fontSize: AppTypography.overline)),
            ],
          ]),
        ),
      );

  Widget _menuRow(IconData icon, String title, String subtitle, VoidCallback onTap) => ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        minLeadingWidth: 28,
        horizontalTitleGap: 8,
        leading: Container(width: 32, height: 32, decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: kPrimaryDark, size: AppIconSize.sm)),
        title: Text(title, style: const TextStyle(color: kText, fontSize: AppTypography.caption, fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle, style: const TextStyle(color: kTextSoft, fontSize: AppTypography.overline)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: AppIconSize.sm, color: kPrimaryDark),
        onTap: onTap,
      );
}
