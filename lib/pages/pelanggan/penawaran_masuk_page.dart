import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_transaksi_pelanggan_page.dart';

class PenawaranMasukPage extends StatelessWidget {
  final String permintaanId;

  const PenawaranMasukPage({super.key, required this.permintaanId});

  String _formatRupiah(dynamic amount) {
    if (amount == null) return '0';
    final val = amount is int ? amount : int.tryParse(amount.toString()) ?? 0;
    return val.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Penawaran Masuk',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('penawaran')
            .where('permintaanId', isEqualTo: permintaanId)
            .where('status', isEqualTo: 'menunggu')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: primaryTeal));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada penawaran masuk.\nMohon tunggu pemilik sumur menawar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200)),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${docs.length} penawaran masuk. Pilih penawaran terbaik!',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          docs[index].data() as Map<String, dynamic>;
                      final penawaranId = docs[index].id;
                      return _buildPenawaranCard(
                        context,
                        primaryTeal,
                        data,
                        penawaranId,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPenawaranCard(
    BuildContext context,
    Color themeColor,
    Map<String, dynamic> data,
    String penawaranId,
  ) {
    final String namaPemilik = data['namaPemilik'] ?? 'Pemilik Sumur';
    final String rating = data['rating']?.toString() ?? '5.0';
    final String kecamatan = data['kecamatan'] ?? 'Banda Aceh';
    final dynamic harga = data['harga'];
    final String pemilikUid = data['pemilikUid'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE8F2F2),
                  child: const Icon(Icons.store, color: Color(0xFF2C6B6F)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(namaPemilik,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          Text(' $rating',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(' • $kecamatan',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Harga Tawar',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 10)),
                    Text(
                      'Rp ${_formatRupiah(harga)}',
                      style: TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                // Tombol TOLAK
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _showKonfirmasiTolak(
                        context, penawaranId, pemilikUid, namaPemilik),
                    child: const Text(
                      '✕  Tolak',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Tombol TERIMA
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _showKonfirmasiTerima(
                        context, penawaranId, pemilikUid, namaPemilik, harga),
                    child: const Text(
                      '✓  Terima',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialog konfirmasi sebelum TERIMA ──────────────────────────────────────
  void _showKonfirmasiTerima(
    BuildContext context,
    String penawaranId,
    String pemilikUid,
    String namaPemilik,
    dynamic harga,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Terima Penawaran?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Anda akan menerima penawaran dari $namaPemilik. Penawaran lain akan otomatis ditolak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C6B6F),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _terimaPenawaran(
                  context, penawaranId, pemilikUid, namaPemilik, harga);
            },
            child: const Text('Ya, Terima',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Dialog konfirmasi sebelum TOLAK ───────────────────────────────────────
  void _showKonfirmasiTolak(
    BuildContext context,
    String penawaranId,
    String pemilikUid,
    String namaPemilik,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Penawaran?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            Text('Anda akan menolak penawaran dari $namaPemilik.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _tolakPenawaran(context, penawaranId, pemilikUid, namaPemilik);
            },
            child: const Text('Ya, Tolak',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Logika TERIMA penawaran ────────────────────────────────────────────────
  void _terimaPenawaran(
    BuildContext context,
    String penawaranId,
    String pemilikUid,
    String namaPemilik,
    dynamic harga,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF2C6B6F))),
    );

    try {
      // 1. Ambil data permintaan
      final permintaanDoc = await FirebaseFirestore.instance
          .collection('permintaan')
          .doc(permintaanId)
          .get();
      final permintaanData = permintaanDoc.data() ?? {};
      final int jumlahAir = permintaanData['jumlahAir'] ?? 0;
      final String alamat = permintaanData['alamat'] ?? '';
      final String kecamatan = permintaanData['kecamatan'] ?? '';
      final String namaPelanggan = permintaanData['namaPelanggan'] ?? '';

      // Ambil data penawaran yang diterima
      final penawaranDoc = await FirebaseFirestore.instance
          .collection('penawaran')
          .doc(penawaranId)
          .get();
      final penawaranData = penawaranDoc.data() ?? {};
      final int hargaInt = penawaranData['harga'] is int
          ? penawaranData['harga']
          : int.tryParse(penawaranData['harga'].toString()) ?? 0;

      // 2. Buat transaksi baru
      final transaksiRef =
          await FirebaseFirestore.instance.collection('transaksi').add({
        'permintaanId': permintaanId,
        'penawaranId': penawaranId,
        'pelangganUid': uid,
        'pemilikUid': pemilikUid,
        'namaPemilik': namaPemilik,
        'namaPelanggan': namaPelanggan,
        'harga': hargaInt,
        'jumlahAir': jumlahAir,
        'alamat': alamat,
        'kecamatan': kecamatan,
        'status': 'aktif',
        'qrCode': 'SUMBERKU-${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Update status permintaan → 'diproses'
      await FirebaseFirestore.instance
          .collection('permintaan')
          .doc(permintaanId)
          .update({
        'status': 'diproses',
        'pemilikUid': pemilikUid,
        'namaPemilik': namaPemilik,
        'hargaSepakat': hargaInt,
      });

      // 4. Update status penawaran yang diterima → 'diterima'
      await FirebaseFirestore.instance
          .collection('penawaran')
          .doc(penawaranId)
          .update({'status': 'diterima'});

      // 5. Tolak semua penawaran lain dari permintaan yang sama (selain yang diterima)
      final semuaPenawaran = await FirebaseFirestore.instance
          .collection('penawaran')
          .where('permintaanId', isEqualTo: permintaanId)
          .where('status', isEqualTo: 'menunggu')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in semuaPenawaran.docs) {
        if (doc.id != penawaranId) {
          // Tandai ditolak
          batch.update(doc.reference, {'status': 'ditolak'});

          // Kirim notifikasi "Ditolak" ke pemilik lain
          final pemilikLainUid =
              (doc.data() as Map<String, dynamic>)['pemilikUid'] ?? '';
          if (pemilikLainUid.isNotEmpty) {
            final notifRef =
                FirebaseFirestore.instance.collection('notifikasi').doc();
            batch.set(notifRef, {
              'uid': pemilikLainUid,
              'judul': 'Tawaran Anda Ditolak',
              'pesan':
                  'Maaf, pelanggan memilih penawaran dari pemilik sumur lain.',
              'tipe': 'ditolak',
              'isUnread': true,
              'permintaanId': permintaanId,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }
      await batch.commit();

      // 6. ✅ Notifikasi ke PEMILIK yang DITERIMA
      await FirebaseFirestore.instance.collection('notifikasi').add({
        'uid': pemilikUid,
        'judul': '🎉 Tawaran Anda Diterima!',
        'pesan':
            'Pelanggan menerima tawaran harga Anda sebesar Rp ${_formatRupiah(hargaInt)}. Segera kirimkan $jumlahAir liter air!',
        'tipe': 'disetujui',
        'isUnread': true,
        'permintaanId': permintaanId,
        'transaksiId': transaksiRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      Navigator.pop(context); // tutup loading

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DetailTransaksiPelangganPage(transaksiId: transaksiRef.id),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // tutup loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menerima penawaran: $e')),
      );
    }
  }

  // ── Logika TOLAK penawaran ─────────────────────────────────────────────────
  void _tolakPenawaran(
    BuildContext context,
    String penawaranId,
    String pemilikUid,
    String namaPemilik,
  ) async {
    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF2C6B6F))),
    );

    try {
      // 1. Update status penawaran → 'ditolak'
      await FirebaseFirestore.instance
          .collection('penawaran')
          .doc(penawaranId)
          .update({'status': 'ditolak'});

      // 2. Cek apakah masih ada penawaran lain yang 'menunggu'
      final sisaPenawaran = await FirebaseFirestore.instance
          .collection('penawaran')
          .where('permintaanId', isEqualTo: permintaanId)
          .where('status', isEqualTo: 'menunggu')
          .get();

      // 3. Kalau tidak ada lagi penawaran menunggu → kembalikan status ke 'menunggu'
      if (sisaPenawaran.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('permintaan')
            .doc(permintaanId)
            .update({'status': 'menunggu'});
      }

      // 4. ✅ Notifikasi ke PEMILIK yang DITOLAK
      await FirebaseFirestore.instance.collection('notifikasi').add({
        'uid': pemilikUid,
        'judul': 'Tawaran Anda Ditolak',
        'pesan':
            'Maaf, pelanggan menolak tawaran harga Anda. Anda dapat menawar kembali jika permintaan masih tersedia.',
        'tipe': 'ditolak',
        'isUnread': true,
        'permintaanId': permintaanId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      Navigator.pop(context); // tutup loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Penawaran berhasil ditolak.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // tutup loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menolak penawaran: $e')),
      );
    }
  }
}