import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_theme.dart';
import 'rumah_hijau_screen.dart';
import 'ui_components.dart';

class TarikSaldoScreen extends StatefulWidget {
  final double saldoAwal;

  const TarikSaldoScreen({super.key, this.saldoAwal = 0});

  @override
  State<TarikSaldoScreen> createState() => _TarikSaldoScreenState();
}

class _TarikSaldoScreenState extends State<TarikSaldoScreen> {
  static const _providers = <_PayoutProvider>[
    _PayoutProvider(
      name: 'DANA',
      mark: 'DANA',
      type: 'E-wallet',
      color: Color(0xFF118EEA),
    ),
    _PayoutProvider(
      name: 'OVO',
      mark: 'OVO',
      type: 'E-wallet',
      color: Color(0xFF4C3494),
    ),
    _PayoutProvider(
      name: 'GoPay',
      mark: 'GoPay',
      type: 'E-wallet',
      color: Color(0xFF00AA5B),
    ),
    _PayoutProvider(
      name: 'ShopeePay',
      mark: 'SPay',
      type: 'E-wallet',
      color: Color(0xFFEE4D2D),
    ),
    _PayoutProvider(
      name: 'BCA',
      mark: 'BCA',
      type: 'Bank',
      color: Color(0xFF0060A8),
    ),
    _PayoutProvider(
      name: 'Mandiri',
      mark: 'mandiri',
      type: 'Bank',
      color: Color(0xFF003B71),
    ),
  ];
  static const _quickAmounts = [10000, 25000, 50000, 100000, 200000];

  final _formKey = GlobalKey<FormState>();
  final _nominal = TextEditingController();
  final _accountNumber = TextEditingController();
  final _accountName = TextEditingController();

  String _mode = 'transfer';
  _PayoutProvider? _selectedProvider;
  String? _providerError;
  bool _saveDestination = false;

  int get _balance =>
      widget.saldoAwal.isFinite && widget.saldoAwal > 0
          ? widget.saldoAwal.round()
          : 0;
  int get _amount => int.tryParse(_nominal.text) ?? 0;

  @override
  void dispose() {
    _nominal.dispose();
    _accountNumber.dispose();
    _accountName.dispose();
    super.dispose();
  }

  String _money(int value) => value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );

  void _selectProvider(_PayoutProvider provider) {
    setState(() {
      if (_selectedProvider?.name != provider.name) {
        _accountNumber.clear();
        _accountName.clear();
      }
      _selectedProvider = provider;
      _providerError = null;
    });
  }

  void _review() {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _providerError = _selectedProvider == null
          ? 'Pilih bank atau e-wallet tujuan.'
          : null;
    });
    if (!valid || _selectedProvider == null) return;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: kSurface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan penarikan',
                style: TextStyle(
                  color: kText,
                  fontSize: 18.7,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _reviewRow('Nominal', 'Rp ${_money(_amount)}'),
              _reviewRow('Jenis tujuan', _selectedProvider!.type),
              _reviewRow('Penyedia', _selectedProvider!.name),
              _reviewRow(
                _selectedProvider!.type == 'Bank'
                    ? 'Nomor rekening'
                    : 'Nomor e-wallet',
                _accountNumber.text.trim(),
              ),
              _reviewRow('Nama pemilik', _accountName.text.trim()),
              _reviewRow('Simpan tujuan', _saveDestination ? 'Ya' : 'Tidak'),
              const SizedBox(height: 10),
              const InlineNotice(
                message:
                    'Langkah pengajuan berikutnya memerlukan PIN 6 digit. API pengajuan/PIN belum tersedia, jadi penarikan ini belum dikirim dan saldo tidak berubah.',
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Kembali ke formulir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: kTextSoft, fontSize: 13.8)),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: kText,
                  fontSize: 13.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _fieldLabel(String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          value,
          style: const TextStyle(
            color: kText,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  Widget _modeButton({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final selected = _mode == value;
    return Expanded(
      child: InkWell(
        key: ValueKey('withdraw-mode-$value'),
        onTap: () => setState(() => _mode = value),
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? kPrimaryLight : kSurface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: selected ? kPrimary : kBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18.9, color: selected ? kPrimaryDark : kTextSoft),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? kPrimaryDark : kTextSoft,
                  fontSize: 11.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _providerTile(_PayoutProvider provider) {
    final selected = _selectedProvider?.name == provider.name;
    return InkWell(
      key: ValueKey('payout-provider-${provider.name}'),
      onTap: () => _selectProvider(provider),
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? provider.color.withValues(alpha: .08) : kSurface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: selected ? provider.color : kBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 48, maxWidth: 70),
              height: 27,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: provider.color,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                provider.mark,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              provider.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? provider.color : kText,
                fontSize: 11.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationCard({
    required String title,
    required String subtitle,
    required String actionLabel,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: kSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: ValueKey('cash-location-$title'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 22.4),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: kText,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: kTextSoft, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    actionLabel,
                    style: const TextStyle(
                      color: kPrimaryDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Icon(Icons.open_in_new_rounded,
                      color: kPrimaryDark, size: 14.2),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMapsSearch(String query) async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });
    try {
      final opened =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Maps tidak dapat dibuka.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Maps tidak dapat dibuka.')),
        );
      }
    }
  }

  void _openRumahHijau() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const RumahHijauScreen()),
    );
  }

  Widget _cashLocationsSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InlineNotice(
            message:
                'Pencarian ini hanya untuk menemukan lokasi dan petunjuk arah. Lokasi yang ditemukan belum terverifikasi sebagai mitra pencairan saldo; aplikasi tidak membuat permintaan tunai atau menjamin pembayaran di outlet.',
          ),
          const SizedBox(height: 14),
          _fieldLabel('Cari lokasi di sekitar Anda'),
          _locationCard(
            title: 'Agen tarik tunai',
            subtitle: 'Cari agen di sekitar melalui Google Maps',
            actionLabel: 'Cari lokasi',
            icon: Icons.storefront_outlined,
            color: const Color(0xFF427B55),
            onTap: () => _openMapsSearch('agen tarik tunai terdekat'),
          ),
          const SizedBox(height: 8),
          _locationCard(
            title: 'Alfamart',
            subtitle: 'Cari gerai di sekitar melalui Google Maps',
            actionLabel: 'Cari lokasi',
            icon: Icons.store_mall_directory_outlined,
            color: const Color(0xFFEE4D2D),
            onTap: () => _openMapsSearch('Alfamart terdekat'),
          ),
          const SizedBox(height: 8),
          _locationCard(
            title: 'Indomaret',
            subtitle: 'Cari gerai di sekitar melalui Google Maps',
            actionLabel: 'Cari lokasi',
            icon: Icons.store_mall_directory_outlined,
            color: const Color(0xFF1769AA),
            onTap: () => _openMapsSearch('Indomaret terdekat'),
          ),
          const SizedBox(height: 8),
          _locationCard(
            title: 'Bank Sampah Rumah Hijau',
            subtitle: 'Lihat informasi mitra dan petunjuk arah',
            actionLabel: 'Detail & arah',
            icon: Icons.eco_outlined,
            color: kPrimary,
            onTap: _openRumahHijau,
          ),
        ],
      );

  Widget _transferForm() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InlineNotice(
            message:
                'Minimum penarikan Rp10.000, tanpa biaya. Pengajuan bank/e-wallet memerlukan PIN 6 digit dan persetujuan admin. Endpoint pengajuan/PIN belum aktif; halaman ini hanya meninjau detail dan tidak mengubah saldo.',
          ),
          const SizedBox(height: 14),
          _fieldLabel('Nominal penarikan'),
          TextFormField(
            controller: _nominal,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              hintText: 'Minimal 10.000',
            ),
            validator: (value) {
              final amount = int.tryParse(value ?? '') ?? 0;
              if (amount < 10000) return 'Minimum penarikan Rp10.000.';
              if (amount > _balance) return 'Saldo tersedia tidak mencukupi.';
              return null;
            },
          ),
          if (_balance >= 10000) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 7,
              runSpacing: 6,
              children: [
                for (final amount
                    in _quickAmounts.where((value) => value <= _balance))
                  ActionChip(
                    label: Text('Rp ${_money(amount)}'),
                    onPressed: () {
                      _nominal.text = amount.toString();
                      setState(() {});
                    },
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          _fieldLabel('Pilih bank atau e-wallet tujuan'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: 72,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7,
            ),
            itemCount: _providers.length,
            itemBuilder: (context, index) => _providerTile(_providers[index]),
          ),
          if (_providerError != null) ...[
            const SizedBox(height: 5),
            Text(
              _providerError!,
              style: const TextStyle(color: kDanger, fontSize: 11.2),
            ),
          ],
          if (_selectedProvider != null) ...[
            const SizedBox(height: 13),
            _fieldLabel(
              _selectedProvider!.type == 'Bank'
                  ? 'Nomor rekening'
                  : 'Nomor HP e-wallet',
            ),
            TextFormField(
              controller: _accountNumber,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: _selectedProvider!.type == 'Bank'
                    ? 'Masukkan nomor rekening'
                    : 'Masukkan nomor HP yang terdaftar',
              ),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Nomor tujuan wajib diisi.'
                  : null,
            ),
            const SizedBox(height: 10),
            _fieldLabel(
              _selectedProvider!.type == 'Bank'
                  ? 'Nama pemilik rekening'
                  : 'Nama pemilik e-wallet',
            ),
            TextFormField(
              controller: _accountName,
              textCapitalization: TextCapitalization.words,
              decoration:
                  const InputDecoration(hintText: 'Sesuai nama akun tujuan'),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Nama pemilik wajib diisi.'
                  : null,
            ),
            const SizedBox(height: 6),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: _saveDestination,
              activeColor: kPrimary,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) =>
                  setState(() => _saveDestination = value ?? false),
              title: const Text(
                'Simpan tujuan ini untuk berikutnya',
                style: TextStyle(
                  color: kText,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Penyimpanan akan aktif setelah endpoint tujuan tersimpan tersedia.',
                style: TextStyle(color: kTextSoft, fontSize: 10),
              ),
            ),
          ],
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('Tarik Saldo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: kPrimaryDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TABUNGAN RUMAH HIJAU',
                    style: TextStyle(
                      color: Color(0xFFDDE5C9),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Saldo tersedia',
                    style: TextStyle(color: Color(0xFFDDE5C9), fontSize: 12.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${_money(_balance)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _modeButton(
                  value: 'transfer',
                  label: 'Transfer bank/e-wallet',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(width: 8),
                _modeButton(
                  value: 'locations',
                  label: 'Lokasi tunai',
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_mode == 'transfer') _transferForm() else _cashLocationsSection(),
          ],
        ),
      ),
      bottomNavigationBar: _mode == 'transfer'
          ? SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
                decoration: BoxDecoration(
                  color: kBg,
                  border: Border(
                    top: BorderSide(color: kBorder.withValues(alpha: .8)),
                  ),
                ),
                child: SizedBox(
                  height: 44,
                  child: FilledButton(
                    onPressed: _review,
                    child: const Text('Tinjau detail'),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _PayoutProvider {
  const _PayoutProvider({
    required this.name,
    required this.mark,
    required this.type,
    required this.color,
  });

  final String name;
  final String mark;
  final String type;
  final Color color;
}
