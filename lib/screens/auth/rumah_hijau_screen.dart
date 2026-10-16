import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import 'app_theme.dart';

class RumahHijauScreen extends StatefulWidget {
  const RumahHijauScreen({super.key});
  @override
  State<RumahHijauScreen> createState() => _RumahHijauScreenState();
}

class _RumahHijauScreenState extends State<RumahHijauScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _place;
  List<Map<String, dynamic>> _schedule = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ApiService().getBankSampah();
    if (!mounted) return;
    if (result['success'] != true) {
      setState(() {
        _error = result['message']?.toString() ??
            'Informasi Rumah Hijau belum dapat dimuat.';
        _loading = false;
      });
      return;
    }
    final raw = result['data'];
    final list = raw is List ? raw : (raw is Map ? [raw] : <dynamic>[]);
    final matches = list.whereType<Map>().where((bank) =>
        (bank['nama_bank'] ?? '')
            .toString()
            .toLowerCase()
            .contains('rumah hijau'));
    final selected = matches.isEmpty ? null : matches.first;
    if (selected == null) {
      setState(() {
        _error = 'Data mitra Rumah Hijau belum tersedia dari server.';
        _loading = false;
      });
      return;
    }
    final place = Map<String, dynamic>.from(selected);
    final schedules = place['jadwal_operasional'];
    setState(() {
      _place = place;
      _schedule = schedules is List
          ? schedules
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
      _loading = false;
    });
  }

  Future<void> _open(String value) async {
    final uri = Uri.parse(value);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aplikasi tujuan tidak dapat dibuka.')));
    }
  }

  String _phoneDigits(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^0'), '62');
  String _time(dynamic value) {
    final text = value?.toString() ?? '';
    return text.length >= 5 ? text.substring(0, 5) : text;
  }

  @override
  Widget build(BuildContext context) {
    final address = (_place?['alamat'] ?? '').toString();
    final phone = (_place?['no_telepon'] ?? '').toString().trim();
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Rumah Hijau'),
        backgroundColor: kBg,
        foregroundColor: kText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.location_off_outlined,
                          color: kTextSoft, size: 49.6),
                      const SizedBox(height: 12),
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: kTextSoft)),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba lagi')),
                    ]),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                            color: kPrimaryDark,
                            borderRadius: BorderRadius.circular(24)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.eco_outlined,
                                  color: Color(0xFFB9E7C9), size: 35.4),
                              const SizedBox(height: 14),
                              Text(
                                  (_place?['nama_bank'] ?? 'Rumah Hijau')
                                      .toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 8),
                              Text(
                                  address.isEmpty
                                      ? 'Alamat belum tersedia.'
                                      : address,
                                  style: const TextStyle(
                                      color: Colors.white70, height: 1.45)),
                              const SizedBox(height: 18),
                              Wrap(spacing: 10, runSpacing: 10, children: [
                                FilledButton.icon(
                                  onPressed: address.isEmpty
                                      ? null
                                      : () => _open(
                                          'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(address)}'),
                                  icon: const Icon(Icons.directions_outlined),
                                  label: const Text('Petunjuk arah'),
                                  style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: kPrimaryDark),
                                ),
                                if (phone.isNotEmpty)
                                  OutlinedButton.icon(
                                    onPressed: () => _open(
                                        'https://wa.me/${_phoneDigits(phone)}'),
                                    icon: const Icon(Icons.chat_outlined),
                                    label: const Text('WhatsApp'),
                                    style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(
                                            color: Colors.white54)),
                                  ),
                              ]),
                            ]),
                      ),
                      const SizedBox(height: 24),
                      const Text('Jadwal setor',
                          style: TextStyle(
                              color: kText,
                              fontSize: 18.7,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      if (_schedule.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18)),
                          child: const Text(
                              'Jadwal belum dibagikan. Silakan hubungi Rumah Hijau untuk memastikan waktu setor.',
                              style: TextStyle(color: kTextSoft, height: 1.45)),
                        )
                      else
                        ..._schedule.map((s) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16)),
                              child: Row(children: [
                                Expanded(
                                    child: Text((s['hari'] ?? '').toString(),
                                        style: const TextStyle(
                                            color: kText,
                                            fontWeight: FontWeight.w700))),
                                Text(
                                    '${_time(s['jam_buka'])} – ${_time(s['jam_tutup'])}',
                                    style: const TextStyle(
                                        color: kPrimary,
                                        fontWeight: FontWeight.w700)),
                              ]),
                            )),
                      const SizedBox(height: 10),
                      const Text(
                          'Status buka/tutup live memerlukan endpoint jadwal Proyek 3; konfirmasi jadwal terkini melalui kontak mitra.',
                          style: TextStyle(
                              color: kTextSoft, fontSize: 13.8, height: 1.45)),
                    ],
                  ),
                ),
    );
  }
}
