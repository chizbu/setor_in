import 'package:flutter/material.dart';
import 'edit_profil_screen.dart';
import 'user_data.dart';

const Color kPrimary = Color(0xFF26D077);
const Color kPrimaryDark = Color(0xFF1BAF60);

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  // ✅ Pakai singleton UserData
  final UserData _userData = UserData();

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
                        border: Border.all(
                            color: Colors.grey.shade300, width: 1.5),
                      ),
                      child: const Icon(Icons.chevron_left,
                          size: 24, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Profil',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87)),
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
                          backgroundImage: _userData.fotoProfil != null
                              ? FileImage(_userData.fotoProfil!)
                              : null,
                          child: _userData.fotoProfil == null
                              ? Icon(Icons.person,
                                  size: 56, color: Colors.grey.shade400)
                              : null,
                        ),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProfilScreen(userData: _userData),
                              ),
                            );
                            setState(() {});
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

                    Text(_userData.nama,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),

                    const SizedBox(height: 4),

                    Text(_userData.email,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade500)),

                    const SizedBox(height: 32),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Personal Info',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                    ),

                    const SizedBox(height: 16),

                    _buildInfoItem(
                      icon: Icons.location_on_outlined,
                      title: 'Nomor Telpon',
                      subtitle: _userData.noTelpon,
                    ),

                    const Divider(height: 1, color: Colors.black12),

                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifikasi',
                      onTap: () {},
                    ),

                    const Divider(height: 1, color: Colors.black12),

                    _buildMenuItem(
                      icon: Icons.help_outline,
                      label: 'Bantuan',
                      onTap: () {},
                    ),

                    const Divider(height: 1, color: Colors.black12),

                    const SizedBox(height: 36),

                    GestureDetector(
                      onTap: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Keluar',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600)),
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
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade500)),
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