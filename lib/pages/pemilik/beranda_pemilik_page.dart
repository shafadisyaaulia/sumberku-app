import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tawar_harga_page.dart';
import '../landing_page.dart';
import 'profil_pemilik_page.dart';
import 'notifikasi_pemilik_page.dart';
import 'riwayat_transaksi_pemilik_page.dart';

class BerandaPemilikPage extends StatefulWidget {
  const BerandaPemilikPage({super.key});

  @override
  State<BerandaPemilikPage> createState() => _BerandaPemilikPageState();
}

class _BerandaPemilikPageState extends State<BerandaPemilikPage> {
  final Color primaryTeal = const Color(0xFF2C6B6F);
  String namaPemilik = '';
  String kecamatanPemilik = '';
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadDataPemilik();
  }

  String _formatRupiah(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Future<void> _loadDataPemilik() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists && mounted) {
      setState(() {
        namaPemilik = doc.data()?['nama'] ?? 'Pemilik Sumur';
        kecamatanPemilik = doc.data()?['kecamatan'] ?? '';
        isLoadingUser = false;
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Keluar',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
            child: const Text('Keluar',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Terima Langsung (tanpa tawar) ─────────────────────────────────────────
  void _terimaLangsung(BuildContext context, Map<String, dynamic> item) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Terima Permintaan?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Anda akan menerima permintaan ${item['jumlahAir'] ?? 0} liter dari ${item['namaPelanggan'] ?? 'Pelanggan'}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C6B6F),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _prosesTerimeLangsung(context, item, uid);
            },
            child:
                const Text('Ya, Terima', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _prosesTerimeLangsung(
      BuildContext context, Map<String, dynamic> item, String uid) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF2C6B6F))),
    );

    try {
      // ✅ Ambil nama & kecamatan pemilik FRESH dari Firestore
      // Tidak pakai variable state supaya tidak pernah kosong/salah
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final namaPemilikFresh = userDoc.data()?['nama'] ?? 'Pemilik Sumur';
      final kecamatanFresh = userDoc.data()?['kecamatan'] ?? '';

      final permintaanId = item['id'];
      final int harga = item['harga'] ?? 0;

      // Update permintaan → 'diproses'
      await FirebaseFirestore.instance
          .collection('permintaan')
          .doc(permintaanId)
          .update({
        'status': 'diproses',
        'pemilikUid': uid,
        'namaPemilik': namaPemilikFresh,
        'hargaSepakat': harga,
      });

      // Buat transaksi jika belum ada
      final existingTransaksi = await FirebaseFirestore.instance
          .collection('transaksi')
          .where('permintaanId', isEqualTo: permintaanId)
          .get();

      if (existingTransaksi.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('transaksi').add({
          'permintaanId': permintaanId,
          'pemilikUid': uid,
          'pelangganUid': item['pelangganUid'] ?? '',
          'namaPemilik': namaPemilikFresh,
          'namaPelanggan': item['namaPelanggan'] ?? '',
          'harga': harga,
          'jumlahAir': item['jumlahAir'] ?? 0,
          'alamat': item['alamat'] ?? '',
          'kecamatan': kecamatanFresh,
          'status': 'aktif',
          'qrCode': 'SUMBERKU-${DateTime.now().millisecondsSinceEpoch}',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Notif ke pelanggan
      await FirebaseFirestore.instance.collection('notifikasi').add({
        'uid': item['pelangganUid'],
        'judul': 'Permintaan Diproses!',
        'pesan':
            '$namaPemilikFresh sedang memproses permintaan ${item['jumlahAir']} liter air Anda.',
        'tipe': 'disetujui',
        'isUnread': true,
        'permintaanId': permintaanId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Notif ke pemilik sendiri
      await FirebaseFirestore.instance.collection('notifikasi').add({
        'uid': uid,
        'judul': 'Permintaan Diterima',
        'pesan':
            'Kamu telah menerima permintaan dari ${item['namaPelanggan'] ?? 'Pelanggan'}. Segera kirimkan air!',
        'tipe': 'disetujui',
        'isUnread': true,
        'permintaanId': permintaanId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      Navigator.pop(context); // tutup loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Permintaan diterima! Silahkan kirim air ke pelanggan.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // tutup loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }

  void _lihatDetail(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DetailPermintaanSheet(item: item),
    );
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'profil') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfilPemilikPage()));
            } else if (value == 'keluar') {
              _showLogoutDialog(context);
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'profil',
              child: Row(children: [
                Icon(Icons.person_outline, color: Colors.black54),
                SizedBox(width: 12),
                Text('Profil Saya'),
              ]),
            ),
            const PopupMenuItem<String>(
              value: 'keluar',
              child: Row(children: [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 12),
                Text('Keluar', style: TextStyle(color: Colors.red)),
              ]),
            ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selamat Datang,',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(
                    isLoadingUser ? '...' : namaPemilik,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            ],
          ),
        ),
        actions: [
          uid == null
              ? const SizedBox()
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifikasi')
                      .where('uid', isEqualTo: uid)
                      .where('isUnread', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    bool adaNotifBaru =
                        snapshot.hasData && snapshot.data!.docs.isNotEmpty;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded,
                              color: Colors.black87, size: 26),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NotifikasiPemilikPage()),
                            );
                          },
                        ),
                        if (adaNotifBaru)
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(
                    isLoadingUser
                        ? 'Memuat wilayah...'
                        : 'Wilayah Tugas: $kecamatanPemilik',
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RiwayatPemilikPage()),
                      );
                    },
                    child: _buildStatCard('Transaksi', 'Sedang Berjalan',
                        Icons.loop_rounded, const Color(0xFFE67E22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                      'Sumur', 'Sumber Air', Icons.water, const Color(0xFF27AE60)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Permintaan Air di Sekitarmu',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            uid == null || kecamatanPemilik.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('permintaan')
                        .where('kecamatan', isEqualTo: kecamatanPemilik)
                        .where('status', whereIn: [
                          'menunggu',
                          'ada_penawaran',
                        ])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'Belum ada permintaan air di wilayah $kecamatanPemilik.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        );
                      }

                      final dataDocs = snapshot.data!.docs;
                      return Column(
                        children: dataDocs.map((doc) {
                          final item =
                              doc.data() as Map<String, dynamic>;
                          item['id'] = doc.id;
                          return _buildPermintaanCard(
                              context, item, primaryTeal, uid);
                        }).toList(),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: Colors.grey[400], fontSize: 10)),
                const SizedBox(height: 2),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Card permintaan dengan cek sudahDitawar per pemilik ──────────────────
  Widget _buildPermintaanCard(BuildContext context, Map<String, dynamic> item,
      Color primaryTeal, String uid) {
    final int harga = item['harga'] ?? 0;
    final int jumlahAir = item['jumlahAir'] ?? 0;
    final String namaPelanggan = item['namaPelanggan'] ?? 'Pelanggan';
    final String kecamatan = item['kecamatan'] ?? 'Banda Aceh';
    final String metode = item['metodePembayaran'] ?? '-';
    final String permintaanId = item['id'];

    // ✅ StreamBuilder khusus untuk cek penawaran MILIK pemilik ini saja
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('penawaran')
          .doc('${permintaanId}_$uid')
          .snapshots(),
      builder: (context, penawaranSnap) {
        // sudahDitawar = true hanya kalau pemilik INI sudah nawar DAN statusnya masih 'menunggu'
        // kalau status 'ditolak' → false → tombol tawar/terima muncul lagi
        bool sudahDitawar = false;
        int hargaTawaranSaya = 0;
        if (penawaranSnap.hasData && penawaranSnap.data!.exists) {
          final pData =
              penawaranSnap.data!.data() as Map<String, dynamic>;
          sudahDitawar = pData['status'] == 'menunggu';
          hargaTawaranSaya = pData['harga'] ?? 0;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
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
                    child: Icon(Icons.person, color: Color(0xFF2C6B6F)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(namaPelanggan,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.water_drop_outlined,
                                size: 12, color: Colors.grey[400]),
                            Text(' $jumlahAir L',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600])),
                            Text('  •  ',
                                style:
                                    TextStyle(color: Colors.grey[400])),
                            Icon(Icons.location_on,
                                size: 12, color: Colors.grey[400]),
                            Expanded(
                              child: Text(' $kecamatan',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      overflow: TextOverflow.ellipsis)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Harga Tawar',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey[500])),
                      Text(
                        'Rp ${_formatRupiah(harga)}',
                        style: const TextStyle(
                            color: Color(0xFF2C6B6F),
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                      Text(metode,
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey[500])),
                    ],
                  ),
                ],
              ),

              // ✅ Banner status sesuai kondisi pemilik ini
              if (sudahDitawar) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_top,
                          size: 14, color: Colors.orange[700]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Menunggu konfirmasi pelanggan • Tawaran Anda: Rp ${_formatRupiah(hargaTawaranSaya)}',
                          style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => _lihatDetail(context, item),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  child: Text('Lihat Detail Permintaan',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          decoration: TextDecoration.underline)),
                ),
              ),
              const SizedBox(height: 8),

              // ✅ Tombol hanya muncul kalau BELUM nawar atau tawaran DITOLAK
              if (!sudahDitawar)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryTeal),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      TawarHargaPage(pelanggan: item)));
                        },
                        child: Text('Tawar Harga',
                            style: TextStyle(
                                color: primaryTeal,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () =>
                            _terimaLangsung(context, item),
                        child: const Text('Terima',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Bottom sheet detail permintaan ────────────────────────────────────────────
class _DetailPermintaanSheet extends StatelessWidget {
  final Map<String, dynamic> item;

  const _DetailPermintaanSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Detail Permintaan Air',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDetailRow(
              Icons.person, 'Pelanggan', item['namaPelanggan'] ?? '-'),
          _buildDetailRow(Icons.water_drop, 'Jumlah Air',
              '${item['jumlahAir'] ?? 0} Liter'),
          _buildDetailRow(Icons.attach_money, 'Harga Ditawarkan',
              'Rp ${item['harga'] ?? 0}'),
          _buildDetailRow(Icons.payment, 'Metode Bayar',
              item['metodePembayaran'] ?? '-'),
          _buildDetailRow(Icons.location_on, 'Kecamatan',
              '${item['kecamatan'] ?? '-'}, Banda Aceh'),
          _buildDetailRow(
              Icons.home, 'Alamat', item['alamat'] ?? '-'),
          if (item['catatan'] != null &&
              item['catatan'].toString().isNotEmpty)
            _buildDetailRow(
                Icons.notes, 'Catatan', item['catatan']),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2C6B6F)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}