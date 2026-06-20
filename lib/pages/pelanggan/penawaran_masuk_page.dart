import 'package:flutter/material.dart';
import 'detail_transaksi_pelanggan_page.dart';

class PenawaranMasukPage extends StatelessWidget {
  const PenawaranMasukPage({super.key});

  @override
  Widget build(BuildContext context) {
    Color primaryTeal = const Color(0xFF2C6B6F);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Penawaran Masuk', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(child: Text('3 penawaran masuk. Pilih sebelum waktu habis!', style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w500))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildPenawaranCard(context, primaryTeal, 'Sumur Pak Anto', '4.8', '0.5 km', 'Rp 45.000', '00:06'),
            _buildPenawaranCard(context, primaryTeal, 'Sumur Bu Siti', '4.9', '1.2 km', 'Rp 48.000', '00:08'),
          ],
        ),
      ),
    );
  }

  Widget _buildPenawaranCard(BuildContext context, Color themeColor, String name, String rating, String distance, String price, String remainingTime) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.grey[200], child: const Icon(Icons.store, color: Colors.grey)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            Text(' $rating ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('• $distance', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Text(price, style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('Sisa waktu: $remainingTime', style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: themeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailTransaksiPelangganPage()));
                  },
                  child: const Text('✓ Terima Penawaran', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}