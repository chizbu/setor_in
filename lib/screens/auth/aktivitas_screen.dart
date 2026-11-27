import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../../services/api_service.dart';

class RiwayatTransaksiScreen extends StatefulWidget {
  const RiwayatTransaksiScreen({super.key});

  @override
  State<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> {
  bool _isLoading = true;
  List<dynamic> _allAktivitas = [];
  List<dynamic> _filteredAktivitas = [];
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _fetchAktivitas();
  }

  Future<void> _fetchAktivitas() async {
    setState(() => _isLoading = true);
    final res = await ApiService().getAktivitas();
    if (res['success']) {
      setState(() {
        _allAktivitas = res['data'] ?? [];
        _applyFilter();
        _isLoading = false;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal mengambil data')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'Semua') {
      _filteredAktivitas = _allAktivitas;
    } else if (_selectedFilter == 'Setoran') {
      _filteredAktivitas = _allAktivitas.where(_isSetoran).toList();
    } else {
      _filteredAktivitas = _allAktivitas.where(_isTukarSaldo).toList();
    }
  }

  String _typeOf(dynamic item) =>
      (item is Map ? (item['type'] ?? item['tipe'] ?? '') : '')
          .toString()
          .toLowerCase();

  bool _isSetoran(dynamic item) {
    final type = _typeOf(item);
    return type.contains('setor') || type.contains('deposit');
  }

  bool _isTukarSaldo(dynamic item) {
    final type = _typeOf(item);
    return type.contains('saldo') || type.contains('tarik') ||
        type.contains('tukar') || type.contains('withdraw');
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'selesai':
      case 'sukses':
      case 'aktif':
        return kPrimary;
      case 'pending':
      case 'proses':
        return kWarning;
      case 'batal':
      case 'tolak':
        return kDanger;
      default:
        return kTextSoft;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'setor':
        return Icons.recycling_rounded;
      case 'tarik':
      case 'tukar_saldo':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.history_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'setor':
        return kPrimary;
      case 'tarik':
      case 'tukar_saldo':
        return kInfo;
      default:
        return kTextSoft;
    }
  }

  String _rupiah(dynamic value) {
    final amount = num.tryParse(value?.toString() ?? '');
    if (amount == null) return 'Belum tersedia';
    final digits = amount.round().toString().split('').reversed.toList();
    final grouped = <String>[];
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 3 == 0) grouped.add('.');
      grouped.add(digits[i]);
    }
    return 'Rp${grouped.reversed.join()}';
  }

  void _showTransactionDetail(Map item) {
    final details =
        item['details'] is List ? item['details'] as List : <dynamic>[];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text((item['title'] ?? 'Detail setoran').toString(),
                    style: const TextStyle(
                        fontSize: AppTypography.title,
                        fontWeight: FontWeight.w800,
                        color: kText)),
                const SizedBox(height: 6),
                Text((item['date'] ?? 'Tanggal belum tersedia').toString(),
                    style: const TextStyle(color: kTextSoft, fontSize: AppTypography.bodySmall)),
                if (item['bank_name'] != null) ...[
                  const SizedBox(height: 4),
                  Text(item['bank_name'].toString(),
                      style: const TextStyle(color: kTextSoft, fontSize: AppTypography.bodySmall)),
                ],
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item['status']?.toString())
                        .withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                      (item['status'] ?? 'Status belum tersedia')
                          .toString()
                          .toUpperCase(),
                      style: TextStyle(
                          fontSize: AppTypography.bodySmall,
                          fontWeight: FontWeight.w800,
                          color: _getStatusColor(item['status']?.toString()))),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Rincian sampah',
                    style: TextStyle(
                        fontSize: AppTypography.subtitle,
                        fontWeight: FontWeight.w800,
                        color: kText)),
                const SizedBox(height: 10),
                if (details.isEmpty)
                  const Text(
                      'Rincian jenis, harga, dan subtotal belum dikirim oleh server.',
                      style: TextStyle(color: kTextSoft, height: 1.4))
                else
                  ...details.whereType<Map>().map((detail) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: kBg,
                            borderRadius: BorderRadius.circular(14)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  (detail['material'] ?? 'Jenis sampah')
                                      .toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: kText)),
                              const SizedBox(height: 6),
                              Text(
                                  'Berat ${detail['weight'] ?? '—'} kg  •  ${_rupiah(detail['price_per_kg'])}/kg',
                                  style: const TextStyle(
                                      color: kTextSoft, fontSize: AppTypography.bodySmall)),
                              const SizedBox(height: 4),
                              Text('Subtotal  ${_rupiah(detail['subtotal'])}',
                                  style: const TextStyle(
                                      color: kPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: AppTypography.bodySmall)),
                            ]),
                      )),
                const Divider(height: 24),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total setoran',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: kText)),
                      Text(_rupiah(item['total_amount']),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, color: kPrimary)),
                    ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: AppIconSize.lg, color: kText),
        ),
        title: const Text(
          'Riwayat transaksi',
          style: TextStyle(
            color: kText,
            fontSize: AppTypography.subtitle,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchAktivitas,
              color: kPrimary,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: kPrimary))
                  : _filteredAktivitas.isEmpty
                      ? _buildEmptyState()
                      : _buildListView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['Semua', 'Setoran', 'Tarik Saldo'];
    return Container(
      height: 56,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : kText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: AppTypography.bodySmall,
                ),
              ),
              selected: isSelected,
              selectedColor: kPrimary,
              backgroundColor: kBg,
              checkmarkColor: Colors.white,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                    _applyFilter();
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 180,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: AppIconSize.hero,
                color: kPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: AppTypography.subtitle,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
                _selectedFilter == 'Semua'
                  ? 'Setoran dan penukaran saldo akan muncul di sini.'
                  : _selectedFilter == 'Setoran'
                      ? 'Setoran akan muncul di sini setelah dicatat petugas.'
                      : 'Penukaran saldo akan muncul di sini setelah diajukan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppTypography.body,
                color: kTextSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _filteredAktivitas.length,
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemBuilder: (context, index) {
        final item = _filteredAktivitas[index];
        final type = item['type'] ?? 'other';
        final status = item['status'] ?? 'selesai';

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: AppTheme.cardDecoration,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _showTransactionDetail(item as Map),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getIconColor(type).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      _getIcon(type),
                      color: _getIconColor(type),
                      size: AppIconSize.md,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] ?? '',
                          style: const TextStyle(
                            fontSize: AppTypography.bodyLarge,
                            fontWeight: FontWeight.w700,
                            color: kText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['subtitle'] ?? '',
                          style: const TextStyle(
                            fontSize: AppTypography.body,
                            fontWeight: FontWeight.w600,
                            color: kPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['detail'] ?? '',
                          style: const TextStyle(
                            fontSize: AppTypography.bodySmall,
                            color: kTextSoft,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              (item['date'] ?? 'Tanggal belum tersedia')
                                  .toString(),
                              style: const TextStyle(
                                fontSize: AppTypography.bodySmall,
                                color: kTextSoft,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: AppTypography.overline,
                                  fontWeight: FontWeight.w700,
                                  color: _getStatusColor(status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
