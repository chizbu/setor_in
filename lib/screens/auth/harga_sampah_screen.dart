import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'app_theme.dart';

class HargaSampahScreen extends StatefulWidget {
  const HargaSampahScreen({super.key});

  @override
  State<HargaSampahScreen> createState() => _HargaSampahScreenState();
}

class _HargaSampahScreenState extends State<HargaSampahScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];
  DateTime? _updatedAt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ApiService().getBankSampah();
    if (!mounted) return;
    if (result['success'] != true) {
      setState(() {
        _error = result['message']?.toString() ?? 'Harga belum dapat dimuat.';
        _loading = false;
      });
      return;
    }
    final raw = result['data'];
    final banks = raw is List ? raw : (raw is Map ? [raw] : <dynamic>[]);
    final partner = banks.whereType<Map>().where((bank) =>
        (bank['nama_bank'] ?? '').toString().toLowerCase().contains('rumah hijau'));
    final rawPrices = partner.isEmpty ? null : partner.first['harga_sampah'];
    final prices = rawPrices is List ? rawPrices : <dynamic>[];
    final updateTimes = prices.whereType<Map>()
        .map((item) => DateTime.tryParse(item['updated_at']?.toString() ?? ''))
        .whereType<DateTime>().toList();
    final lastUpdated = updateTimes.isEmpty ? null : updateTimes.reduce((a, b) => a.isAfter(b) ? a : b);
    setState(() {
      _items = prices.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList();
      _updatedAt = lastUpdated;
      _loading = false;
    });
  }

  String _rupiah(dynamic value) {
    final amount = int.tryParse(value?.toString() ?? '') ?? 0;
    final digits = amount.toString().split('').reversed.toList();
    final output = <String>[];
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && index % 3 == 0) output.add('.');
      output.add(digits[index]);
    }
    return 'Rp${output.reversed.join()}';
  }

  String _formatWib(DateTime value) {
    final date = value.toUtc().add(const Duration(hours: 7));
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year} $hour:$minute WIB';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _load,
            color: kPrimary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: kBg,
                  surfaceTintColor: Colors.transparent,
                  title: const Text('Harga sampah'),
                  centerTitle: false,
                  actions: [IconButton(onPressed: _load, tooltip: 'Muat ulang', icon: const Icon(Icons.refresh_rounded, color: kText, size: 21.2))],
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 7, 16, 28),
                  sliver: SliverList.list(children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: kPrimaryDark, borderRadius: BorderRadius.circular(16)),
                      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.recycling_rounded, color: Color(0xFFDDE5C9), size: 23.6),
                        SizedBox(height: 8),
                        Text('Sampah terpilah punya nilai.', style: TextStyle(color: Colors.white, fontSize: 18.4, fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text('Bersihkan dan pilah sebelum dibawa ke Rumah Hijau.', style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4)),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      const Expanded(child: Text('Harga beli per kg', style: TextStyle(fontSize: 14.9, fontWeight: FontWeight.w800, color: kText))),
                      Text(_updatedAt == null ? 'Pembaruan belum tersedia' : 'Diperbarui ${_formatWib(_updatedAt!)}', style: const TextStyle(fontSize: 10, color: kTextSoft)),
                    ]),
                    const SizedBox(height: 8),
                    if (_loading)
                      const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: kPrimary)))
                    else if (_error != null)
                      _StateCard(icon: Icons.cloud_off_outlined, title: 'Belum tersambung', message: _error!, action: TextButton.icon(onPressed: _load, icon: const Icon(Icons.refresh_rounded, size: 17.7), label: const Text('Coba lagi')))
                    else if (_items.isEmpty)
                      const _StateCard(icon: Icons.inventory_2_outlined, title: 'Harga belum tersedia', message: 'Daftar harga akan muncul setelah Rumah Hijau mengaktifkan jenis sampah.')
                    else
                      ..._items.map((item) => _PriceTile(item: item, rupiah: _rupiah)),
                    const SizedBox(height: 10),
                    const Text('Harga dapat diperbarui oleh pengelola. Nilai pada setoran mengikuti harga saat transaksi dicatat.', style: TextStyle(color: kTextSoft, fontSize: 11.2, height: 1.45)),
                  ]),
                ),
              ],
            ),
          ),
        ),
      );
}

class _PriceTile extends StatelessWidget {
  const _PriceTile({required this.item, required this.rupiah});
  final Map<String, dynamic> item;
  final String Function(dynamic) rupiah;

  @override
  Widget build(BuildContext context) {
    final name = (item['nama'] ?? item['jenis_sampah'] ?? 'Jenis sampah').toString();
    final category = (item['kategori'] ?? 'Kategori belum disediakan').toString();
    final price = item['harga_beli'] ?? item['harga_per_kg'] ?? item['harga'];
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: Row(children: [
        Container(width: 30, height: 30, decoration: BoxDecoration(color: kPrimaryLight, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.recycling_outlined, color: kPrimary, size: 18.9)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w800, color: kText, fontSize: 12.5)),
          const SizedBox(height: 2),
          Text(category, style: const TextStyle(fontSize: 10, color: kTextSoft)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(rupiah(price), style: const TextStyle(fontWeight: FontWeight.w800, color: kPrimary, fontSize: 13.8)),
          const Text('per kg', style: TextStyle(color: kTextSoft, fontSize: 10)),
        ]),
      ]),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.icon, required this.title, required this.message, this.action});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
        child: Column(children: [
          Icon(icon, size: 26, color: kTextSoft),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: kText, fontSize: 12.5)),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: kTextSoft, fontSize: 11.2, height: 1.4)),
          if (action != null) action!,
        ]),
      );
}
