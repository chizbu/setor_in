import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../../services/api_service.dart';

class AktivitasScreen extends StatefulWidget {
  const AktivitasScreen({super.key});

  @override
  State<AktivitasScreen> createState() => _AktivitasScreenState();
}

class _AktivitasScreenState extends State<AktivitasScreen> {
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
    } else if (_selectedFilter == 'Setor') {
      _filteredAktivitas = _allAktivitas.where((x) => x['type'] == 'setor').toList();
    } else if (_selectedFilter == 'Misi') {
      _filteredAktivitas = _allAktivitas.where((x) => x['type'] == 'misi').toList();
    }
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
      case 'misi':
        return Icons.flag_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'setor':
        return kPrimary;
      case 'misi':
        return kInfo;
      default:
        return kTextSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Aktivitas Anda'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
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
                  ? const Center(child: CircularProgressIndicator(color: kPrimary))
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
    final filters = ['Semua', 'Setor', 'Misi'];
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : kText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 12,
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 64,
                color: kPrimary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada aktivitas terbaru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'Semua'
                  ? 'Ayo lakukan setor sampah pertama Anda untuk mengumpulkan koin!'
                  : 'Tidak ada aktivitas untuk kategori $_selectedFilter.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
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
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = _filteredAktivitas[index];
        final type = item['type'] ?? 'other';
        final status = item['status'] ?? 'selesai';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppTheme.cardDecoration,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getIconColor(type).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(type),
                    color: _getIconColor(type),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['detail'] ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: kTextSoft,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item['date']} • ${item['time']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: kTextSoft,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
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
        );
      },
    );
  }
}
