import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'edukasi_detail_screen.dart';
import 'kategori_detail_screen.dart';
import '../../services/api_service.dart';
import 'ui_components.dart';

final List<Map<String, dynamic>> kategoriSampahList = [
  {
    'label': 'Kertas',
    'icon': Icons.description_outlined,
    'color': Color(0xFF3B82F6),
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
    'label': 'Plastik',
    'icon': Icons.water_drop_outlined,
    'color': Color(0xFF0D9146),
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
    'label': 'Kaca',
    'icon': Icons.wine_bar_outlined,
    'color': Color(0xFF8B5CF6),
    'definisi':
        'Sampah kaca adalah limbah berbahan silika yang dapat didaur ulang hampir 100% tanpa kehilangan kualitas material.',
    'contoh': [
      'Botol kaca minuman',
      'Toples dan wadah kaca',
      'Pecahan kaca jendela',
      'Cermin bekas',
      'Lampu bohlam',
    ],
    'pengelolaan': [
      'Bungkus pecahan kaca dengan koran',
      'Pisahkan berdasarkan warna kaca',
      'Bersihkan dari sisa makanan',
      'Jangan campur dengan keramik',
      'Setor ke pengepul atau bank sampah',
    ],
  },
  {
    'label': 'Organik',
    'icon': Icons.eco_outlined,
    'color': Color(0xFF059669),
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
    'label': 'Logam',
    'icon': Icons.hardware_outlined,
    'color': Color(0xFFF59E0B),
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
    'label': 'Elektronik',
    'icon': Icons.devices_outlined,
    'color': Color(0xFFEF4444),
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
  final VoidCallback? onBack;
  const EdukasiScreen({super.key, this.onBack});

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen> {
  String? _selectedKategori;
  bool _isLoading = true;
  String? _loadError;
  List<Map<String, dynamic>> _modulFromApi = [];

  @override
  void initState() {
    super.initState();
    _loadEdukasi();
  }

  Future<void> _loadEdukasi() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    final res = await ApiService().getEdukasi();

    if (res['success'] == true && res['data'] != null) {
      final rawData = res['data'];
      // API returns paginated data with 'data' key
      final List items = rawData is Map
          ? (rawData['data'] ?? [])
          : (rawData is List ? rawData : []);

      _modulFromApi = items.map((e) {
        return <String, dynamic>{
          'title': e['judul'] ?? '',
          'image': '', // API konten belum punya gambar
          'kategori': e['kategori'] ?? '',
          'durasi': '5 menit',
          'penulis': 'Admin Setor.in',
          'artikel': [
            {
              'heading': e['judul'] ?? '',
              'body': e['isi'] ?? '',
            }
          ],
        };
      }).toList();
    } else {
      _modulFromApi = [];
      _loadError =
          (res['message'] ?? 'Konten edukasi belum dapat dimuat.').toString();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _displayedModul {
    final source = _modulFromApi;

    if (_selectedKategori == null) return source;
    return source.where((m) {
      final kat = (m['kategori'] as String?)?.toLowerCase() ?? '';
      return kat == _selectedKategori!.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back, size: 23.6, color: kText),
        ),
        title: const Text(
          'Edukasi',
          style: TextStyle(
            fontSize: 18.4,
            fontWeight: FontWeight.w800,
            color: kText,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 80),
        children: [
          const Text('RUMAH HIJAU  /  PENGETAHUAN', style: TextStyle(
              color: kPrimary, fontSize: 10, fontWeight: FontWeight.w800,
              letterSpacing: 1.1)),
          const SizedBox(height: 5),
          const Text('Pilih lebih bijak.\nMulai dari yang sederhana.',
              style: TextStyle(color: kText, fontSize: 20.9, height: 1.12,
                  fontWeight: FontWeight.w800, letterSpacing: -.4)),
          const SizedBox(height: 5),
          const Text('Kenali material, siapkan dengan benar, lalu bawa ke Rumah Hijau.',
              style: TextStyle(color: kTextSoft, fontSize: 12.5, height: 1.4)),
          const SizedBox(height: 14),
          const Text('JELAJAHI JENIS SAMPAH', style: TextStyle(
              color: kTextSoft, fontSize: 8.8, fontWeight: FontWeight.w800,
              letterSpacing: .9)),
          const SizedBox(height: 6),
          _buildKategoriRow(),
          const SizedBox(height: 16),
          const Text('Bacaan pilihan', style: TextStyle(
              color: kText, fontSize: 16.1, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(color: kPrimary)),
            )
          else if (_loadError != null)
            AppCard(
              child: Column(children: [
                Text(_loadError!, textAlign: TextAlign.center,
                    style: const TextStyle(color: kTextSoft, fontSize: 12.5)),
                TextButton.icon(onPressed: _loadEdukasi,
                    icon: const Icon(Icons.refresh_rounded, size: 17.7),
                    label: const Text('Coba lagi')),
              ]),
            )
          else if (_displayedModul.isEmpty)
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: Row(children: [
                Container(width: 28, height: 28,
                    decoration: BoxDecoration(color: kPrimaryLight,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.menu_book_outlined,
                        color: kPrimaryDark, size: 17.7)),
                const SizedBox(width: 9),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_selectedKategori != null
                      ? 'Belum ada bacaan untuk $_selectedKategori'
                      : 'Belum ada bacaan',
                      style: const TextStyle(color: kText, fontSize: 11.2,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  const Text('Konten dari pengelola Rumah Hijau akan muncul di sini.',
                      style: TextStyle(color: kTextSoft, fontSize: 10)),
                ])),
              ]),
            )
          else
            ..._displayedModul.map((m) => _ModulCard(modul: m)),
        ],
      ),
    );
  }

  Widget _buildKategoriRow() {
    return SizedBox(
      height: 28,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: kategoriSampahList.length,
        itemBuilder: (context, i) {
          final k = kategoriSampahList[i];
          final color = k['color'] as Color;
          final label = k['label'] as String;
          final isSelected = _selectedKategori == label;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedKategori = isSelected ? null : label;
              });
            },
            onLongPress: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => KategoriDetailScreen(data: k),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? kPrimaryLight : kSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? kPrimary : kBorder),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(k['icon'] as IconData, color: isSelected ? kPrimaryDark : kTextSoft, size: 13),
                const SizedBox(width: 4),
                Text(label, style: TextStyle(fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? kPrimaryDark : kText)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _ModulCard extends StatelessWidget {
  final Map<String, dynamic> modul;
  const _ModulCard({required this.modul});

  @override
  Widget build(BuildContext context) {
    final hasImage = (modul['image'] as String?)?.isNotEmpty == true;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EdukasiDetailScreen(data: modul),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade200,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                Image.asset(
                  modul['image'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackCover(),
                )
              else
                _fallbackCover(),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.68),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
              // Kategori badge
              if ((modul['kategori'] as String?)?.isNotEmpty == true)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      modul['kategori'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Text(
                  modul['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17.2,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackCover() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D9146), Color(0xFF26D077)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.menu_book_rounded,
            size: 56.6, color: Colors.white.withValues(alpha: 0.3)),
      ),
    );
  }
}
