import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Notifikasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotifItem('Permintaan Baru', 'Budi Santoso mengajukan permintaan 1000L air', '2 menit yang lalu', Icons.water_drop, Colors.blue),
          _buildNotifItem('Penawaran Diterima', 'Siti Nurhaliza menerima penawaran Anda', '1 jam yang lalu', Icons.check_circle, Colors.green),
          _buildNotifItem('Pembayaran Diterima', 'Rp 45.000 telah masuk ke rekening Anda', '3 jam yang lalu', Icons.monetization_on, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildNotifItem(String title, String body, String time, IconData icon, Color iconColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: iconColor.withOpacity(0.1), child: Icon(icon, color: iconColor)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}