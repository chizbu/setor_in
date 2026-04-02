import 'package:flutter/material.dart';

const Color kPrimary = Color(0xFF26D077);
const Color kPrimaryDark = Color(0xFF1BAF60);

class EdukasiScreen extends StatefulWidget {
  const EdukasiScreen({super.key});

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen> {
  int _selectedKategori = 0;

  final List<Map<String, dynamic>> _kategori = [
    {'icon': Icons.recycling, 'label': 'Kertas'},
    {'icon': Icons.flag_outlined, 'label': 'Plastik'},
    {'icon': Icons.location_on_outlined, 'label': 'Kaca'},
    {'icon': Icons.location_on_outlined, 'label': 'Logam'},
  ];

  // Placeholder modul
  final List<Map<String, String>> _modul = [
    {'title': 'Cara Memilah Sampah Kertas', 'subtitle': 'Modul 1'},
    {'title': 'Daur Ulang Plastik di Rumah', 'subtitle': 'Modul 2'},
    {'title': 'Mengelola Sampah Kaca', 'subtitle': 'Modul 3'},
  ];

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
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        size: 24,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Edukasi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Kategori Sampah ──
                    const Text(
                      'Kategori sampah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        _kategori.length,
                        (index) => _buildKategoriItem(index),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Modul ──
                    const Text(
                      'Modul',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),

                    ..._modul.map((m) => _buildModulCard(m)).toList(),

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

  Widget _buildKategoriItem(int index) {
    final item = _kategori[index];
    final isSelected = _selectedKategori == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedKategori = index),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected
                  ? kPrimary.withOpacity(0.25)
                  : kPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: kPrimary, width: 1.5)
                  : null,
            ),
            child: Icon(
              item['icon'] as IconData,
              color: kPrimary,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item['label'] as String,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? kPrimary : Colors.black54,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulCard(Map<String, String> modul) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Placeholder konten
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modul['subtitle']!,
                    style: TextStyle(
                      fontSize: 11,
                      color: kPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    modul['title']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}