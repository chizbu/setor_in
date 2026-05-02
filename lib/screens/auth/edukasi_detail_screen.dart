import 'package:flutter/material.dart';

class EdukasiDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const EdukasiDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String title = (data['title'] as String?) ?? '';
    final String image = (data['image'] as String?) ?? '';
    final String durasi = (data['durasi'] as String?) ?? '';
    final String penulis = (data['penulis'] as String?) ?? '';
    final String kategori = (data['kategori'] as String?) ?? '';
    final List<Map<String, dynamic>> artikel =
        (data['artikel'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: CustomScrollView(
        slivers: [
          // ── Hero cover ──
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.35),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 15, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Foto cover
                  Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade400,
                      child: const Center(
                        child: Icon(Icons.image_outlined,
                            size: 60, color: Colors.white54),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Judul di atas foto
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (kategori.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              kategori,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(children: [
                          const Icon(Icons.access_time_rounded,
                              color: Colors.white70, size: 13),
                          const SizedBox(width: 4),
                          Text(durasi,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          const SizedBox(width: 14),
                          const Icon(Icons.person_outline_rounded,
                              color: Colors.white70, size: 13),
                          const SizedBox(width: 4),
                          Text(penulis,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Isi artikel ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if (i >= artikel.length) return null;
                  final section = artikel[i];
                  final heading = (section['heading'] as String?) ?? '';
                  final body = (section['body'] as String?) ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading section
                        Text(
                          heading,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Divider kecil
                        Container(
                          width: 32,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9146),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Body paragraf
                        Text(
                          body,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A4A4A),
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: artikel.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}