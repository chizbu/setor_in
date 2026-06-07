import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'edukasi_detail_screen.dart';
import 'kategori_detail_screen.dart';
import '../../services/api_service.dart';

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

// ── Modul lokal sebagai fallback jika API belum ada konten ──
final List<Map<String, dynamic>> _fallbackModulList = [
  {
    'title': 'Daur Ulang Plastik di Rumah',
    'image': 'assets/images/modul_plastik.png',
    'kategori': 'Plastik',
    'durasi': '7 menit',
    'penulis': 'Tim Setor.in',
    'artikel': [
      {
        'heading': 'Mengapa Plastik Perlu Didaur Ulang?',
        'body':
            'Plastik adalah salah satu material yang paling sulit terurai di alam. Sebuah botol plastik bisa bertahan hingga 450 tahun di lingkungan. Di Indonesia, sekitar 6,8 juta ton sampah plastik dihasilkan setiap tahun, dan sebagian besar berakhir di TPA atau bahkan di lautan.\n\nDaur ulang plastik di rumah bukan sekadar tren — ini adalah langkah nyata yang bisa kita ambil untuk mengurangi dampak lingkungan dari rutinitas harian kita.',
      },
    ],
  },
  {
    'title': 'Cara Mengelola Sampah Organik dari Rumah',
    'image': 'assets/images/modul_organik.png',
    'kategori': 'Organik',
    'durasi': '8 menit',
    'penulis': 'Tim Setor.in',
    'artikel': [
      {
        'heading': 'Sampah Organik: Masalah atau Peluang?',
        'body':
            'Sekitar 60% sampah rumah tangga di Indonesia adalah sampah organik. Jika langsung dibuang ke TPA, sampah organik menghasilkan gas metana yang 25 kali lebih merusak daripada CO₂.\n\nNamun di tangan yang tepat, sampah organik bisa berubah menjadi kompos berkualitas tinggi.',
      },
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
  List<Map<String, dynamic>> _modulFromApi = [];

  @override
  void initState() {
    super.initState();
    _loadEdukasi();
  }

  Future<void> _loadEdukasi() async {
    setState(() => _isLoading = true);
    final res = await ApiService().getEdukasi();

    if (res['success'] == true && res['data'] != null) {
      final rawData = res['data'];
      // API returns paginated data with 'data' key
      final List items = rawData is Map ? (rawData['data'] ?? []) : (rawData is List ? rawData : []);
      
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
    }

    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _displayedModul {
    // Gunakan data dari API jika ada, fallback ke lokal
    final source = _modulFromApi.isNotEmpty ? _modulFromApi : _fallbackModulList;
    
    if (_selectedKategori == null) return source;
    return source.where((m) {
      final kat = (m['kategori'] as String?)?.toLowerCase() ?? '';
      return kat == _selectedKategori!.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black87, width: 2),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Colors.black87,
            ),
          ),
        ),
        title: const Text(
          'Edukasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Kategori sampah',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          _buildKategoriRow(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedKategori != null
                      ? 'Modul — $_selectedKategori'
                      : 'Modul',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                if (_selectedKategori != null)
                  GestureDetector(
                    onTap: () => setState(() => _selectedKategori = null),
                    child: const Text(
                      'Tampilkan semua',
                      style: TextStyle(
                        fontSize: 12,
                        color: kPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: kPrimary)),
            )
          else if (_displayedModul.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.menu_book_outlined,
                        size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      _selectedKategori != null
                          ? 'Belum ada modul untuk kategori $_selectedKategori'
                          : 'Belum ada modul edukasi',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._displayedModul.map((m) => _ModulCard(modul: m)),
        ],
      ),
    );
  }

  Widget _buildKategoriRow() {
    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
              width: 70,
              margin: const EdgeInsets.only(right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.25)
                          : color.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: color, width: 2)
                          : null,
                    ),
                    child: Icon(k['icon'] as IconData, color: color, size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? color : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      modul['kategori'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
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
                    fontSize: 15,
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
            size: 48, color: Colors.white.withValues(alpha: 0.3)),
      ),
    );
  }
}