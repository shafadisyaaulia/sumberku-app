import 'package:flutter/material.dart';

class PermintaanAirPage extends StatefulWidget {
  const PermintaanAirPage({super.key});

  @override
  State<PermintaanAirPage> createState() => _PermintaanAirPageState();
}

class _PermintaanAirPageState extends State<PermintaanAirPage> {
  String _metodePembayaran = 'Tunai';
  final Color primaryTeal = const Color(0xFF2C6B6F);

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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Input Jumlah Air
            const Text('Jumlah Air (Liter)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.opacity, color: primaryTeal),
                hintText: 'Contoh: 1000',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Input Harga Penawaran
            const Text('Harga Penawaran (Rp)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money, color: primaryTeal),
                hintText: 'Contoh: 50000',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            Text('Masukkan harga maksimal yang Anda tawarkan', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            const SizedBox(height: 20),

            // 3. Pilihan Metode Pembayaran
            const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Tunai', style: TextStyle(fontSize: 14)),
                    value: 'Tunai',
                    groupValue: _metodePembayaran,
                    activeColor: primaryTeal,
                    onChanged: (value) => setState(() => _metodePembayaran = value!),
                  ),
                  Divider(height: 1, color: Colors.grey[200]),
                  RadioListTile<String>(
                    title: const Text('Transfer Bank', style: TextStyle(fontSize: 14)),
                    value: 'Transfer Bank',
                    groupValue: _metodePembayaran,
                    activeColor: primaryTeal,
                    onChanged: (value) => setState(() => _metodePembayaran = value!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Catatan Tambahan
            const Text('Catatan Tambahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Contoh: Mohon kirim sebelum jam 5 sore...',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Kirim Permintaan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Permintaan Air Berhasil Dikirim!')),
                  );
                  Navigator.pop(context); // Kembali ke beranda setelah kirim
                },
                child: const Text('Kirim Permintaan →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}