import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'rumah_hijau_screen.dart';
import 'ui_components.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  static const _faqList = <Map<String, String>>[
    {
      'question': 'Bagaimana cara menyetorkan sampah?',
      'answer':
          'Periksa harga dan jadwal Rumah Hijau, pilah serta bersihkan sampah, lalu tunjukkan QR nasabah kepada petugas. Petugas menimbang dan memverifikasi setoran.',
    },
    {
      'question': 'Bagaimana nilai setoran dihitung?',
      'answer':
          'Nilai setoran dihitung petugas berdasarkan jenis dan berat sampah serta harga beli yang berlaku saat transaksi diverifikasi.',
    },
    {
      'question': 'Apa saja jenis sampah yang diterima?',
      'answer':
          'Jenis yang diterima dapat berubah. Lihat daftar harga aktif di aplikasi sebelum berangkat dan pastikan sampah bersih serta terpilah.',
    },
    {
      'question': 'Mengapa QR nasabah belum tampil?',
      'answer':
          'QR diterbitkan backend setelah akun aktif. Jika akun sudah aktif tetapi QR belum muncul, muat ulang aplikasi dan hubungi pengelola Rumah Hijau.',
    },
    {
      'question': 'Di mana saya melihat status setoran?',
      'answer':
          'Buka menu Aktivitas untuk melihat detail dan status transaksi. Setoran muncul setelah petugas mengirim data transaksi ke server.',
    },
    {
      'question': 'Apakah harga sampah selalu sama?',
      'answer':
          'Harga dapat diperbarui pengelola. Nilai transaksi mengikuti harga saat setoran dicatat oleh petugas.',
    },
    {
      'question': 'Apa yang harus dilakukan jika OTP tidak diterima?',
      'answer':
          'Periksa kembali alamat email dan folder spam. Jangan pernah membagikan kode OTP kepada orang lain. Jika masih terkendala, minta bantuan pengelola Rumah Hijau.',
    },
    {
      'question': 'Bagaimana mengubah nomor HP atau alamat?',
      'answer':
          'Buka Profil, pilih Edit Profil, lalu simpan perubahan setelah terhubung ke server.',
    },
    {
      'question': 'Di mana lokasi dan jadwal setor?',
      'answer':
          'Buka halaman Rumah Hijau untuk melihat informasi mitra yang tersedia. Jika jadwal belum ditampilkan, konfirmasi kepada pengelola sebelum datang.',
    },
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          title: const Text('Panduan & FAQ'),
          backgroundColor: kBg,
          scrolledUnderElevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            AppCard(
              color: kPrimaryLight,
              child: const Row(
                children: [
                  BrandMark(size: 51.9),
                  SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Panduan Setor.in',
                            style: TextStyle(
                                color: kText,
                                fontSize: 17.2,
                                fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text(
                            'Info singkat seputar setoran sampah bersama Rumah Hijau.',
                            style: TextStyle(
                                color: kTextSoft, fontSize: 13.8, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 23),
            const SectionHeading('Pertanyaan umum'),
            const SizedBox(height: 11),
            ..._faqList.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        iconColor: kPrimary,
                        collapsedIconColor: kTextSoft,
                        title: Text(item['question']!,
                            style: const TextStyle(
                                color: kText,
                                fontSize: 14.9,
                                fontWeight: FontWeight.w700)),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(item['answer']!,
                                style: const TextStyle(
                                    color: kTextSoft,
                                    fontSize: 13.8,
                                    height: 1.5)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 13),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Butuh informasi lokasi?',
                      style: TextStyle(
                          color: kText,
                          fontSize: 17.2,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  const Text(
                      'Buka detail lokasi mitra untuk melihat informasi Rumah Hijau yang tersedia.',
                      style: TextStyle(
                          color: kTextSoft, fontSize: 13.8, height: 1.45)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RumahHijauScreen()),
                    ),
                    icon: const Icon(Icons.place_outlined, size: 21.2),
                    label: const Text('Lihat lokasi Rumah Hijau'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimary,
                      side: const BorderSide(color: kBorder),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
