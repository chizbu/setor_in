import 'package:flutter/material.dart';
import 'edit_profil_screen.dart';
 
const Color kPrimary = Color(0xFF26D077);
const Color kPrimaryDark = Color(0xFF1BAF60);
 
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});
 
  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}
 
class _ProfilScreenState extends State<ProfilScreen> {
  String _nama = 'User';
  String _email = 'User@gmail.com';
  String _noTelpon = '088888888888';
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── AppBar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1.5),
                      ),
                      child: const Icon(Icons.chevron_left,
                          size: 24, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Profil',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
 
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 28),
 
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Avatar ──
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: Colors.grey.shade200,
                          child: Icon(Icons.person,
                              size: 56, color: Colors.grey.shade400),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilScreen(
                                  nama: _nama,
                                  email: _email,
                                  noTelpon: _noTelpon,
                                ),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                _nama = result['nama'];
                                _email = result['email'];
                                _noTelpon = result['noTelpon'];
                              });
                            }
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: kPrimary,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
 
                    const SizedBox(height: 14),
 
                    // Nama
                    Text(
                      _nama,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                    ),
 
                    const SizedBox(height: 4),
 
                    // Email
                    Text(
                      _email,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    ),
 
                    const SizedBox(height: 32),
 
                    // ── Personal Info ──
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Personal Info',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87),
                      ),
                    ),
 
                    const SizedBox(height: 16),
 
                    // Nomor Telpon
                    _buildInfoItem(
                      icon: Icons.location_on_outlined,
                      title: 'Nomor Telpon',
                      subtitle: _noTelpon,
                    ),
 
                    const Divider(height: 1, color: Colors.black12),
 
                    // Notifikasi
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifikasi',
                      onTap: () {},
                    ),
 
                    const Divider(height: 1, color: Colors.black12),
 
                    // Bantuan
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      label: 'Bantuan',
                      onTap: () {},
                    ),
 
                    const Divider(height: 1, color: Colors.black12),
 
                    const SizedBox(height: 36),
 
                    // ── Keluar ──
                    GestureDetector(
                      onTap: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Keluar',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.red,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
 
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 26),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
 
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 26),
            const SizedBox(width: 16),
            Text(label,
                style:
                    const TextStyle(fontSize: 15, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}