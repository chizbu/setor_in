import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'edukasi_detail_screen.dart';

final List<Map<String, dynamic>> _modulList = [
  {
    'title': 'Cara Memilah Sampah Kertas',
    'subtitle': 'Modul 1',
    'kategori': 'Kertas',
    'durasi': '5 menit',
    'icon': Icons.article_outlined,
    'color': Color(0xFF3B82F6),
    'tag': 'Pemula',
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
    'title': 'Daur Ulang Plastik di Rumah',
    'subtitle': 'Modul 2',
    'kategori': 'Plastik',
    'durasi': '7 menit',
    'icon': Icons.water_drop_outlined,
    'color': Color(0xFF0D9146),
    'tag': 'Pemula',
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
    'title': 'Mengelola Sampah Logam',
    'subtitle': 'Modul 3',
    'kategori': 'Logam',
    'durasi': '6 menit',
    'icon': Icons.hardware_outlined,
    'color': Color(0xFFF59E0B),
    'tag': 'Menengah',
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
    'title': 'Pengelolaan Sampah Organik',
    'subtitle': 'Modul 4',
    'kategori': 'Organik',
    'durasi': '8 menit',
    'icon': Icons.compost_outlined,
    'color': Color(0xFF059669),
    'tag': 'Menengah',
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
    'title': 'Sampah Elektronik (E-Waste)',
    'subtitle': 'Modul 5',
    'kategori': 'Elektronik',
    'durasi': '10 menit',
    'icon': Icons.devices_outlined,
    'color': Color(0xFFEF4444),
    'tag': 'Lanjutan',
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

class EdukasiScreen extends StatefulWidget {
  const EdukasiScreen({super.key});

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen> {
  String _filterKategori = 'Semua';

  final List<String> _kategoriList = [
    'Semua', 'Kertas', 'Plastik', 'Logam', 'Organik', 'Elektronik',
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_filterKategori == 'Semua') return _modulList;
    return _modulList.where((m) => m['kategori'] == _filterKategori).toList();
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Pemula': return kPrimary;
      case 'Menengah': return kWarning;
      case 'Lanjutan': return kDanger;
      default: return kPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            expandedHeight: 140,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: kGradientPrimary),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📚 Edukasi Daur Ulang',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(
                          'Pelajari cara mengelola sampah dengan benar',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Row(children: [
                          _statChip(Icons.menu_book_rounded,
                              '${_modulList.length} Modul'),
                          const SizedBox(width: 8),
                          _statChip(Icons.category_outlined, '5 Kategori'),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: _kategoriList.map((k) {
                      final active = _filterKategori == k;
                      return GestureDetector(
                        onTap: () => setState(() => _filterKategori = k),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: active ? kPrimary : kBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: active ? kPrimary : Colors.grey.shade200),
                          ),
                          child: Text(k,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: active ? Colors.white : kTextSoft)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: _filtered.isEmpty
            ? _buildEmpty()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  if (_filterKategori == 'Semua') ...[
                    _buildFeaturedCard(_filtered.first),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Semua Modul',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: kText)),
                        Text('${_filtered.length - 1} lainnya',
                            style: const TextStyle(
                                fontSize: 12, color: kTextSoft)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._filtered.skip(1).map((m) => _buildModulCard(m)),
                  ] else ...[
                    ..._filtered.map((m) => _buildModulCard(m)),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 13),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> m) {
    final color = m['color'] as Color;
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => EdukasiDetailScreen(data: m))),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(m['icon'] as IconData,
                  size: 140, color: Colors.white.withValues(alpha: 0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('⭐ Unggulan',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(m['tag'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
                  const Spacer(),
                  Text(m['subtitle'],
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(m['title'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.access_time_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(m['durasi'],
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Baca →',
                          style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulCard(Map<String, dynamic> m) {
    final color = m['color'] as Color;
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => EdukasiDetailScreen(data: m))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(m['icon'] as IconData, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(m['subtitle'],
                        style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _tagColor(m['tag']).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(m['tag'],
                          style: TextStyle(
                              fontSize: 9,
                              color: _tagColor(m['tag']),
                              fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(m['title'],
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kText)),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.access_time_rounded,
                        size: 12, color: kTextSoft),
                    const SizedBox(width: 3),
                    Text(m['durasi'],
                        style: const TextStyle(
                            fontSize: 11, color: kTextSoft)),
                    const SizedBox(width: 10),
                    const Icon(Icons.category_outlined,
                        size: 12, color: kTextSoft),
                    const SizedBox(width: 3),
                    Text(m['kategori'],
                        style: const TextStyle(
                            fontSize: 11, color: kTextSoft)),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.search_off_rounded,
                color: kPrimary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Modul tidak ditemukan',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 6),
          const Text('Coba pilih kategori lain',
              style: TextStyle(fontSize: 13, color: kTextSoft)),
        ],
      ),
    );
  }
}