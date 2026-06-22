import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PermintaanAirPage extends StatefulWidget {
  const PermintaanAirPage({super.key});

  @override
  State<PermintaanAirPage> createState() => _PermintaanAirPageState();
}

class _PermintaanAirPageState extends State<PermintaanAirPage> {
  String _metodePembayaran = 'Tunai';
  final Color primaryTeal = const Color(0xFF2C6B6F);
  final jumlahCtrl = TextEditingController();
  final hargaCtrl = TextEditingController();
  final catatanCtrl = TextEditingController();
  bool isLoading = false;

  void _kirimPermintaan() async {
    if (jumlahCtrl.text.isEmpty || hargaCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah air dan harga wajib diisi!')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Ambil data user dari Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final namaPelanggan = userDoc.data()?['nama'] ?? '';
      final kecamatan = userDoc.data()?['kecamatan'] ?? '';
      final alamat = userDoc.data()?['alamat'] ?? '';

      // Simpan permintaan ke Firestore
      final permintaanRef = await FirebaseFirestore.instance
          .collection('permintaan')
          .add({
        'pelangganUid': uid,
        'namaPelanggan': namaPelanggan,
        'kecamatan': kecamatan,
        'alamat': alamat,
        'kota': 'Banda Aceh',
        'jumlahAir': int.tryParse(jumlahCtrl.text) ?? 0,
        'harga': int.tryParse(hargaCtrl.text) ?? 0,
        'metodePembayaran': _metodePembayaran,
        'catatan': catatanCtrl.text.trim(),
        'status': 'menunggu',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Kirim notifikasi ke semua pemilik sumur di kecamatan yang sama
      final pemilikDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('peran', isEqualTo: 'Pemilik')
          .where('kecamatan', isEqualTo: kecamatan)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final pemilik in pemilikDocs.docs) {
        final notifRef =
            FirebaseFirestore.instance.collection('notifikasi').doc();
        batch.set(notifRef, {
          'uid': pemilik.id,
          'judul': 'Permintaan Air Baru!',
          'pesan':
              '$namaPelanggan membutuhkan ${jumlahCtrl.text} liter air di $kecamatan',
          'tipe': 'permintaan_baru',
          'isUnread': true,
          'permintaanId': permintaanRef.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Permintaan air berhasil dikirim!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim permintaan: $e')),
      );
    }
  }

  @override
  void dispose() {
    jumlahCtrl.dispose();
    hargaCtrl.dispose();
    catatanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryTeal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ajukan Permintaan Air',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jumlah Air (Liter)',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: jumlahCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.opacity, color: primaryTeal),
                hintText: 'Contoh: 1000',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Harga Penawaran (Rp)',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: hargaCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon:
                    Icon(Icons.attach_money, color: primaryTeal),
                hintText: 'Contoh: 50000',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            Text(
                'Masukkan harga maksimal yang Anda tawarkan',
                style:
                    TextStyle(color: Colors.grey[500], fontSize: 11)),
            const SizedBox(height: 20),

            const Text('Metode Pembayaran',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Tunai',
                        style: TextStyle(fontSize: 14)),
                    value: 'Tunai',
                    groupValue: _metodePembayaran,
                    activeColor: primaryTeal,
                    onChanged: (value) =>
                        setState(() => _metodePembayaran = value!),
                  ),
                  Divider(height: 1, color: Colors.grey[200]),
                  RadioListTile<String>(
                    title: const Text('Transfer Bank',
                        style: TextStyle(fontSize: 14)),
                    value: 'Transfer Bank',
                    groupValue: _metodePembayaran,
                    activeColor: primaryTeal,
                    onChanged: (value) =>
                        setState(() => _metodePembayaran = value!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Catatan Tambahan',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: catatanCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Contoh: Mohon kirim sebelum jam 5 sore...',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isLoading ? null : _kirimPermintaan,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Kirim Permintaan →',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}