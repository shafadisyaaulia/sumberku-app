import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'permintaan_air_page.dart';
import 'penawaran_masuk_page.dart';
import 'detail_transaksi_pelanggan_page.dart';
import 'notifikasi_pelanggan_page.dart'; // 1. PASTIKAN IMPORT INI ADA
import '../landing_page.dart';

class BerandaPelangganPage extends StatefulWidget {
  const BerandaPelangganPage({super.key});

  @override
  State<BerandaPelangganPage> createState() => _BerandaPelangganPageState();
}

class _BerandaPelangganPageState extends State<BerandaPelangganPage> {
  final Color primaryTeal = const Color(0xFF2C6B6F);
  String nama = '';
  String kecamatan = '';
  String alamat = '';
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadDataUser();
  }

  Future<void> _loadDataUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && mounted) {
      setState(() {
        nama = doc.data()?['nama'] ?? '';
        kecamatan = doc.data()?['kecamatan'] ?? '';
        alamat = doc.data()?['alamat'] ?? '';
        isLoadingUser = false;
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LandingPage()),
                (route) => false,
              );
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showKonfirmasiTawaran(BuildContext context, String permintaanId, Map<String, dynamic> data) {
    final int hargaTawar = data['harga'] ?? 0;
    final String namaPemilik = data['namaPemilik'] ?? 'Pemilik Sumur';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.local_offer, color: Colors.orange),
            SizedBox(width: 8),
            Text('Penawaran Harga', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('$namaPemilik menawarkan harga Rp $hargaTawar untuk pesanan airmu.\n\nApakah kamu setuju?'),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('permintaan').doc(permintaanId).update({
                'status': 'menunggu',
                'pemilikUid': FieldValue.delete(),
                'namaPemilik': FieldValue.delete(),
                'harga': FieldValue.delete(),
              });
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Tolak', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              await FirebaseFirestore.instance.collection('permintaan').doc(permintaanId).update({
                'status': 'diproses',
                'hargaSepakat': hargaTawar,
              });

              await FirebaseFirestore.instance.collection('transaksi').add({
                'permintaanId': permintaanId,
                'pemilikUid': data['pemilikUid'],
                'pelangganUid': uid,
                'namaPemilik': namaPemilik,
                'jumlahAir': data['jumlahAir'],
                'harga': hargaTawar,
                'status': 'diproses',
                'createdAt': FieldValue.serverTimestamp(),
              });

              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tawaran diterima! Pesanan segera diproses.')),
              );
            },
            child: const Text('Terima', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _navigasiKeDetailTransaksi(BuildContext context, String permintaanId) async {
    try {
      final q = await FirebaseFirestore.instance
          .collection('transaksi')
          .where('permintaanId', isEqualTo: permintaanId)
          .limit(1)
          .get();

      if (!context.mounted) return;

      if (q.docs.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailTransaksiPelangganPage(transaksiId: q.docs.first.id),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data transaksi belum tersedia')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka detail: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: PopupMenuButton<String>(
          offset: const Offset(0, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'keluar') _showLogoutDialog(context);
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'keluar',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Keluar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selamat Datang,', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(
                    isLoadingUser ? '...' : nama,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            ],
          ),
        ),
        actions: [
          // 2. PERBAIKAN: Sekarang kalau dipencet, langsung pindah ke Halaman Notifikasi
          IconButton(
            icon: Icon(Icons.notifications_none, color: primaryTeal),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotifikasiPelangganPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: primaryTeal, size: 16),
                const SizedBox(width: 4),
                Text(
                  isLoadingUser ? 'Memuat lokasi...' : '$kecamatan, Banda Aceh',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryTeal, const Color(0xFF1E4648)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Butuh Air?',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ajukan permintaan air dan dapatkan penawaran terbaik dari pemilik sumur terdekat.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PermintaanAirPage()),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajukan Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Permintaan Aktif',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: Text('Lihat Semua', style: TextStyle(color: primaryTeal)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            uid == null
                ? const SizedBox()
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('permintaan')
                        .where('pelangganUid', isEqualTo: uid)
                        .where('status', whereIn: ['menunggu', 'ada_penawaran', 'menunggu_konfirmasi', 'diterima', 'diproses', 'selesai'])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.water_drop_outlined, size: 40, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada permintaan aktif.\nYuk ajukan permintaan air pertamamu!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;
                      docs.sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>;
                        final bData = b.data() as Map<String, dynamic>;
                        final aTime = aData['createdAt'] as Timestamp?;
                        final bTime = bData['createdAt'] as Timestamp?;
                        if (aTime == null) return -1;
                        if (bTime == null) return 1;
                        return bTime.compareTo(aTime);
                      });

                      return Column(
                        children: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final status = data['status'] ?? 'menunggu';
                          final jumlahAir = data['jumlahAir'] ?? 0;

                          String labelStatus = 'Menunggu Penawaran';
                          Color colorStatus = Colors.orange;
                          Color bgStatus = Colors.orange[50]!;

                          if (status == 'ada_penawaran' || status == 'menunggu_konfirmasi') {
                            labelStatus = 'Penawaran Masuk';
                            colorStatus = Colors.blue;
                            bgStatus = Colors.blue[50]!;
                          } else if (status == 'diterima' || status == 'diproses') {
                            labelStatus = 'Sedang Diproses';
                            colorStatus = Colors.amber[800]!;
                            bgStatus = Colors.amber[50]!;
                          } else if (status == 'selesai') {
                            labelStatus = 'Selesai';
                            colorStatus = Colors.green;
                            bgStatus = Colors.green[50]!;
                          }

                          return _buildPermintaanCard(
                            context,
                            primaryTeal,
                            '$jumlahAir Liter Air Bersih',
                            labelStatus,
                            kecamatan.isNotEmpty ? '$kecamatan, Banda Aceh' : 'Banda Aceh',
                            textColor: colorStatus,
                            bgColor: bgStatus,
                            permintaanId: doc.id,
                            statusMentah: status,
                            dataPermintaan: data,
                          );
                        }).toList(),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermintaanCard(
    BuildContext context,
    Color themeColor,
    String title,
    String statusText,
    String lokasi, {
    required Color textColor,
    required Color bgColor,
    required String permintaanId,
    required String statusMentah,
    required Map<String, dynamic> dataPermintaan,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: themeColor.withOpacity(0.1),
                  child: Icon(Icons.water_drop, color: themeColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(lokasi, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    if (statusMentah == 'menunggu_konfirmasi') {
                      _showKonfirmasiTawaran(context, permintaanId, dataPermintaan);
                    } else if (statusMentah == 'ada_penawaran') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PenawaranMasukPage(permintaanId: permintaanId),
                        ),
                      );
                    } else if (statusMentah == 'diterima' || statusMentah == 'diproses' || statusMentah == 'selesai') {
                      _navigasiKeDetailTransaksi(context, permintaanId);
                    }
                  },
                  child: Text(
                    (statusMentah == 'ada_penawaran' || statusMentah == 'menunggu_konfirmasi')
                        ? 'Lihat Penawaran'
                        : 'Lihat Detail',
                    style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}