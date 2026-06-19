import 'package:flutter/material.dart';

class RiwayatTransaksiPage extends StatelessWidget {
  const RiwayatTransaksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    Color primaryTeal = const Color(0xFF2C6B6F);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Transaksi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          bottom: TabBar(
            labelColor: primaryTeal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryTeal,
            tabs: const [
              Tab(text: 'Aktif'),
              Tab(text: 'Selesai'),
            ],
          ),
          elevation: 1,
        ),
        body: TabBarView(
          children: [
            // Tab Pesanan Aktif
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCardTransaksi('Sumur Pak Anto', '1000 L • Sedang Dikirim', 'Rp 45.000', Colors.orange),
              ],
            ),
            // Tab Selesai
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCardTransaksi('Sumur Bu Siti', '800 L • 5 Mei 2026', 'Rp 38.000', Colors.green),
                _buildCardTransaksi('Sumur Pak Budi', '1200 L • 3 Mei 2026', 'Rp 50.000', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTransaksi(String title, String subtitle, String price, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
            )
          ],
        ),
      ),
    );
  }
}