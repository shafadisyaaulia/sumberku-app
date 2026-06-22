import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TawarHargaPage extends StatefulWidget {
  final Map<String, dynamic> pelanggan;

  const TawarHargaPage({super.key, required this.pelanggan});

  @override
  State<TawarHargaPage> createState() => _TawarHargaPageState();
}

class _CenterTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue;
  }
}

class _TawarHargaPageState extends State<TawarHargaPage> {
  final TextEditingController _hargaController = TextEditingController();
  bool _isValid = false;

  static const Color primaryTeal = Color(0xFF2C6B6F);

  @override
  void initState() {
    super.initState();
    _hargaController.addListener(_validate);
  }

  void _validate() {
    final text = _hargaController.text.trim();
    final val = int.tryParse(text);
    setState(() {
      // Bebas tawar berapa saja tanpa batas harga maksimal
      _isValid = val != null && val > 0;
    });
  }

  @override
  void dispose() {
    _hargaController.dispose();
    super.dispose();
  }

  String _formatRupiah(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final pelanggan = widget.pelanggan;
    final int hargaMaks = pelanggan['hargaMaksimal'] ?? pelanggan['harga'] ?? 0;
    final int jumlahAir = pelanggan['jumlahAir'] ?? 0;
    final String namaPelanggan = pelanggan['pelangganNama'] ?? pelanggan['namaPelanggan'] ?? 'Pelanggan';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tawar Harga', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informasi Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[700])),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: const Text('👨🏽', style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(namaPelanggan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Kecamatan: ${pelanggan['kecamatan'] ?? '-'}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.water_drop_outlined, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text('Jumlah Air', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ]),
                      Text('$jumlahAir Liter', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.attach_money, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text('Harga Maksimal', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ]),
                      Text(
                        'Rp ${_formatRupiah(hargaMaks)}',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Harga Penawaran Anda (Rp)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CenterTextFormatter()],
              decoration: InputDecoration(
                hintText: 'Contoh: 45000',
                hintStyle: TextStyle(color: Colors.grey[400]),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryTeal)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Masukkan harga penawaran terbaik Anda (bebas tanpa batas maksimal)',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
            const SizedBox(height: 16),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isValid ? primaryTeal : Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isValid
                    ? () async {
                        final uidPemilik = FirebaseAuth.instance.currentUser?.uid;
                        if (uidPemilik == null) return;

                        // Tampilkan loading indicator sebentar agar aman
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator(color: primaryTeal)),
                        );

                        try {
                          final userDoc = await FirebaseFirestore.instance.collection('users').doc(uidPemilik).get();
                          final namaPemilik = userDoc.data()?['nama'] ?? 'Pemilik Sumur';
                          final permintaanId = pelanggan['id'] ?? pelanggan['permintaanId'];

                          // 1. Simpan data penawaran ke subcollection
                          final refPenawaran = FirebaseFirestore.instance
                              .collection('permintaan')
                              .doc(permintaanId)
                              .collection('penawaran')
                              .doc(uidPemilik); // Pakai UID pemilik sebagai ID biar tidak double kirim

                          await refPenawaran.set({
                            'id': uidPemilik,
                            'pemilikUid': uidPemilik,
                            'pemilikNama': namaPemilik,
                            'hargaTawaran': int.parse(_hargaController.text.trim()),
                            'status': 'menunggu',
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          // 2. Update status penawaran utama di permintaan menjadi 'menunggu_konfirmasi'
                          await FirebaseFirestore.instance.collection('permintaan').doc(permintaanId).update({
                            'status': 'menunggu_konfirmasi',
                          });

                          if (!mounted) return;
                          Navigator.pop(context); // Tutup loading dialog
                          Navigator.pop(context); // Kembali ke Beranda utama

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Penawaran harga berhasil dikirim!')),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          Navigator.pop(context); // Tutup loading dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal mengirim penawaran: $e')),
                          );
                        }
                      }
                    : null,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Kirim Penawaran',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}