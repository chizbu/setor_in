import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'ui_components.dart';

class ActivityEntry {
  const ActivityEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.when,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final DateTime when;
}

class AktivitasScreen extends StatelessWidget {
  const AktivitasScreen({super.key, required this.entries});

  final List<ActivityEntry> entries;

  String _relativeTime(DateTime value) {
    final difference = DateTime.now().difference(value);
    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inHours < 1) return '${difference.inMinutes} menit lalu';
    if (difference.inDays < 1) return '${difference.inHours} jam lalu';
    return '${difference.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          title: const Text('Aktivitas'),
          backgroundColor: kBg,
          foregroundColor: kText,
          surfaceTintColor: Colors.transparent,
        ),
        body: entries.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: AppStateCard(
                    icon: Icons.history_rounded,
                    title: 'Belum ada aktivitas',
                    message: 'Aktivitas akunmu akan muncul di sini.',
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 7),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      minLeadingWidth: 30,
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: kPrimaryLight,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(entry.icon, size: 17.7, color: kPrimaryDark),
                      ),
                      title: Text(entry.title,
                          style: const TextStyle(
                              color: kText, fontSize: 13.8, fontWeight: FontWeight.w800)),
                      subtitle: Text(entry.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: kTextSoft, fontSize: 11.2)),
                      trailing: Text(_relativeTime(entry.when),
                          style: const TextStyle(color: kTextSoft, fontSize: 10)),
                    ),
                  );
                },
              ),
      );
}
