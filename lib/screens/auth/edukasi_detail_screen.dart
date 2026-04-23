import 'package:flutter/material.dart';
import 'app_theme.dart';

class EdukasiDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const EdukasiDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 30),
            decoration: const BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 10),
                const Icon(Icons.recycling, size: 80, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  'Sampah ${data['kategori']}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCard('Definisi', Text(data['definisi'])),
                  _buildCard(
                    'Contoh Sampah',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (data['contoh'] as List)
                          .map<Widget>((e) => Text('• $e'))
                          .toList(),
                    ),
                  ),
                  _buildCard(
                    'Cara Pengelolaan',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (data['pengelolaan'] as List)
                          .map<Widget>((e) => Text('• $e'))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, Widget content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }
}