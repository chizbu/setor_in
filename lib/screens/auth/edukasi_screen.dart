import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'edukasi_detail_screen.dart';
import 'kategori_detail_screen.dart';

// ─── DATA KATEGORI SAMPAH ─────────────────────────────────────────────────────
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

// ─── DATA MODUL — cover + artikel lengkap tersendiri ─────────────────────────
// 'artikel' berisi list section: {'heading': '...', 'body': '...'}
// Foto: letakkan di assets/images/ dan daftarkan di pubspec.yaml
// Contoh pubspec.yaml:
//   flutter:
//     assets:
//       - assets/images/modul_plastik.jpg
//       - assets/images/modul_organik.jpg
//       - assets/images/modul_kertas.jpg
//       - assets/images/modul_logam.jpg
//       - assets/images/modul_elektronik.jpg
final List<Map<String, dynamic>> modulList = [
  {
    'title': 'Daur Ulang Plastik di Rumah',
    'image': 'assets/images/modul_plastik.jpg',
    'kategori': 'Plastik',
    'durasi': '7 menit',
    'penulis': 'Tim Setor.in',
    'artikel': [
      {
        'heading': 'Mengapa Plastik Perlu Didaur Ulang?',
        'body':
            'Plastik adalah salah satu material yang paling sulit terurai di alam. Sebuah botol plastik bisa bertahan hingga 450 tahun di lingkungan. Di Indonesia, sekitar 6,8 juta ton sampah plastik dihasilkan setiap tahun, dan sebagian besar berakhir di TPA atau bahkan di lautan.\n\nDaur ulang plastik di rumah bukan sekadar tren — ini adalah langkah nyata yang bisa kita ambil untuk mengurangi dampak lingkungan dari rutinitas harian kita.',
      },
      {
        'heading': 'Mengenal Kode Resin Plastik',
        'body':
            'Sebelum mendaur ulang, penting untuk mengenal 7 jenis kode resin plastik yang tertera di bagian bawah produk:\n\n• Kode 1 (PET) — botol air mineral, mudah didaur ulang\n• Kode 2 (HDPE) — galon, kemasan detergen, bernilai tinggi\n• Kode 4 (LDPE) — kantong plastik, bisa didaur ulang\n• Kode 5 (PP) — sedotan, wadah makanan, bisa didaur ulang\n• Kode 3, 6, 7 — hindari dan jangan campur dengan yang lain\n\nPlastik dengan kode berbeda tidak boleh dicampur karena akan menurunkan kualitas hasil daur ulang.',
      },
      {
        'heading': 'Langkah Daur Ulang di Rumah',
        'body':
            '1. Kumpulkan dan pisahkan — sediakan wadah khusus untuk plastik, jauhkan dari sampah organik.\n\n2. Bersihkan — cuci plastik bekas makanan atau minuman agar tidak berjamur dan berbau.\n\n3. Keringkan — plastik basah akan merusak kualitas bahan daur ulang.\n\n4. Gepengkan atau potong kecil — ini menghemat ruang penyimpanan.\n\n5. Setorkan ke bank sampah atau pengepul — cari jadwal setor rutin setiap minggu.',
      },
      {
        'heading': 'Ide Kreatif Reuse Plastik',
        'body':
            'Sebelum mendaur ulang, coba gunakan kembali (reuse) terlebih dahulu:\n\n• Botol plastik → pot tanaman vertikal\n• Kantong kresek → tempat sampah kecil atau wadah belanja ulang\n• Kemasan sachet → bahan kerajinan tangan seperti tas anyaman\n• Botol shampo → dispenser kecil atau tempat alat tulis\n\nDengan kreativitas, plastik bekas bisa memiliki nilai guna kembali sebelum akhirnya disetorkan.',
      },
      {
        'heading': 'Dampak Nyata dari Aksi Kecilmu',
        'body':
            'Mendaur ulang 1 ton plastik menghemat energi setara 5.774 kWh listrik dan mengurangi emisi CO₂ sebesar 1,5 ton. Bayangkan jika seluruh rumah tangga di Indonesia melakukan hal yang sama — perubahan besar dimulai dari dapur dan ruang tamu kita.',
      },
    ],
  },
  {
    'title': 'Cara Mengelola Sampah Organik dari Rumah',
    'image': 'assets/images/modul_organik.jpg',
    'kategori': 'Organik',
    'durasi': '8 menit',
    'penulis': 'Tim Setor.in',
    'artikel': [
      {
        'heading': 'Sampah Organik: Masalah atau Peluang?',
        'body':
            'Sekitar 60% sampah rumah tangga di Indonesia adalah sampah organik — sisa sayuran, nasi, kulit buah, dan ampas masakan. Jika langsung dibuang ke TPA, sampah organik menghasilkan gas metana yang 25 kali lebih merusak daripada CO₂.\n\nNamun di tangan yang tepat, sampah organik bisa berubah menjadi kompos berkualitas tinggi yang menyuburkan tanaman — gratis dan ramah lingkungan.',
      },
      {
        'heading': 'Metode Pengomposan Rumahan',
        'body':
            'Ada tiga cara mudah membuat kompos di rumah:\n\n• Composting Aerobik — wadah terbuka dengan lubang udara, aduk setiap 3 hari, selesai dalam 4–8 minggu\n• Vermikomposting — menggunakan cacing tanah, sangat efisien, kompos jadi dalam 2–4 minggu\n• Bokashi — fermentasi dengan bantuan EM4 (effective microorganism), cocok untuk dapur kecil\n\nPilih metode yang paling sesuai dengan luas rumah dan rutinitas harianmu.',
      },
      {
        'heading': 'Cara Membuat Kompos Aerobik',
        'body':
            '1. Siapkan wadah berlubang atau tong kompos berukuran 50–100 liter.\n\n2. Masukkan bahan coklat (daun kering, kardus robek) sebagai lapisan dasar.\n\n3. Tambahkan bahan hijau (sisa sayuran, buah) di atasnya dengan rasio 1:2.\n\n4. Siram sedikit air jika terlalu kering.\n\n5. Aduk setiap 2–3 hari untuk menjaga sirkulasi udara.\n\n6. Setelah 4–8 minggu, kompos siap digunakan saat sudah berwarna coklat gelap dan berbau tanah.',
      },
      {
        'heading': 'Yang Boleh dan Tidak Boleh Dikompos',
        'body':
            'Boleh dikompos:\n• Sisa sayuran dan buah\n• Ampas kopi dan teh\n• Kulit telur\n• Daun kering dan potongan rumput\n• Nasi dan roti basi\n\nJangan dikompos:\n• Daging, ikan, atau tulang (menarik hama)\n• Produk susu\n• Minyak dan lemak\n• Tanaman sakit atau berjamur\n• Kotoran hewan peliharaan berbahan daging',
      },
      {
        'heading': 'Manfaat Kompos untuk Tanamanmu',
        'body':
            'Kompos rumahan mengandung nitrogen, fosfor, dan kalium alami yang memperbaiki struktur tanah, meningkatkan kemampuan tanah menahan air, dan mendorong pertumbuhan mikroorganisme baik.\n\nCukup campurkan 20% kompos dengan 80% tanah tanam — tanaman sayuranmu akan tumbuh lebih sehat tanpa pupuk kimia.',
      },
    ],
  },
  {
    'title': 'Cara Memilah Sampah Kertas',
    'image': 'assets/images/modul_kertas.jpg',
    'kategori': 'Kertas',
    'durasi': '5 menit',
    'penulis': 'Tim Setor.in',
    'artikel': [
      {
        'heading': 'Kenapa Kertas Harus Dipilah?',
        'body':
            'Indonesia mengonsumsi sekitar 7 juta ton kertas per tahun. Industri kertas adalah salah satu penyumbang deforestasi terbesar karena setiap ton kertas baru membutuhkan 17 batang pohon.\n\nDengan memilah dan mendaur ulang kertas, kita tidak hanya mengurangi tumpukan sampah, tapi juga secara langsung membantu menjaga hutan.',
      },
      {
        'heading': 'Jenis-Jenis Kertas yang Bisa Didaur Ulang',
        'body':
            'Tidak semua kertas bisa didaur ulang. Berikut panduan singkatnya:\n\nBISA didaur ulang:\n• Koran dan majalah\n• Kertas HVS dan fotokopi\n• Kardus dan karton\n• Amplop dan paper bag\n• Buku bekas (tanpa hard cover)\n\nTIDAK bisa didaur ulang:\n• Tisu dan kertas toilet (sudah terkontaminasi)\n• Kertas berlapis plastik atau aluminium (bungkus mi instan, dll)\n• Struk kasir berbahan thermal\n• Kertas berminyak atau bekas makanan',
      },
      {
        'heading': 'Langkah Memilah Kertas di Rumah',
        'body':
            '1. Sediakan dus atau kantong khusus untuk kertas bersih di dapur atau ruang kerja.\n\n2. Setiap ada kertas bekas, segera masukkan — jangan biarkan tercampur sampah basah.\n\n3. Pisahkan kardus dari kertas tipis karena harga setor dan proses daur ulangnya berbeda.\n\n4. Lipat kardus menjadi pipih agar hemat tempat.\n\n5. Keluarkan klip logam, staples, atau lakban sebelum disetor.\n\n6. Setorkan ke bank sampah saat sudah terkumpul minimal 1–2 kg.',
      },
      {
        'heading': 'Nilai Ekonomi Sampah Kertas',
        'body':
            'Sampah kertas punya nilai jual yang lumayan:\n• Kertas HVS campuran: Rp 800–1.200/kg\n• Kardus: Rp 1.500–2.000/kg\n• Koran: Rp 700–1.000/kg\n\nDengan mengumpulkan kertas dari satu rumah tangga selama sebulan, kamu bisa menghasilkan 5–10 kg atau sekitar Rp 5.000–20.000 — kecil tapi konsisten dan bermakna.',
      },
      {
        'heading': 'Tips Mengurangi Sampah Kertas',
        'body':
            'Pilah itu penting, tapi mengurangi jauh lebih baik:\n\n• Gunakan kertas bolak-balik sebelum dibuang\n• Pilih tagihan digital daripada cetak\n• Bawa tas belanja sendiri untuk menghindari paper bag\n• Kirim ucapan lewat pesan digital, bukan kartu cetak\n• Cetak dokumen hanya saat benar-benar perlu',
      },
    ],
  },
  {
    'title': 'Mengelola Sampah Logam',
    'image': 'assets/images/modul_logam.jpg',
    'kategori': 'Logam',
    'durasi': '6 menit',
    'penulis': 'Tim Setor.in',
    'artikel': [
      {
        'heading': 'Logam Bekas: Sampah Bernilai Tinggi',
        'body':
            'Sampah logam adalah salah satu sampah paling bernilai dalam dunia daur ulang. Aluminium, besi, tembaga, dan kuningan bisa didaur ulang berkali-kali tanpa kehilangan sifat aslinya.\n\nMendaur ulang aluminium, misalnya, hanya membutuhkan 5% energi dibanding memproduksi aluminium baru dari bijih bauksit. Ini penghematan energi yang luar biasa.',
      },
      {
        'heading': 'Mengenal Jenis Logam Rumah Tangga',
        'body':
            'Logam yang paling sering kita temui di rumah:\n\n• Aluminium — kaleng minuman, foil, rangka jendela\n• Besi/Baja — kaleng makanan, paku, peralatan dapur\n• Tembaga — kabel listrik, pipa air, koin lama\n• Seng — atap rumah, ember, baskom\n• Kuningan — kunci, engsel pintu\n\nCara membedakan: magnet akan menempel pada besi/baja, tapi tidak pada aluminium, tembaga, atau kuningan.',
      },
      {
        'heading': 'Cara Memilah dan Menyimpan Logam',
        'body':
            '1. Pisahkan logam dari sampah lain ke dalam wadah tersendiri.\n\n2. Gunakan tes magnet untuk membedakan besi (feromagnetik) dan non-besi.\n\n3. Bersihkan sisa makanan atau cairan dari kaleng sebelum disimpan.\n\n4. Gepengkan kaleng aluminium untuk menghemat ruang.\n\n5. Simpan di tempat kering — logam basah bisa berkarat dan menurunkan nilai jualnya.\n\n6. Kumpulkan dalam jumlah cukup (minimal 2–3 kg) sebelum disetor agar lebih efisien.',
      },
      {
        'heading': 'Harga Logam Bekas di Pasaran',
        'body':
            'Berikut kisaran harga logam bekas (dapat bervariasi per daerah):\n\n• Aluminium: Rp 10.000–15.000/kg\n• Tembaga: Rp 60.000–80.000/kg\n• Kuningan: Rp 30.000–45.000/kg\n• Besi tua: Rp 1.500–3.000/kg\n• Seng: Rp 3.000–5.000/kg\n\nTembaga dan aluminium adalah yang paling menguntungkan. Jika rumahmu ada renovasi atau penggantian kabel/pipa, jangan buang — setor ke bank sampah logam.',
      },
      {
        'heading': 'Keamanan Dalam Mengelola Logam',
        'body':
            'Beberapa hal yang perlu diperhatikan saat mengelola sampah logam:\n\n• Gunakan sarung tangan saat memegang logam bekas yang tajam\n• Jangan membakar logam — asapnya beracun\n• Hati-hati dengan baterai dan aki bekas — mengandung bahan kimia berbahaya, setor ke tempat khusus\n• Logam dari peralatan listrik yang masih bisa diperbaiki sebaiknya didonasikan dulu',
      },
    ],
  },
  {
    'title': 'Sampah Elektronik (E-Waste)',
    'image': 'assets/images/modul_elektronik.jpg',
    'kategori': 'Elektronik',
    'durasi': '10 menit',
    'penulis': 'Tim Setor.in',
    'artikel': [
      {
        'heading': 'Apa Itu E-Waste dan Mengapa Berbahaya?',
        'body':
            'E-waste atau sampah elektronik adalah perangkat elektronik yang sudah tidak dipakai — mulai dari ponsel lama hingga kulkas rusak. Indonesia menghasilkan sekitar 2,5 juta ton e-waste per tahun, tapi kurang dari 10% yang ditangani dengan benar.\n\nE-waste mengandung bahan berbahaya seperti timbal, merkuri, kadmium, dan arsen. Jika dibuang sembarangan, zat-zat ini meresap ke tanah dan air tanah, mencemari ekosistem dan mengancam kesehatan manusia.',
      },
      {
        'heading': 'Apa Saja yang Termasuk E-Waste?',
        'body':
            'E-waste mencakup lebih dari yang kita kira:\n\n• Perangkat komunikasi: ponsel, tablet, laptop, telepon rumah\n• Peralatan rumah tangga elektronik: AC, kulkas, mesin cuci, microwave\n• Perangkat hiburan: TV, speaker, kamera, konsol game\n• Aksesori: charger, kabel, earphone, mouse, keyboard\n• Perlengkapan kantor: printer, scanner, mesin fotokopi\n• Baterai berbagai jenis',
      },
      {
        'heading': 'Langkah Sebelum Membuang Perangkat',
        'body':
            'Sebelum menyingkirkan perangkat elektronik, lakukan ini:\n\n1. Pertimbangkan perbaikan — apakah masih bisa diperbaiki?\n\n2. Donasikan — ponsel lama yang masih nyala bisa sangat berguna bagi orang lain.\n\n3. Jual kembali — marketplace seperti Tokopedia atau OLX menerima barang bekas elektronik.\n\n4. Hapus semua data pribadi — factory reset ponsel/laptop sebelum diserahkan ke siapapun.\n\n5. Lepaskan baterai jika memungkinkan — baterai memerlukan penanganan terpisah.',
      },
      {
        'heading': 'Cara Membuang E-Waste dengan Benar',
        'body':
            'JANGAN taruh e-waste di tempat sampah biasa. Gunakan jalur resmi berikut:\n\n• Drop point e-waste resmi — banyak tersedia di mall, kantor pos, atau gerai operator seluler\n• Program take-back produsen — merek seperti Samsung, Apple, dan Xiaomi punya program daur ulang resminya\n• Bank sampah elektronik — cari yang terdekat lewat aplikasi atau website bank sampah daerahmu\n• Event daur ulang komunitas — sering diadakan oleh LSM lingkungan atau pemerintah daerah',
      },
      {
        'heading': 'Bahan Berharga dalam E-Waste',
        'body':
            'Di balik bahayanya, e-waste menyimpan logam berharga:\n\n• 1 ton ponsel bekas mengandung ±300 gram emas — jauh lebih banyak dari 1 ton bijih emas\n• Tembaga, perak, palladium, dan kobalt juga terkandung dalam jumlah signifikan\n\nIndustri urban mining — yaitu mengekstrak logam berharga dari e-waste — kini berkembang pesat. Dengan membuang e-waste ke tempat yang benar, kamu turut mendukung industri ini.',
      },
    ],
  },
];

// ─── SCREEN UTAMA ─────────────────────────────────────────────────────────────
class EdukasiScreen extends StatelessWidget {
  const EdukasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 15,
              color: Colors.black87,
            ),
          ),
        ),
        title: const Text(
          'Edukasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // ── KATEGORI SAMPAH ──
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
          _KategoriRow(),

          // ── MODUL ──
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 12),
            child: Text(
              'Modul',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          _ModulList(),
        ],
      ),
    );
  }
}

// ─── KATEGORI ROW ─────────────────────────────────────────────────────────────
class _KategoriRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kategoriSampahList.length,
        itemBuilder: (context, i) {
          final k = kategoriSampahList[i];
          final color = k['color'] as Color;
          return GestureDetector(
            onTap: () => Navigator.push(
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
                      color: color.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(k['icon'] as IconData, color: color, size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    k['label'],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
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

// ─── MODUL LIST ───────────────────────────────────────────────────────────────
class _ModulList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: modulList.map((m) => _ModulCard(modul: m)).toList(),
    );
  }
}

class _ModulCard extends StatelessWidget {
  final Map<String, dynamic> modul;
  const _ModulCard({required this.modul});

  @override
  Widget build(BuildContext context) {
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
              Image.asset(
                modul['image'] as String,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: Center(
                    child: Icon(Icons.image_outlined,
                        size: 40, color: Colors.grey.shade500),
                  ),
                ),
              ),
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
}