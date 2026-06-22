import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'penawaran_diterima_page.dart';
import 'main_navigation_pemilik.dart';

class MenungguPage extends StatefulWidget {
  final Map<String, dynamic> pelanggan;
  final int hargaPenawaran;

  const MenungguPage({super.key, required this.pelanggan, required this.hargaPenawaran});

  @override
  State<MenungguPage> createState() => _MenungguPageState();
}

class _MenungguPageState extends State<MenungguPage> with SingleTickerProviderStateMixin {
  late AnimationController _dotController;
  String? idPenawaranSaya;
  bool sudahKirimKeFirebase = false;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    _kirimPenawaranKeFirebase();
  }

  Future<void> _kirimPenawaranKeFirebase() async {
    final uidPemilik = FirebaseAuth.instance.currentUser?.uid;
    if (uidPemilik == null) return;

    // Mengambil profil nama pemilik sumur dari firestore
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uidPemilik).get();
    final namaPemilik = userDoc.data()?['nama'] ?? 'Pemilik Sumur';

    final permintaanId = widget.pelanggan['id'];

    // Membuat dokumen penawaran baru di dalam permintaan air pelanggan terkait
    final refPenawaran = FirebaseFirestore.instance
        .collection('permintaan')
        .doc(permintaanId)
        .collection('penawaran')
        .doc(); 

    idPenawaranSaya = refPenawaran.id;

    await refPenawaran.set({
      'id': idPenawaranSaya,
      'pemilikUid': uidPemilik,
      'pemilikNama': namaPemilik,
      'hargaTawaran': widget.hargaPenawaran,
      'status': 'menunggu', // Status awal penawaran
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Perbarui status utama permintaan menjadi 'ada_penawaran' agar beranda pelanggan tahu
    await FirebaseFirestore.instance.collection('permintaan').doc(permintaanId).update({
      'status': 'ada_penawaran',
    });

    if (mounted) {
      setState(() {
        sudahKirimKeFirebase = true;
      });
    }
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permintaanId = widget.pelanggan['id'];

    if (!sudahKirimKeFirebase || idPenawaranSaya == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // STREAM REALTIME: Pantau nasib penawaran dari tanggapan aksi pelanggan
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('permintaan')
          .doc(permintaanId)
          .collection('penawaran')
          .doc(idPenawaranSaya)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final dataPenawaran = snapshot.data!.data() as Map<String, dynamic>;
          final statusPenawaran = dataPenawaran['status'] ?? 'menunggu';

          // KONDISI 1: JIKA DITERIMA PELANGGAN
          if (statusPenawaran == 'diterima') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PenawaranDiterimaPage(
                    pelanggan: widget.pelanggan,
                    hargaPenawaran: widget.hargaPenawaran,
                    permintaanId: permintaanId,
                  ),
                ),
              );
            });
          }
          
          // KONDISI 2: JIKA HANGUS (Pelanggan memilih driver/pemilik sumur lain)
          if (statusPenawaran == 'hangus') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showHangusDialog(context);
            });
          }
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                    child: const Icon(Icons.access_time, size: 50, color: Colors.grey),
                  ),
                  const SizedBox(height: 28),
                  const Text('Menunggu Pelanggan...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    'Penawaran sebesar Rp ${widget.hargaPenawaran} berhasil dikirim.\nMenunggu konfirmasi pemesanan dari pelanggan...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  _buildAnimatedDots(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHangusDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Penawaran Hangus', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Wah, pelanggan telah menerima penawaran dari pemilik sumur lain. Tetap semangat dan coba lagi pada orderan berikutnya!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigationPemilik()),
                (route) => false,
              );
            },
            child: const Text('Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C6B6F))),
          )
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final opacity = (((_dotController.value - delay) % 1.0 + 1.0) % 1.0 > 0.5) ? 1.0 : 0.3;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF2C6B6F).withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}