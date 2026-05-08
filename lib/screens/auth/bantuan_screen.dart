import 'package:flutter/material.dart';
import 'package:proyek_2_setor_in/screens/auth/app_theme.dart';

class BantuanScreen extends StatefulWidget {
  const BantuanScreen({super.key});

  @override
  State<BantuanScreen> createState() => _BantuanScreenState();
}

class _BantuanScreenState extends State<BantuanScreen> {
  final List<Map<String, String>> _faqList = [
    {
      'pertanyaan': 'Bagaimana cara menyetorkan sampah?',
      'jawaban':
          'Anda dapat menyetorkan sampah dengan memilih menu Setor pada halaman utama, lalu ikuti langkah-langkah yang tersedia.',
    },
    {
      'pertanyaan': 'Bagaimana cara mencairkan saldo?',
      'jawaban':
          'Saldo dapat dicairkan melalui menu Tarik Saldo. Pastikan Anda sudah menghubungkan rekening atau dompet digital terlebih dahulu.',
    },
    {
      'pertanyaan': 'Apa saja jenis sampah yang diterima?',
      'jawaban':
          'Kami menerima berbagai jenis sampah anorganik seperti plastik, kertas, logam, dan kaca. Pastikan sampah dalam kondisi bersih dan terpilah.',
    },
    {
      'pertanyaan': 'Berapa lama proses verifikasi akun?',
      'jawaban':
          'Proses verifikasi akun biasanya memakan waktu 1x24 jam setelah data lengkap dikirimkan.',
    },
    {
      'pertanyaan': 'Bagaimana jika poin saya tidak bertambah?',
      'jawaban':
          'Jika poin tidak bertambah setelah setoran dikonfirmasi, silakan hubungi tim kami melalui menu Hubungi Kami di bawah.',
    },
  ];

  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.grey.shade300, width: 1.5),
                      ),
                      child: const Icon(Icons.chevron_left,
                          size: 22, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Bantuan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.black12),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),

                    // Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: kPrimary.withOpacity(0.2), width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: kPrimary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.support_agent,
                                color: kPrimary, size: 26),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ada yang bisa kami bantu?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Temukan jawaban atau hubungi tim kami.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // FAQ Title
                    const Text(
                      'Pertanyaan Umum (FAQ)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // FAQ List
                    ...List.generate(_faqList.length, (index) {
                      final item = _faqList[index];
                      final isExpanded = _expandedIndex == index;
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _expandedIndex =
                                    isExpanded ? null : index;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              decoration: BoxDecoration(
                                color: isExpanded
                                    ? kPrimary.withOpacity(0.05)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isExpanded
                                      ? kPrimary.withOpacity(0.3)
                                      : Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['pertanyaan']!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isExpanded
                                                ? kPrimary
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: isExpanded
                                            ? kPrimary
                                            : Colors.grey.shade500,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  if (isExpanded) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      item['jawaban']!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }),

                    const SizedBox(height: 24),

                    // Kontak Kami Title
                    const Text(
                      'Hubungi Kami',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildKontakItem(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: 'support@setorin.id',
                    ),
                    const SizedBox(height: 10),
                    _buildKontakItem(
                      icon: Icons.phone_outlined,
                      label: 'WhatsApp',
                      value: '+62 812-3456-7890',
                    ),
                    const SizedBox(height: 10),
                    _buildKontakItem(
                      icon: Icons.access_time_outlined,
                      label: 'Jam Operasional',
                      value: 'Senin – Jumat, 08.00 – 17.00 WIB',
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKontakItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: kPrimary, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}