import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'edukasi_detail_screen.dart';

// ─── Data Kategori ───────────────────────────────────────────────
final List<Map<String, dynamic>> _kategoriList = [
  {'label': 'Kertas',     'icon': Icons.receipt_long_outlined},
  {'label': 'Plastik',    'icon': Icons.water_drop_outlined},
  {'label': 'Kaca',       'icon': Icons.wine_bar_outlined},
  {'label': 'Organik',    'icon': Icons.eco_outlined},
  {'label': 'Logam',      'icon': Icons.hardware_outlined},
  {'label': 'Elektronik', 'icon': Icons.devices_outlined},
];

// ─── Data Modul ──────────────────────────────────────────────────
// Ganti nama file 'assets/images/modul_xxx.jpg' di pubspec.yaml sesuai foto kamu.
final List<Map<String, dynamic>> _modulList = [
  {
    'title': 'Daur Ulang Plastik di Rumah',
    'subtitle': 'Modul 2',
    'kategori': 'Plastik',
    'durasi': '7 menit',
    'tag': 'Pemula',
    'image': 'assets/images/modul_plastik.jpg',
    'color': Color(0xFF0D9146),
    'icon': Icons.water_drop_outlined,
    'definisi':
        'Sampah plastik adalah limbah berbahan polimer sintetis yang sulit terurai secara alami dan membutuhkan penanganan khusus.',
    'contoh': [
      'Botol plastik minuman',
      'Kantong plastik belanja',
      'Kemasan makanan & snack',
      'Sedotan plastik',
      'Ember & gayung bekas',
    ],
    'pengelolaan': [
      'Cuci bersih plastik sebelum dikumpulkan',
      'Pisahkan berdasarkan jenis kode resin',
      'Gepengkan botol untuk hemat ruang',
      'Gunakan kembali jika memungkinkan',
      'Kirim ke bank sampah atau daur ulang',
    ],
  },
  {
    'title': 'Cara Mengelola Sampah Organik dari Rumah',
    'subtitle': 'Modul 4',
    'kategori': 'Organik',
    'durasi': '8 menit',
    'tag': 'Menengah',
    'image': 'assets/images/modul_organik.jpg',
    'color': Color(0xFF059669),
    'icon': Icons.compost_outlined,
    'definisi':
        'Sampah organik adalah limbah yang berasal dari makhluk hidup dan dapat terurai secara alami menjadi kompos yang berguna.',
    'contoh': [
      'Sisa makanan & sayuran',
      'Kulit buah-buahan',
      'Daun kering dan ranting',
      'Ampas kopi dan teh',
      'Kotoran hewan peliharaan',
    ],
    'pengelolaan': [
      'Pisahkan dari sampah anorganik',
      'Buat kompos dengan wadah tertutup',
      'Tambahkan tanah atau daun kering',
      'Aduk rutin setiap 3 hari',
      'Gunakan kompos untuk pupuk tanaman',
    ],
  },
  {
    'title': 'Cara Memilah Sampah Kertas',
    'subtitle': 'Modul 1',
    'kategori': 'Kertas',
    'durasi': '5 menit',
    'tag': 'Pemula',
    'image': 'assets/images/modul_kertas.jpg',
    'color': Color(0xFF3B82F6),
    'icon': Icons.article_outlined,
    'definisi':
        'Sampah kertas adalah limbah yang terbuat dari serat selulosa yang berasal dari kayu, bambu, atau bahan organik lainnya.',
    'contoh': [
      'Koran, majalah, buku bekas',
      'Kardus dan kemasan karton',
      'Kertas tulis, kertas fotokopi',
      'Tissue dan tisu toilet',
      'Karton susu dan jus',
      'Paper bag dan amplop',
    ],
    'pengelolaan': [
      'Pisahkan kertas dari sampah lain',
      'Bersihkan dari makanan atau cairan',
      'Lipat atau sobek menjadi kecil',
      'Simpan di tempat kering',
      'Setorkan ke bank sampah',
    ],
  },
  {
    'title': 'Mengelola Sampah Logam',
    'subtitle': 'Modul 3',
    'kategori': 'Logam',
    'durasi': '6 menit',
    'tag': 'Menengah',
    'image': 'assets/images/modul_logam.jpg',
    'color': Color(0xFFF59E0B),
    'icon': Icons.hardware_outlined,
    'definisi':
        'Sampah logam mencakup berbagai jenis material berbasis besi, aluminium, dan tembaga yang bernilai tinggi untuk didaur ulang.',
    'contoh': [
      'Kaleng minuman aluminium',
      'Kaleng makanan besi',
      'Besi tua dan skrap',
      'Kawat dan kabel tembaga',
      'Peralatan dapur bekas',
    ],
    'pengelolaan': [
      'Bersihkan dari sisa makanan',
      'Pisahkan logam besi dan non-besi',
      'Jangan campur dengan sampah basah',
      'Kumpulkan dalam jumlah banyak',
      'Setor ke bank sampah khusus logam',
    ],
  },
  {
    'title': 'Sampah Elektronik (E-Waste)',
    'subtitle': 'Modul 5',
    'kategori': 'Elektronik',
    'durasi': '10 menit',
    'tag': 'Lanjutan',
    'image': 'assets/images/modul_elektronik.jpg',
    'color': Color(0xFFEF4444),
    'icon': Icons.devices_outlined,
    'definisi':
        'Sampah elektronik adalah perangkat listrik atau elektronik yang sudah tidak digunakan dan mengandung bahan berbahaya.',
    'contoh': [
      'Ponsel dan laptop bekas',
      'Baterai dan charger',
      'TV dan monitor lama',
      'Printer dan keyboard',
      'Kabel dan aksesori elektronik',
    ],
    'pengelolaan': [
      'Jangan buang ke tempat sampah biasa',
      'Hapus data pribadi sebelum dibuang',
      'Bawa ke drop point e-waste resmi',
      'Manfaatkan program tukar tambah',
      'Donasikan jika masih berfungsi',
    ],
  },
];

// ─── Screen ──────────────────────────────────────────────────────
class EdukasiScreen extends StatelessWidget {
  const EdukasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // ── AppBar sederhana (sesuai mockup: back button + "Edukasi") ──
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.black87,
              size: 22,
            ),
          ),
        ),
        title: const Text(
          'Edukasi',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Label "Kategori sampah" ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Kategori sampah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Kategori: horizontal scroll ──
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _kategoriList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final k = _kategoriList[i];
                  return _KategoriCard(
                    label: k['label'] as String,
                    icon: k['icon'] as IconData,
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ── Label "Modul" ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Modul',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Daftar Modul ──
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              itemCount: _modulList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final m = _modulList[i];
                return _ModulCard(
                  data: m,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EdukasiDetailScreen(data: m),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget: Kategori Card ────────────────────────────────────────
class _KategoriCard extends StatelessWidget {
  final String label;
  final IconData icon;

  const _KategoriCard({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0D9146), size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget: Modul Card (foto background + judul di bawah) ────────
class _ModulCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _ModulCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String imagePath = data['image'] as String;
    final Color accentColor = data['color'] as Color;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Foto background ──
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                // Fallback jika foto belum ada
                errorBuilder: (_, __, ___) => Container(
                  color: accentColor.withOpacity(0.15),
                  child: Center(
                    child: Icon(
                      data['icon'] as IconData,
                      color: accentColor,
                      size: 52,
                    ),
                  ),
                ),
              ),

              // ── Gradient gelap dari tengah ke bawah ──
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.65),
                      ],
                      stops: const [0.35, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // ── Judul di bagian bawah (center, seperti mockup) ──
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Text(
                  data['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}