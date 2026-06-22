import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_transaksi_pelanggan_page.dart';

class RiwayatTransaksiPelangganPage extends StatelessWidget {
  const RiwayatTransaksiPelangganPage({super.key});

  String _formatWaktu(Timestamp? ts) {
    if (ts == null) return '-';
    final now = DateTime.now();
    final waktu = ts.toDate();
    final diff = now.difference(waktu);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${waktu.day}/${waktu.month}/${waktu.year}';
  }

  int _parseHarga(dynamic nilai) {
    if (nilai == null) return 0;
    if (nilai is int) return nilai;
    if (nilai is double) return nilai.toInt();
    final bersih =
        nilai.toString().replaceAll(RegExp(r'[Rp\.\s]'), '').trim();
    return int.tryParse(bersih) ?? 0;
  }

  String _formatRupiah(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  String _labelStatus(String status) {
    switch (status) {
      case 'aktif':
        return 'Aktif';
      case 'diproses':
        return 'Diproses';
      case 'di_jalan':
        return 'Di Jalan';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _colorStatus(String status) {
    switch (status) {
      case 'selesai':
        return Colors.green;
      case 'dibatalkan':
        return Colors.red;
      case 'di_jalan':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false,
          title: const Text('Transaksi Saya',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          bottom: const TabBar(
            labelColor: primaryTeal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryTeal,
            tabs: [
              Tab(text: 'Aktif'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: uid == null
            ? const Center(child: Text('Silakan login terlebih dahulu'))
            : StreamBuilder<QuerySnapshot>(
                // ✅ Query pakai index yang sudah ada: pelangganUid + createdAt
                // Tidak pakai whereIn status — filter dilakukan manual di bawah
                stream: FirebaseFirestore.instance
                    .collection('transaksi')
                    .where('pelangganUid', isEqualTo: uid)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                        child:
                            CircularProgressIndicator(color: primaryTeal));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const TabBarView(
                      children: [
                        Center(
                            child: Text('Belum ada transaksi aktif.',
                                style: TextStyle(color: Colors.grey))),
                        Center(
                            child: Text('Belum ada riwayat selesai.',
                                style: TextStyle(color: Colors.grey))),
                      ],
                    );
                  }

                  final semua = snapshot.data!.docs;

                  // ✅ Filter manual di client
                  final aktifDocs = semua.where((doc) {
                    final status =
                        (doc.data() as Map<String, dynamic>)['status'] ?? '';
                    return status != 'selesai' && status != 'dibatalkan';
                  }).toList();

                  final selesaiDocs = semua.where((doc) {
                    final status =
                        (doc.data() as Map<String, dynamic>)['status'] ?? '';
                    return status == 'selesai' || status == 'dibatalkan';
                  }).toList();

                  return TabBarView(
                    children: [
                      // ── Tab Aktif ──────────────────────────────────────
                      aktifDocs.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.hourglass_empty,
                                      size: 48, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text('Tidak ada transaksi aktif.',
                                      style: TextStyle(
                                          color: Colors.grey[500])),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: aktifDocs.length,
                              itemBuilder: (context, index) {
                                final doc = aktifDocs[index];
                                final data =
                                    doc.data() as Map<String, dynamic>;
                                return _buildCard(
                                  context,
                                  transaksiId: doc.id,
                                  data: data,
                                  primaryTeal: primaryTeal,
                                );
                              },
                            ),

                      // ── Tab Selesai ────────────────────────────────────
                      selesaiDocs.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long,
                                      size: 48, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text('Belum ada transaksi selesai.',
                                      style: TextStyle(
                                          color: Colors.grey[500])),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: selesaiDocs.length,
                              itemBuilder: (context, index) {
                                final doc = selesaiDocs[index];
                                final data =
                                    doc.data() as Map<String, dynamic>;
                                return _buildCard(
                                  context,
                                  transaksiId: doc.id,
                                  data: data,
                                  primaryTeal: primaryTeal,
                                );
                              },
                            ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String transaksiId,
    required Map<String, dynamic> data,
    required Color primaryTeal,
  }) {
    final int harga = _parseHarga(data['harga']);
    final String status = data['status'] ?? 'aktif';

    // ✅ Ambil langsung dari transaksi — tidak perlu FutureBuilder ke collection lain
    final String namaPemilik = data['namaPemilik'] ?? 'Pemilik Sumur';
    final int jumlahAir = data['jumlahAir'] ?? 0;
    final Timestamp? createdAt = data['createdAt'] as Timestamp?;

    final Color statusColor = _colorStatus(status);
    final String statusTeks = _labelStatus(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE8F2F2),
                child: Icon(Icons.water_drop, color: Color(0xFF2C6B6F)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(namaPemilik,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.water_drop_outlined,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text('$jumlahAir Liter',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(_formatWaktu(createdAt),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rp ${_formatRupiah(harga)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF2C6B6F))),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(statusTeks,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailTransaksiPelangganPage(
                          transaksiId: transaksiId),
                    ),
                  );
                },
                child: Text('Lihat Detail',
                    style: TextStyle(
                        color: primaryTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}