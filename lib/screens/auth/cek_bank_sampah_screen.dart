import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────
class BankSampah {
  final String id;
  final String nama;
  final String alamat;
  final String jarak;
  final String jamBuka;
  final String jamTutup;
  final double rating;
  final int ulasan;
  final bool buka;
  final List<String> jenisDiterima;
  final String telepon;
  final double lat;
  final double lng;
  final Color markerColor;

  const BankSampah({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.jarak,
    required this.jamBuka,
    required this.jamTutup,
    required this.rating,
    required this.ulasan,
    required this.buka,
    required this.jenisDiterima,
    required this.telepon,
    required this.lat,
    required this.lng,
    required this.markerColor,
  });

  String get jamOperasional => '$jamBuka – $jamTutup';
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────────────────────
final List<BankSampah> kDaftarBank = [
  BankSampah(
    id: 'bs1',
    nama: 'Bank Sampah Berseri',
    alamat: 'Jl. Mawar No. 12, Jakarta Selatan',
    jarak: '0.8 km',
    jamBuka: '08.00',
    jamTutup: '16.00',
    rating: 4.8,
    ulasan: 142,
    buka: true,
    jenisDiterima: ['Plastik', 'Kertas', 'Logam', 'Kaca'],
    telepon: '021-7654321',
    lat: -6.245,
    lng: 106.813,
    markerColor: kPrimary,
  ),
  BankSampah(
    id: 'bs2',
    nama: 'BSU Anggrek Hijau',
    alamat: 'Jl. Melati Raya No. 5, Jakarta Timur',
    jarak: '1.2 km',
    jamBuka: '07.00',
    jamTutup: '15.00',
    rating: 4.5,
    ulasan: 89,
    buka: true,
    jenisDiterima: ['Plastik', 'Kaca', 'Elektronik'],
    telepon: '021-8765432',
    lat: -6.225,
    lng: 106.845,
    markerColor: kInfo,
  ),
  BankSampah(
    id: 'bs3',
    nama: 'Bank Sampah Mandiri',
    alamat: 'Jl. Kenanga No. 30, Jakarta Barat',
    jarak: '2.3 km',
    jamBuka: '08.00',
    jamTutup: '17.00',
    rating: 4.2,
    ulasan: 56,
    buka: false,
    jenisDiterima: ['Kertas', 'Logam', 'Organik'],
    telepon: '021-5432109',
    lat: -6.180,
    lng: 106.790,
    markerColor: kWarning,
  ),
  BankSampah(
    id: 'bs4',
    nama: 'BSM Cempaka Wangi',
    alamat: 'Jl. Cempaka No. 7, Jakarta Pusat',
    jarak: '3.1 km',
    jamBuka: '09.00',
    jamTutup: '16.00',
    rating: 4.6,
    ulasan: 203,
    buka: true,
    jenisDiterima: ['Plastik', 'Kertas', 'Kaca', 'Logam'],
    telepon: '021-3456789',
    lat: -6.170,
    lng: 106.830,
    markerColor: Color(0xFF8B5CF6),
  ),
  BankSampah(
    id: 'bs5',
    nama: 'Bank Sampah Hijau Lestari',
    alamat: 'Jl. Pandan No. 2, Depok',
    jarak: '4.5 km',
    jamBuka: '08.00',
    jamTutup: '15.00',
    rating: 4.0,
    ulasan: 31,
    buka: false,
    jenisDiterima: ['Plastik', 'Organik'],
    telepon: '021-2345678',
    lat: -6.300,
    lng: 106.820,
    markerColor: kAccent,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class CekBankSampahScreen extends StatefulWidget {
  const CekBankSampahScreen({super.key});

  @override
  State<CekBankSampahScreen> createState() => _CekBankSampahScreenState();
}

class _CekBankSampahScreenState extends State<CekBankSampahScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _filterStatus = 'Semua'; // 'Semua' | 'Buka' | 'Tutup'
  String _filterJenis = 'Semua';
  BankSampah? _highlighted;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<String> _statusFilter = ['Semua', 'Buka', 'Tutup'];
  final List<String> _jenisFilter = ['Semua', 'Plastik', 'Kertas', 'Logam', 'Kaca', 'Elektronik', 'Organik'];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<BankSampah> get _filtered {
    return kDaftarBank.where((b) {
      final matchQuery = _query.isEmpty ||
          b.nama.toLowerCase().contains(_query.toLowerCase()) ||
          b.alamat.toLowerCase().contains(_query.toLowerCase());
      final matchStatus = _filterStatus == 'Semua' ||
          (_filterStatus == 'Buka' && b.buka) ||
          (_filterStatus == 'Tutup' && !b.buka);
      final matchJenis = _filterJenis == 'Semua' || b.jenisDiterima.contains(_filterJenis);
      return matchQuery && matchStatus && matchJenis;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ──
            SliverAppBar(
              pinned: true,
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              expandedHeight: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Cek Bank Sampah',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded),
                  onPressed: _showFilterSheet,
                ),
              ],
            ),

            // ── Map Placeholder ──
            SliverToBoxAdapter(child: _buildMap()),

            // ── Search + Chips ──
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(children: [
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau alamat bank sampah...',
                        hintStyle: const TextStyle(color: kTextSoft, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: kPrimary),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: kTextSoft, size: 18),
                                onPressed: () { setState(() { _query = ''; _searchCtrl.clear(); }); },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status chips
                  Row(children: [
                    ..._statusFilter.map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _chip(s, _filterStatus == s, () => setState(() => _filterStatus = s)),
                    )),
                    const Spacer(),
                    Text('${_filtered.length} lokasi',
                        style: const TextStyle(fontSize: 12, color: kTextSoft)),
                  ]),
                  const SizedBox(height: 10),
                ]),
              ),
            ),

            // ── List ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildCard(_filtered[i]),
                  childCount: _filtered.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── MAP ────────────────────────────────────────────────────────────────────
  Widget _buildMap() {
    return SizedBox(
      height: 220,
      child: Stack(children: [
        // Background
        Container(
          color: const Color(0xFFD4EDDA),
          child: CustomPaint(painter: _MapGridPainter(), size: Size.infinite),
        ),

        // Marker pins
        ...kDaftarBank.asMap().entries.map((e) {
          final b = e.value;
          // Posisi relatif (simulasi)
          final offsets = [
            const Offset(0.5, 0.55),
            const Offset(0.7, 0.35),
            const Offset(0.25, 0.3),
            const Offset(0.55, 0.2),
            const Offset(0.45, 0.78),
          ];
          final pos = offsets[e.key];
          return Positioned(
            left: MediaQuery.of(context).size.width * pos.dx - 14,
            top: 220 * pos.dy - 28,
            child: GestureDetector(
              onTap: () { setState(() => _highlighted = b); _showDetail(b); },
              child: Column(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: _highlighted?.id == b.id ? b.markerColor : b.buka ? b.markerColor : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: const Icon(Icons.recycling_rounded, color: Colors.white, size: 14),
                ),
                CustomPaint(
                  painter: _PinTailPainter(b.buka ? b.markerColor : Colors.grey),
                  size: const Size(10, 6),
                ),
              ]),
            ),
          );
        }),

        // My location
        Positioned(
          left: MediaQuery.of(context).size.width * 0.5 - 16,
          top: 220 * 0.55 - 16,
          child: Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: kInfo,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: kInfo.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 4)],
            ),
          ),
        ),

        // My location button
        Positioned(
          bottom: 12, right: 12,
          child: GestureDetector(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)],
              ),
              child: const Row(children: [
                Icon(Icons.my_location_rounded, color: kPrimary, size: 16),
                SizedBox(width: 4),
                Text('Lokasiku', style: TextStyle(fontSize: 12, color: kText, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),

        // Legenda
        Positioned(
          top: 12, left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _legendDot(kPrimary), const SizedBox(width: 4),
              const Text('Buka', style: TextStyle(fontSize: 10, color: kText)),
              const SizedBox(width: 8),
              _legendDot(Colors.grey), const SizedBox(width: 4),
              const Text('Tutup', style: TextStyle(fontSize: 10, color: kText)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _legendDot(Color c) => Container(width: 10, height: 10,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  // ── CHIP ───────────────────────────────────────────────────────────────────
  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? kPrimary : kBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? kPrimary : Colors.grey.shade200),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? Colors.white : kTextSoft,
            )),
      ),
    );
  }

  // ── CARD ───────────────────────────────────────────────────────────────────
  Widget _buildCard(BankSampah b) {
    return GestureDetector(
      onTap: () { setState(() => _highlighted = b); _showDetail(b); },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: _highlighted?.id == b.id
              ? Border.all(color: kPrimary, width: 2)
              : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: b.markerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.recycling_rounded, color: b.markerColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(b.nama,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kText))),
                  _statusBadge(b.buka),
                ]),
                const SizedBox(height: 3),
                Text(b.alamat,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: kTextSoft)),
              ])),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _infoChip(Icons.location_on_outlined, b.jarak, kTextSoft),
              const SizedBox(width: 10),
              _infoChip(Icons.access_time_rounded, b.jamOperasional, kTextSoft),
              const SizedBox(width: 10),
              _infoChip(Icons.star_rounded, '${b.rating} (${b.ulasan})', kWarning),
            ]),
            const SizedBox(height: 10),
            // Jenis diterima
            Wrap(spacing: 6, runSpacing: 4,
              children: b.jenisDiterima.map((j) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(j, style: const TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _statusBadge(bool buka) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: buka ? kPrimary.withValues(alpha: 0.1) : kDanger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(color: buka ? kPrimary : kDanger, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(buka ? 'Buka' : 'Tutup',
            style: TextStyle(color: buka ? kPrimary : kDanger, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontSize: 11, color: color)),
    ]);
  }

  // ── FILTER SHEET ────────────────────────────────────────────────────────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kText)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() { _filterStatus = 'Semua'; _filterJenis = 'Semua'; });
                  Navigator.pop(ctx);
                },
                child: const Text('Reset', style: TextStyle(fontSize: 13, color: kPrimary, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 20),
            const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, children: _statusFilter.map((s) {
              final active = _filterStatus == s;
              return GestureDetector(
                onTap: () => setModal(() => _filterStatus = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? kPrimary : kBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? kPrimary : Colors.grey.shade200),
                  ),
                  child: Text(s, style: TextStyle(fontSize: 12, color: active ? Colors.white : kTextSoft,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
                ),
              );
            }).toList()),
            const SizedBox(height: 18),
            const Text('Jenis Sampah', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: _jenisFilter.map((j) {
              final active = _filterJenis == j;
              return GestureDetector(
                onTap: () => setModal(() => _filterJenis = j),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? kPrimary : kBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? kPrimary : Colors.grey.shade200),
                  ),
                  child: Text(j, style: TextStyle(fontSize: 12, color: active ? Colors.white : kTextSoft,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
                ),
              );
            }).toList()),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { setState(() {}); Navigator.pop(ctx); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Terapkan Filter', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── DETAIL SHEET ────────────────────────────────────────────────────────────
  void _showDetail(BankSampah b) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              )),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Header
                  Row(children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: b.markerColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.recycling_rounded, color: b.markerColor, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(b.nama, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kText)),
                      const SizedBox(height: 4),
                      Text(b.alamat, style: const TextStyle(fontSize: 12, color: kTextSoft)),
                      const SizedBox(height: 6),
                      _statusBadge(b.buka),
                    ])),
                  ]),
                  const SizedBox(height: 20),

                  // Info grid
                  Row(children: [
                    Expanded(child: _infoBox(Icons.location_on_outlined, 'Jarak', b.jarak, kPrimary)),
                    const SizedBox(width: 10),
                    Expanded(child: _infoBox(Icons.star_rounded, 'Rating', '${b.rating}', kWarning)),
                    const SizedBox(width: 10),
                    Expanded(child: _infoBox(Icons.rate_review_outlined, 'Ulasan', '${b.ulasan}', kInfo)),
                  ]),
                  const SizedBox(height: 16),

                  // Detail info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.cardDecoration,
                    child: Column(children: [
                      _detailRow(Icons.access_time_rounded, 'Jam Operasional', b.jamOperasional),
                      const Divider(height: 16),
                      _detailRow(Icons.phone_outlined, 'Telepon', b.telepon),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Jenis yang diterima
                  const Text('Menerima Sampah', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: b.jenisDiterima.map((j) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: kPrimaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(j, style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                  )).toList()),
                  const SizedBox(height: 24),

                  // CTA Buttons
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone_outlined, size: 18, color: kPrimary),
                        label: const Text('Hubungi', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kPrimary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () { HapticFeedback.mediumImpact(); },
                        icon: const Icon(Icons.directions_rounded, size: 18),
                        label: const Text('Petunjuk Arah', style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary, foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _infoBox(IconData icon, String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: AppTheme.cardDecoration,
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: kTextSoft)),
      ]),
    );
  }

  Widget _detailRow(IconData icon, String label, String val) {
    return Row(children: [
      Icon(icon, color: kPrimary, size: 16),
      const SizedBox(width: 10),
      Text('$label: ', style: const TextStyle(fontSize: 13, color: kTextSoft)),
      Expanded(child: Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText))),
    ]);
  }
}

// ── Custom Painters ────────────────────────────────────────────────────────────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = Colors.white.withValues(alpha: 0.35)..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final roadH = Paint()..color = Colors.white.withValues(alpha: 0.55)..strokeWidth = 5..strokeCap = StrokeCap.round;
    final roadV = Paint()..color = Colors.white.withValues(alpha: 0.45)..strokeWidth = 4..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.55), Offset(size.width, size.height * 0.55), roadH);
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), Paint()..color = Colors.white.withValues(alpha: 0.3)..strokeWidth = 3);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), roadV);
    canvas.drawLine(Offset(size.width * 0.65, 0), Offset(size.width * 0.65, size.height), Paint()..color = Colors.white.withValues(alpha: 0.3)..strokeWidth = 2);
    
    // Blocks
    final blockPaint = Paint()..color = Colors.white.withValues(alpha: 0.15);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.05, size.height * 0.05, size.width * 0.25, size.height * 0.2), const Radius.circular(4)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.4, size.height * 0.05, size.width * 0.2, size.height * 0.18), const Radius.circular(4)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.7, size.height * 0.38, size.width * 0.25, size.height * 0.22), const Radius.circular(4)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.05, size.height * 0.65, size.width * 0.28, size.height * 0.28), const Radius.circular(4)), blockPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_) => false;
}