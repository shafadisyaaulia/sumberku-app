import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotifikasiPemilikPage extends StatelessWidget {
  const NotifikasiPemilikPage({super.key});

  Map<String, dynamic> _getStyleByType(String tipe) {
    switch (tipe) {
      case 'permintaan_baru':
        return {'icon': Icons.water_drop, 'color': Colors.blue};
      case 'disetujui':
        return {'icon': Icons.thumb_up_alt_rounded, 'color': Colors.green};
      case 'selesai':
        return {'icon': Icons.monetization_on, 'color': Colors.orange};
      case 'ditolak':
        // ✅ Ikon merah khusus untuk tawaran ditolak
        return {'icon': Icons.thumb_down_alt_rounded, 'color': Colors.red};
      default:
        return {'icon': Icons.notifications, 'color': Colors.grey};
    }
  }

  String _formatWaktu(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifikasi',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        elevation: 1,
        actions: [
          TextButton(
            onPressed: () async {
              if (uid == null) return;
              final batch = FirebaseFirestore.instance.batch();
              final unreadNotifs = await FirebaseFirestore.instance
                  .collection('notifikasi')
                  .where('uid', isEqualTo: uid)
                  .where('isUnread', isEqualTo: true)
                  .get();
              for (var doc in unreadNotifs.docs) {
                batch.update(doc.reference, {'isUnread': false});
              }
              await batch.commit();
            },
            child: const Text('Tandai Dibaca',
                style: TextStyle(
                    color: Color(0xFF2C6B6F),
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: uid == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifikasi')
                  .where('uid', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none,
                            size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('Belum ada notifikasi.',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 13)),
                      ],
                    ),
                  );
                }

                // Sort manual: terbaru di atas, null createdAt paling atas
                final listNotif = snapshot.data!.docs.toList();
                listNotif.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime = aData['createdAt'] as Timestamp?;
                  final bTime = bData['createdAt'] as Timestamp?;
                  if (aTime == null) return -1;
                  if (bTime == null) return 1;
                  return bTime.compareTo(aTime);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listNotif.length,
                  itemBuilder: (context, index) {
                    final doc = listNotif[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final String judul = data['judul'] ?? 'Pemberitahuan';
                    final String pesan = data['pesan'] ?? '';
                    final String tipe = data['tipe'] ?? '';
                    final bool isUnread = data['isUnread'] ?? false;
                    final Timestamp? createdAt =
                        data['createdAt'] as Timestamp?;

                    final style = _getStyleByType(tipe);

                    return GestureDetector(
                      onTap: () {
                        if (isUnread) {
                          doc.reference.update({'isUnread': false});
                        }
                      },
                      child: _buildNotifItem(
                        judul,
                        pesan,
                        _formatWaktu(createdAt),
                        style['icon'] as IconData,
                        style['color'] as Color,
                        isUnread: isUnread,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildNotifItem(
    String title,
    String body,
    String time,
    IconData icon,
    Color iconColor, {
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFE8F2F2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isUnread
            ? Border.all(color: const Color(0xFF2C6B6F).withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.12),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13))),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Color(0xFF2C6B6F), shape: BoxShape.circle),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(time,
                style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
      ),
    );
  }
}