import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'penawaran_masuk_page.dart';
import 'detail_transaksi_pelanggan_page.dart';

class NotifikasiPelangganPage extends StatelessWidget {
  const NotifikasiPelangganPage({super.key});

  String _formatWaktu(Timestamp? ts) {
    if (ts == null) return 'Baru saja';
    final now = DateTime.now();
    final waktu = ts.toDate();
    final diff = now.difference(waktu);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${waktu.day}/${waktu.month}/${waktu.year}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        // PERBAIKAN: Menambahkan tombol panah kembali manual agar pasti muncul warna hitam
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
      ),
      body: uid == null
          ? const Center(child: Text('Silakan login terlebih dahulu'))
          : _buildNotifikasiGabungan(context, uid),
    );
  }

  Widget _buildNotifikasiGabungan(BuildContext context, String uid) {
    // Stream 1: permintaan yang ada penawaran masuk (belum diterima)
    final streamPenawaran = FirebaseFirestore.instance
        .collection('permintaan')
        .where('pelangganUid', isEqualTo: uid)
        .where('status', isEqualTo: 'ada_penawaran')
        .orderBy('createdAt', descending: true)
        .snapshots();

    // Stream 2: semua transaksi milik pelanggan ini (untuk notif status)
    final streamTransaksi = FirebaseFirestore.instance
        .collection('transaksi')
        .where('pelangganUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: streamPenawaran,
      builder: (context, snapPenawaran) {
        return StreamBuilder<QuerySnapshot>(
          stream: streamTransaksi,
          builder: (context, snapTransaksi) {
            if (snapPenawaran.connectionState == ConnectionState.waiting ||
                snapTransaksi.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<Widget> notifItems = [];

            // ── Notifikasi penawaran masuk ──
            final penawaranDocs = snapPenawaran.data?.docs ?? [];
            for (final doc in penawaranDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final jumlahAir = data['jumlahAir'] ?? 0;
              notifItems.add(
                _buildNotifItem(
                  context,
                  title: 'Penawaran Masuk!',
                  body: 'Ada penawaran untuk permintaan $jumlahAir liter air Anda. Segera pilih!',
                  time: _formatWaktu(data['createdAt'] as Timestamp?),
                  icon: Icons.local_offer,
                  iconColor: Colors.blue,
                  isUnread: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PenawaranMasukPage(permintaanId: doc.id),
                      ),
                    );
                  },
                ),
              );
            }

            // ── Notifikasi status transaksi ──
            final transaksiDocs = snapTransaksi.data?.docs ?? [];
            for (final doc in transaksiDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] ?? '';
              final namaPemilik = data['namaPemilik'] ?? 'Pemilik Sumur';
              final waktu = _formatWaktu(data['createdAt'] as Timestamp?);

              String title = '';
              String body = '';
              IconData icon = Icons.info_outline;
              Color iconColor = Colors.grey;
              bool isUnread = false;

              if (status == 'aktif') {
                title = 'Pesanan Dikonfirmasi';
                body = '$namaPemilik telah menerima pesananmu. Menunggu pengiriman.';
                icon = Icons.check_circle_outline;
                iconColor = Colors.teal;
                isUnread = true;
              } else if (status == 'di_jalan') {
                title = 'Air Sedang Dikirim!';
                body = '$namaPemilik sedang dalam perjalanan menuju lokasimu.';
                icon = Icons.local_shipping_outlined;
                iconColor = Colors.orange;
                isUnread = true;
              } else if (status == 'selesai') {
                title = 'Pesanan Selesai';
                body = 'Pesananmu dari $namaPemilik telah selesai. Terima kasih!';
                icon = Icons.water_drop;
                iconColor = Colors.green;
                isUnread = false;
              } else if (status == 'dibatalkan') {
                title = 'Pesanan Dibatalkan';
                body = 'Pesananmu dari $namaPemilik telah dibatalkan.';
                icon = Icons.cancel_outlined;
                iconColor = Colors.red;
                isUnread = false;
              } else {
                continue;
              }

              notifItems.add(
                _buildNotifItem(
                  context,
                  title: title,
                  body: body,
                  time: waktu,
                  icon: icon,
                  iconColor: iconColor,
                  isUnread: isUnread,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailTransaksiPelangganPage(
                            transaksiId: doc.id),
                      ),
                    );
                  },
                ),
              );
            }

            if (notifItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('Belum ada notifikasi',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: notifItems,
            );
          },
        );
      },
    );
  }

  Widget _buildNotifItem(
    BuildContext context, {
    required String title,
    required String body,
    required String time,
    required IconData icon,
    required Color iconColor,
    bool isUnread = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            backgroundColor: iconColor.withOpacity(0.1),
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
      ),
    );
  }
}