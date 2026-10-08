import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api_service.dart';
import 'app_theme.dart';

String rupiah(dynamic value) {
  final n = value is num
      ? value.round()
      : int.tryParse(value?.toString() ?? '') ?? 0;
  final s = n.toString();
  return 'Rp${s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
}

class PrdScreenFrame extends StatelessWidget {
  const PrdScreenFrame({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });
  final String title;
  final Widget child;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    appBar: AppBar(
      title: Text(title),
      backgroundColor: kBg,
      foregroundColor: kText,
      surfaceTintColor: Colors.transparent,
      actions: action == null ? null : [action!],
    ),
    body: child,
  );
}

class QrNasabahScreen extends StatefulWidget {
  const QrNasabahScreen({super.key});
  @override
  State<QrNasabahScreen> createState() => _QrNasabahScreenState();
}

class _QrNasabahScreenState extends State<QrNasabahScreen> {
  bool loading = true;
  String? error;
  String code = '';
  String name = '';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final result = await ApiService().getMe();
    final data = result['data'];
    if (result['success'] == true && data is Map) {
      code = (data['kode_qr'] ?? data['qr_code'] ?? '').toString();
      name = (data['nama'] ?? '').toString();
      if (code.isEmpty) error = 'QR nasabah belum tersedia pada akun ini.';
    } else {
      error = result['message']?.toString() ?? 'Data QR belum dapat dimuat.';
    }
    if (mounted)
      setState(() {
        loading = false;
      });
  }

  @override
  Widget build(BuildContext context) => PrdScreenFrame(
    title: 'QR setor',
    action: IconButton(
      onPressed: _load,
      icon: const Icon(Icons.refresh_rounded),
    ),
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE6EDE7)),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: kPrimaryLight,
                child: Icon(Icons.qr_code_2_rounded, color: kPrimary, size: 30),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kartu nasabah Rumah Hijau',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name.isEmpty ? 'Tunjukkan kode ini kepada petugas' : name,
                style: const TextStyle(color: kTextSoft),
              ),
              const SizedBox(height: 24),
              if (loading)
                const SizedBox(
                  height: 220,
                  child: Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  ),
                )
              else if (code.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE9EDE9)),
                  ),
                  child: QrImageView(
                    data: code,
                    size: 220,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                )
              else
                _InlineState(
                  message: error ?? 'QR belum tersedia.',
                  onRetry: _load,
                ),
              const SizedBox(height: 18),
              const Text(
                'Kode QR bersifat pribadi. Jangan bagikan selain kepada petugas saat menyetor.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: kTextSoft, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Sebelum menyetor',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
        ),
        const SizedBox(height: 12),
        const _Instruction(
          number: '01',
          title: 'Bersihkan dan pilah',
          detail:
              'Pastikan sampah bersih, kering, dan dipisahkan menurut jenis.',
        ),
        const _Instruction(
          number: '02',
          title: 'Tunjukkan QR ke petugas',
          detail: 'Petugas Rumah Hijau akan memindai kode nasabah Anda.',
        ),
        const _Instruction(
          number: '03',
          title: 'Sampah ditimbang',
          detail: 'Petugas mencatat jenis serta berat setiap sampah.',
        ),
        const _Instruction(
          number: '04',
          title: 'Saldo masuk setelah verifikasi',
          detail:
              'Nilai setoran yang sudah diverifikasi menambah saldo rupiah.',
        ),
      ],
    ),
  );
}

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});
  @override
  State<PriceScreen> createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> items = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final result = await ApiService().getJenisSampah();
    final raw = result['data'];
    final rows = raw is Map ? (raw['data'] ?? raw['jenis_sampah']) : raw;
    if (result['success'] == true && rows is List) {
      items = rows
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((e) => e['aktif'] != false)
          .toList();
      if (items.isEmpty) error = 'Belum ada harga sampah yang tersedia.';
    } else {
      error = result['message']?.toString() ?? 'Harga belum dapat dimuat.';
    }
    if (mounted)
      setState(() {
        loading = false;
      });
  }

  @override
  Widget build(BuildContext context) => PrdScreenFrame(
    title: 'Harga sampah',
    action: IconButton(
      onPressed: _load,
      icon: const Icon(Icons.refresh_rounded),
    ),
    child: loading
        ? const Center(child: CircularProgressIndicator(color: kPrimary))
        : error != null
        ? _InlineState(message: error!, onRetry: _load)
        : ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3EA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: kPrimary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Harga beli Rumah Hijau per kilogram. Nilai final mengikuti berat dan verifikasi petugas.',
                        style: TextStyle(
                          color: kText,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...items.map((item) => _PriceCard(item: item)),
            ],
          ),
  );
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.item});
  final Map<String, dynamic> item;
  @override
  Widget build(BuildContext context) {
    final title = (item['nama'] ?? item['nama_jenis'] ?? 'Jenis sampah')
        .toString();
    final category = (item['kategori'] ?? 'Daur ulang').toString();
    final price = item['harga_beli'] ?? item['harga_beli_per_kg'] ?? 0;
    final updated = item['updated_at'] ?? item['diperbarui_at'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDE8)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kPrimaryLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.recycling_rounded, color: kPrimary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$category${updated == null ? '' : ' · Diperbarui ${updated.toString().split('T').first}'}',
                  style: const TextStyle(fontSize: 12, color: kTextSoft),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rupiah(price),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: kPrimary,
                  fontSize: 16,
                ),
              ),
              const Text(
                'per kg',
                style: TextStyle(fontSize: 11, color: kTextSoft),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final controller = TextEditingController();
  final scroll = ScrollController();
  final messages = <Map<String, String>>[];
  bool sending = false;
  static const _key = 'setorin_chat_history_v1';
  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .whereType<Map>()
          .take(20)
          .map((e) => {'role': '${e['role']}', 'content': '${e['content']}'})
          .toList();
      if (mounted) setState(() => messages.addAll(list));
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(messages.take(20).toList()));
  }

  Future<void> _send() async {
    final text = controller.text.trim();
    if (text.isEmpty || text.length > 500 || sending) return;
    final local = <String, String>{'role': 'user', 'content': text};
    setState(() {
      messages.add(local);
      sending = true;
      controller.clear();
    });
    await _save();
    final contextMessages = messages
        .where((m) => m['role'] == 'user' || m['role'] == 'assistant')
        .toList()
        .reversed
        .take(10)
        .toList()
        .reversed
        .toList();
    final result = await ApiService().getChatReply(contextMessages);
    final data = result['data'];
    final reply = result['success'] == true && data is Map
        ? (data['reply'] ?? data['message'] ?? '').toString()
        : (result['message']?.toString() ??
              'Asisten belum dapat menjawab. Silakan coba lagi atau lihat FAQ.');
    if (mounted)
      setState(() {
        messages.add({
          'role': 'assistant',
          'content': reply.isEmpty
              ? 'Saya belum mendapat jawaban. Silakan coba lagi.'
              : reply,
        });
        sending = false;
      });
    await _save();
    if (scroll.hasClients)
      scroll.animateTo(
        scroll.position.maxScrollExtent + 160,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
  }

  @override
  void dispose() {
    controller.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    appBar: AppBar(
      title: const Text('Asisten Setor.in'),
      backgroundColor: kBg,
      foregroundColor: kText,
      surfaceTintColor: Colors.transparent,
    ),
    body: Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kPrimaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Jawaban bersifat umum seputar sampah, lingkungan, dan penggunaan Setor.in. Jangan kirim data pribadi atau saldo.',
            style: TextStyle(color: kText, fontSize: 12, height: 1.4),
          ),
        ),
        Expanded(
          child: messages.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'Tanyakan cara memilah sampah atau menggunakan Setor.in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kTextSoft, height: 1.5),
                    ),
                  ),
                )
              : ListView.builder(
                  controller: scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + (sending ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (sending && i == messages.length)
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kPrimary,
                            ),
                          ),
                        ),
                      );
                    final m = messages[i];
                    final mine = m['role'] == 'user';
                    return Align(
                      alignment: mine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(13),
                        constraints: const BoxConstraints(maxWidth: 310),
                        decoration: BoxDecoration(
                          color: mine ? kPrimary : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          m['content'] ?? '',
                          style: TextStyle(
                            color: mine ? Colors.white : kText,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLength: 500,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Tulis pertanyaan…',
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: sending ? null : _send,
                  icon: const Icon(Icons.arrow_upward_rounded),
                  style: IconButton.styleFrom(backgroundColor: kPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});
  static const entries = <(String, String)>[
    (
      'Sampah apa yang bisa disetor?',
      'Lihat halaman Harga untuk daftar jenis sampah aktif yang diterima Rumah Hijau.',
    ),
    (
      'Bagaimana menyiapkan sampah?',
      'Bersihkan, keringkan, dan pilah menurut jenis sebelum dibawa.',
    ),
    (
      'Kapan saldo bertambah?',
      'Saldo bertambah setelah petugas menyelesaikan verifikasi setoran.',
    ),
    (
      'Bagaimana cara menunjukkan QR?',
      'Buka tab QR di aplikasi dan tunjukkan kode kepada petugas Rumah Hijau.',
    ),
    (
      'Bisakah saya menarik saldo?',
      'Ajukan tukar saldo dari halaman Profil. Minimal pengajuan Rp10.000 dan memerlukan PIN.',
    ),
    (
      'Mengapa harga setoran berbeda?',
      'Nilai akhir dihitung dari berat terverifikasi dan harga beli yang berlaku saat transaksi disimpan.',
    ),
    (
      'Saya lupa PIN, apa yang harus dilakukan?',
      'Hubungi Rumah Hijau melalui kontak yang tersedia di halaman Lokasi & jadwal agar PIN dapat dipulihkan dengan aman.',
    ),
    (
      'Bagaimana jika saldo belum masuk?',
      'Periksa status transaksi. Saldo hanya masuk setelah setoran berstatus selesai.',
    ),
    (
      'Apakah aplikasi menerima sampah kotor?',
      'Tidak. Mohon bersihkan dan keringkan sampah agar layak dipilah dan didaur ulang.',
    ),
    (
      'Bagaimana menghubungi Rumah Hijau?',
      'Buka Profil lalu Lokasi & jadwal untuk melihat alamat dan pilihan kontak yang tersedia.',
    ),
  ];
  @override
  Widget build(BuildContext context) => PrdScreenFrame(
    title: 'Pertanyaan umum',
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: entries
          .map(
            (e) => Card(
              color: Colors.white,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ExpansionTile(
                title: Text(
                  e.$1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: kText,
                  ),
                ),
                iconColor: kPrimary,
                collapsedIconColor: kTextSoft,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text(
                    e.$2,
                    style: const TextStyle(color: kTextSoft, height: 1.5),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with WidgetsBindingObserver {
  Map<String, dynamic> location = {};
  Map<String, dynamic> schedule = {};
  String? error;
  bool loading = true;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) _load(silent: true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load(silent: true);
      _startTimer();
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive)
      timer?.cancel();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted)
      setState(() {
        loading = true;
        error = null;
      });
    final results = await Future.wait([
      ApiService().getLokasi(),
      ApiService().getJadwalSetor(),
    ]);
    final l = results[0]['data'];
    final s = results[1]['data'];
    if (results[0]['success'] == true && l is Map)
      location = Map<String, dynamic>.from(l);
    if (results[1]['success'] == true && s is Map)
      schedule = Map<String, dynamic>.from(s);
    if (location.isEmpty && schedule.isEmpty)
      error = results
          .firstWhere((e) => e['success'] != true)['message']
          ?.toString();
    if (mounted)
      setState(() {
        loading = false;
      });
  }

  Future<void> _maps() async {
    final lat = location['latitude'] ?? location['lat'];
    final lng = location['longitude'] ?? location['lng'];
    final address = location['alamat']?.toString() ?? 'Rumah Hijau';
    final uri = lat != null && lng != null
        ? Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng')
        : Uri.https('www.google.com', '/maps/search/', {
            'api': '1',
            'query': address,
          });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Maps tidak dapat dibuka.')),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PrdScreenFrame(
    title: 'Lokasi & jadwal',
    action: IconButton(
      onPressed: _load,
      icon: const Icon(Icons.refresh_rounded),
    ),
    child: loading
        ? const Center(child: CircularProgressIndicator(color: kPrimary))
        : ListView(
            padding: const EdgeInsets.all(18),
            children: [
              if (error != null && location.isEmpty && schedule.isEmpty)
                _InlineState(message: error!, onRetry: _load)
              else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE7ECE7)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Rumah Hijau',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: kText,
                              ),
                            ),
                          ),
                          _OpenBadge(
                            open:
                                (location['status_buka'] ??
                                    schedule['status_buka']) ==
                                true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        location['alamat']?.toString() ??
                            'Alamat belum tersedia',
                        style: const TextStyle(color: kTextSoft, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _maps,
                          icon: const Icon(Icons.directions_outlined),
                          label: const Text('Petunjuk arah'),
                        ),
                      ),
                      if ((location['whatsapp'] ?? location['no_whatsapp'])
                              ?.toString()
                              .isNotEmpty ==
                          true)
                        TextButton.icon(
                          onPressed: () => launchUrl(
                            Uri.parse(
                              'https://wa.me/${(location['whatsapp'] ?? location['no_whatsapp']).toString().replaceAll(RegExp(r'[^0-9]'), '')}',
                            ),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.chat_outlined),
                          label: const Text('Hubungi via WhatsApp'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Jadwal setor terdekat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 10),
                if (schedule.isEmpty)
                  const _InfoCard(text: 'Jadwal belum diumumkan.'),
                if (schedule.isNotEmpty)
                  _InfoCard(
                    text:
                        '${schedule['tanggal'] ?? 'Tanggal belum tersedia'}\n'
                        '${schedule['jam_buka'] ?? '—'} – ${schedule['jam_tutup'] ?? '—'} WIB\n'
                        '${schedule['catatan'] ?? ''}',
                  ),
              ],
            ],
          ),
  );
}

class _OpenBadge extends StatelessWidget {
  const _OpenBadge({required this.open});
  final bool open;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: open ? const Color(0xFFE4F4E8) : const Color(0xFFF1F2F1),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      open ? 'BUKA' : 'TUTUP',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: open ? kPrimary : kTextSoft,
      ),
    ),
  );
}

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});
  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final amount = TextEditingController();
  final targetName = TextEditingController();
  final targetNumber = TextEditingController();
  final owner = TextEditingController();
  final pin = TextEditingController();
  final pinConfirm = TextEditingController();
  String targetType = 'BANK';
  bool saving = false;
  bool saveTarget = false;
  int? availableBalance;
  bool hasPin = true;
  bool balanceLoading = true;
  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final results = await Future.wait([
      ApiService().getSaldoV1(),
      ApiService().getSavedExchangeTarget(),
    ]);
    if (!mounted) return;
    final result = results[0];
    final data = result['data'];
    if (result['success'] == true && data is Map) {
      final raw = data['tersedia'] ?? data['saldo_tersedia'] ?? data['saldo'];
      availableBalance = raw is num
          ? raw.round()
          : int.tryParse(raw?.toString() ?? '');
      hasPin = data['has_pin'] == true || data['pin_terdaftar'] == true;
    }
    final saved = results[1]['data'];
    final target = saved is List && saved.isNotEmpty ? saved.first : saved;
    if (results[1]['success'] == true && target is Map) {
      targetType = (target['jenis'] ?? target['jenis_tujuan'] ?? 'BANK')
          .toString()
          .toUpperCase();
      if (targetType != 'EWALLET') targetType = 'BANK';
      targetName.text = (target['nama'] ?? target['nama_tujuan'] ?? '')
          .toString();
      targetNumber.text = (target['nomor'] ?? target['nomor_tujuan'] ?? '')
          .toString();
      owner.text = (target['pemilik'] ?? target['nama_pemilik'] ?? '')
          .toString();
    }
    if (mounted) setState(() => balanceLoading = false);
  }

  @override
  void dispose() {
    amount.dispose();
    targetName.dispose();
    targetNumber.dispose();
    owner.dispose();
    pin.dispose();
    pinConfirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value =
        int.tryParse(amount.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (value < 10000) {
      _message('Nominal minimum penukaran adalah Rp10.000.');
      return;
    }
    if (availableBalance != null && value > availableBalance!) {
      _message('Nominal melebihi saldo tersedia ${rupiah(availableBalance)}.');
      return;
    }
    if (balanceLoading || availableBalance == null) {
      _message(
        'Saldo belum dapat diverifikasi. Periksa koneksi dan coba lagi.',
      );
      return;
    }
    if (targetName.text.trim().isEmpty ||
        targetNumber.text.trim().isEmpty ||
        owner.text.trim().isEmpty) {
      _message('Lengkapi tujuan dan nama pemilik rekening.');
      return;
    }
    final pinValue = pin.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(pinValue)) {
      _message('PIN harus terdiri dari 6 digit.');
      return;
    }
    if (!hasPin && pinValue != pinConfirm.text.trim()) {
      _message('Konfirmasi PIN tidak sama.');
      return;
    }
    setState(() => saving = true);
    if (!hasPin) {
      final pinResult = await ApiService().setPinV1(pinValue);
      if (pinResult['success'] != true) {
        if (mounted) setState(() => saving = false);
        _message(
          pinResult['message']?.toString() ?? 'PIN belum berhasil dibuat.',
        );
        return;
      }
      hasPin = true;
    }
    final result = await ApiService().createSaldoExchange({
      'nominal': value,
      'jenis_tujuan': targetType,
      'nama_tujuan': targetName.text.trim(),
      'nomor_tujuan': targetNumber.text.trim(),
      'nama_pemilik': owner.text.trim(),
      'simpan_tujuan': saveTarget,
      'pin': pinValue,
    });
    if (mounted) setState(() => saving = false);
    if (result['success'] == true && mounted) {
      _message(
        'Pengajuan terkirim. Saldo akan ditahan sampai permintaan diproses.',
      );
      Navigator.pop(context, true);
    } else {
      _message(result['message']?.toString() ?? 'Pengajuan belum berhasil.');
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Widget _field(
    String label,
    TextEditingController c, {
    TextInputType keyboard = TextInputType.text,
    String? hint,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: c,
      keyboardType: keyboard,
      inputFormatters: label == 'Nominal'
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5EAE5)),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => PrdScreenFrame(
    title: 'Tukar saldo',
    child: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Ajukan penukaran saldo',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: kText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Minimal Rp10.000. Tidak ada biaya penukaran.',
          style: TextStyle(color: kTextSoft),
        ),
        const SizedBox(height: 12),
        if (balanceLoading) const LinearProgressIndicator(color: kPrimary),
        if (!balanceLoading && availableBalance != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Saldo tersedia: ${rupiah(availableBalance)}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: kPrimary,
              ),
            ),
          ),
        const SizedBox(height: 20),
        _field(
          'Nominal',
          amount,
          keyboard: TextInputType.number,
          hint: 'Contoh: 50000',
        ),
        DropdownButtonFormField<String>(
          value: targetType,
          decoration: InputDecoration(
            labelText: 'Jenis tujuan',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          items: const [
            DropdownMenuItem(value: 'BANK', child: Text('Bank')),
            DropdownMenuItem(value: 'EWALLET', child: Text('E-wallet')),
          ],
          onChanged: (v) => setState(() => targetType = v ?? 'BANK'),
        ),
        const SizedBox(height: 14),
        _field(
          targetType == 'BANK' ? 'Nama bank' : 'Nama e-wallet',
          targetName,
        ),
        _field(
          targetType == 'BANK' ? 'Nomor rekening' : 'Nomor e-wallet',
          targetNumber,
          keyboard: TextInputType.number,
        ),
        _field('Nama pemilik', owner),
        CheckboxListTile(
          value: saveTarget,
          onChanged: (v) => setState(() => saveTarget = v ?? false),
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Simpan tujuan untuk berikutnya',
            style: TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(height: 8),
        _field(
          hasPin ? 'PIN 6 digit' : 'Buat PIN 6 digit',
          pin,
          keyboard: TextInputType.number,
          hint: '••••••',
        ),
        if (!hasPin)
          _field(
            'Ulangi PIN 6 digit',
            pinConfirm,
            keyboard: TextInputType.number,
            hint: '••••••',
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: saving ? null : _submit,
            style: FilledButton.styleFrom(backgroundColor: kPrimary),
            child: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Ajukan penukaran'),
          ),
        ),
      ],
    ),
  );
}

class _InlineState extends StatelessWidget {
  const _InlineState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_outlined, color: kTextSoft, size: 34),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: kTextSoft, height: 1.4),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Coba lagi'),
        ),
      ],
    ),
  );
}

class _Instruction extends StatelessWidget {
  const _Instruction({
    required this.number,
    required this.title,
    required this.detail,
  });
  final String number, title, detail;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: kPrimaryLight,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: kPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: kText,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                style: const TextStyle(
                  color: kTextSoft,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(text, style: const TextStyle(height: 1.6, color: kText)),
  );
}
