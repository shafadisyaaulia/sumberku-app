import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_navigation_pemilik.dart';

class DetailTransaksiPemilikPage extends StatefulWidget {
  final String permintaanId;

  const DetailTransaksiPemilikPage({super.key, required this.permintaanId});

  @override
  State<DetailTransaksiPemilikPage> createState() =>
      _DetailTransaksiPemilikPageState();
}

class _DetailTransaksiPemilikPageState
    extends State<DetailTransaksiPemilikPage> {
  bool _isLoading = false;

  String _formatRupiah(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  int _parseHarga(dynamic nilai) {
    if (nilai == null) return 0;
    if (nilai is int) return nilai;
    if (nilai is double) return nilai.toInt();
    final bersih = nilai.toString().replaceAll(RegExp(r'[Rp\.\s]'), '').trim();
    return int.tryParse(bersih) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Detail Transaksi',
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
      // Pakai StreamBuilder dari koleksi transaksi agar status real-time
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transaksi')
            .where('permintaanId', isEqualTo: widget.permintaanId)
            .limit(1)
            .snapshots(),
        builder: (context, snapTransaksi) {
          // Sambil menunggu transaksi, fallback ke data permintaan
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('permintaan')
                .doc(widget.permintaanId)
                .snapshots(),
            builder: (context, snapPermintaan) {
              if (snapPermintaan.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapPermintaan.hasData || !snapPermintaan.data!.exists) {
                return const Center(
                    child: Text('Data transaksi tidak ditemukan.'));
              }

              final permData =
                  snapPermintaan.data!.data() as Map<String, dynamic>;

              // Ambil status dari transaksi jika ada, fallback ke permintaan
              String status = permData['status'] ?? 'aktif';
              String? transaksiId;
              if (snapTransaksi.hasData &&
                  snapTransaksi.data!.docs.isNotEmpty) {
                final transaksiData = snapTransaksi.data!.docs.first.data()
                    as Map<String, dynamic>;
                status = transaksiData['status'] ?? status;
                transaksiId = snapTransaksi.data!.docs.first.id;
              }

              final String namaPelanggan = permData['pelangganNama'] ??
                  permData['namaPelanggan'] ??
                  'Pelanggan';
              final int jumlahAir = permData['jumlahAir'] ?? 0;
              final int hargaSepakat = _parseHarga(
                  permData['hargaSepakat'] ??
                      permData['harga'] ??
                      permData['hargaMaksimal']);
              final String catatan =
                  permData['catatan'] ?? 'Tidak ada catatan';
              final String alamat =
                  permData['alamatLengkap'] ??
                      permData['alamat'] ??
                      'Banda Aceh';

              // Status flags
              final bool isDiJalan = status == 'di_jalan';
              final bool isSelesai = status == 'selesai';
              final bool isDibatalkan = status == 'dibatalkan';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Status Tracker 4 langkah ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStep('Penawaran', true),
                          _buildDividerLine(true),
                          _buildStep('Diproses', true),
                          _buildDividerLine(isDiJalan || isSelesai),
                          _buildStep('Di Jalan', isDiJalan || isSelesai),
                          _buildDividerLine(isSelesai),
                          _buildStep('Selesai', isSelesai),
                        ],
                      ),
                    ),

                    // Banner status dibatalkan
                    if (isDibatalkan) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.red.withOpacity(0.3))),
                        child: const Row(
                          children: [
                            Icon(Icons.cancel_outlined,
                                color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Pesanan ini telah dibatalkan oleh pelanggan.',
                                style: TextStyle(
                                    color: Colors.red, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // ── Info Pelanggan ──
                    const Text('Informasi Pelanggan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const CircleAvatar(
                              backgroundColor: Color(0xFFE8F2F2),
                              child:
                                  Icon(Icons.person, color: primaryTeal)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(namaPelanggan,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Text(
                                  'Wilayah: ${permData['kecamatan'] ?? '-'}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Detail Transaksi ──
                    const Text('Detail Transaksi',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          _buildRow('Jumlah Air', '$jumlahAir Liter'),
                          const SizedBox(height: 10),
                          _buildRow('Harga Disepakati',
                              'Rp ${_formatRupiah(hargaSepakat)}',
                              valueColor: primaryTeal, valueBold: true),
                          const SizedBox(height: 10),
                          _buildRow('Metode Pembayaran', 'Tunai (COD)'),
                          const SizedBox(height: 10),
                          _buildRow(
                            'Status',
                            isSelesai
                                ? 'Selesai'
                                : isDiJalan
                                    ? 'Sedang Diantar'
                                    : isDibatalkan
                                        ? 'Dibatalkan'
                                        : 'Sedang Diproses',
                            valueColor: isSelesai
                                ? Colors.green
                                : isDiJalan
                                    ? Colors.orange
                                    : isDibatalkan
                                        ? Colors.red
                                        : Colors.amber[800],
                            valueBold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Alamat ──
                    const Text('Alamat Tujuan Pengiriman',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: primaryTeal, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(alamat,
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Catatan ──
                    const Text('Catatan dari Pelanggan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(catatan,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13)),
                    ),
                    const SizedBox(height: 24),

                    // ── Tombol Aksi ──
                    // Tombol 1: Sedang Diproses → tekan untuk ubah jadi Di Jalan
                    if (!isDiJalan && !isSelesai && !isDibatalkan)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () => _konfirmasiDiJalan(
                                  context, transaksiId),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.local_shipping,
                                  color: Colors.white, size: 18),
                          label: const Text('Mulai Antar Air',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
                      ),

                    // Tombol 2: Sedang Di Jalan → tekan untuk ubah jadi Selesai
                    if (isDiJalan && !isSelesai)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () => _konfirmasiSelesaiKirim(
                                  context, transaksiId),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.check_circle,
                                  color: Colors.white, size: 18),
                          label: const Text('Selesai Kirim Air',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Konfirmasi ubah status ke di_jalan ──
  void _konfirmasiDiJalan(BuildContext context, String? transaksiId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mulai Antar Air?'),
        content: const Text(
            'Konfirmasi bahwa kamu sudah berangkat menuju lokasi pelanggan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal',
                  style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (!mounted) return;
              setState(() => _isLoading = true);

              try {
                // Update status permintaan
                await FirebaseFirestore.instance
                    .collection('permintaan')
                    .doc(widget.permintaanId)
                    .update({'status': 'di_jalan'});

                // Update status transaksi
                if (transaksiId != null) {
                  await FirebaseFirestore.instance
                      .collection('transaksi')
                      .doc(transaksiId)
                      .update({'status': 'di_jalan'});
                } else {
                  // Fallback: query dan update semua transaksi terkait
                  final q = await FirebaseFirestore.instance
                      .collection('transaksi')
                      .where('permintaanId',
                          isEqualTo: widget.permintaanId)
                      .get();
                  for (final doc in q.docs) {
                    await doc.reference.update({'status': 'di_jalan'});
                  }
                }

                if (mounted) setState(() => _isLoading = false);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Status diperbarui: Sedang Diantar')),
                );
              } catch (e) {
                if (mounted) setState(() => _isLoading = false);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Gagal memperbarui status: $e')),
                );
              }
            },
            child: const Text('Ya, Berangkat',
                style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Konfirmasi ubah status ke selesai ──
  void _konfirmasiSelesaiKirim(
      BuildContext context, String? transaksiId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Selesai Kirim Air?'),
        content: const Text(
            'Pastikan pasokan air bersih sudah sukses disalurkan ke bak penampungan pelanggan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal',
                  style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (!mounted) return;
              setState(() => _isLoading = true);

              try {
                final uid = FirebaseAuth.instance.currentUser?.uid;

                // 1. Ambil data permintaan
                final permintaanDoc = await FirebaseFirestore.instance
                    .collection('permintaan')
                    .doc(widget.permintaanId)
                    .get();
                final permData = permintaanDoc.data() as Map<String, dynamic>? ?? {};
                final pelangganUid = permData['pelangganUid'] ??
                    permData['uid'] ??
                    '';

                // 2. Update status permintaan
                await FirebaseFirestore.instance
                    .collection('permintaan')
                    .doc(widget.permintaanId)
                    .update({'status': 'selesai'});

                // 3. Update status transaksi
                if (transaksiId != null) {
                  await FirebaseFirestore.instance
                      .collection('transaksi')
                      .doc(transaksiId)
                      .update({'status': 'selesai'});
                } else {
                  final q = await FirebaseFirestore.instance
                      .collection('transaksi')
                      .where('permintaanId',
                          isEqualTo: widget.permintaanId)
                      .get();
                  for (final doc in q.docs) {
                    await doc.reference.update({'status': 'selesai'});
                  }
                }

                // 4. Notifikasi ke pelanggan
                if (pelangganUid.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('notifikasi')
                      .add({
                    'uid': pelangganUid,
                    'judul': 'Air Telah Terkirim!',
                    'pesan':
                        'Pengiriman air sudah selesai. Terima kasih telah menggunakan layanan kami.',
                    'tipe': 'selesai',
                    'isUnread': true,
                    'permintaanId': widget.permintaanId,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                }

                // 5. Notifikasi ke pemilik sendiri
                if (uid != null) {
                  await FirebaseFirestore.instance
                      .collection('notifikasi')
                      .add({
                    'uid': uid,
                    'judul': 'Transaksi Selesai!',
                    'pesan':
                        'Pengiriman air berhasil diselesaikan. Pendapatan telah dicatat.',
                    'tipe': 'selesai',
                    'isUnread': true,
                    'permintaanId': widget.permintaanId,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                }

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Transaksi berhasil diselesaikan!')),
                );

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MainNavigationPemilik()),
                  (route) => false,
                );
              } catch (e) {
                if (mounted) setState(() => _isLoading = false);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Gagal menyelesaikan transaksi: $e')),
                );
              }
            },
            child: const Text('Ya, Selesai',
                style: TextStyle(
                    color: Color(0xFF2C6B6F),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String label, bool isDone) {
    return Column(
      children: [
        Icon(isDone ? Icons.check_circle : Icons.radio_button_off,
            color: isDone ? const Color(0xFF2C6B6F) : Colors.grey,
            size: 22),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: isDone ? Colors.black : Colors.grey,
                fontWeight:
                    isDone ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildDividerLine(bool isDone) {
    return Expanded(
        child: Container(
            height: 2,
            color: isDone
                ? const Color(0xFF2C6B6F)
                : Colors.grey[300]));
  }

  Widget _buildRow(String label, String value,
      {Color? valueColor, bool valueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                color: valueColor ?? Colors.black,
                fontWeight:
                    valueBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}