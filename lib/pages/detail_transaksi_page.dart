import 'package:flutter/material.dart';
import 'pesan_page.dart';

class DetailTransaksiPage extends StatelessWidget {
  const DetailTransaksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    Color primaryTeal = const Color(0xFF2C6B6F);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Detail Transaksi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Tracker widget
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStepTracker('Permintaan', true),
                  _buildStepTracker('Diterima', true),
                  _buildStepTracker('Di Jalan', false),
                  _buildStepTracker('Selesai', false),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info Pemilik Sumur
            const Text('Informasi Pemilik Sumur', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        CircleAvatar(child: Icon(Icons.person)),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sumur Pak Anto', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('★ 4.8 • 0.5 km', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(icon: Icon(Icons.phone, color: primaryTeal), onPressed: () {}),
                        IconButton(
                          icon: Icon(Icons.chat, color: primaryTeal),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const PesanPage()));
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rincian Pesanan
            const Text('Detail Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Jumlah Air'), Text('1000 Liter', style: TextStyle(fontWeight: FontWeight.bold))]),
                  SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total Harga'), Text('Rp 45.000', style: TextStyle(fontWeight: FontWeight.bold))]),
                  SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Waktu'), Text('7 Mei 2026, 14:30', style: TextStyle(color: Colors.grey))]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStepTracker(String label, bool isDone) {
    return Column(
      children: [
        Icon(isDone ? Icons.check_circle : Icons.radio_button_off, color: isDone ? const Color(0xFF2C6B6F) : Colors.grey),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isDone ? Colors.black : Colors.grey, fontWeight: isDone ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}