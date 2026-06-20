import 'package:flutter/material.dart';

class NotifikasiPelangganPage extends StatelessWidget {
  const NotifikasiPelangganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Notifikasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotifItem(
            'Penawaran Masuk!',
            'Sumur Pak Anto menawarkan harga Rp 45.000 untuk 1000L air Anda',
            '2 menit yang lalu',
            Icons.local_offer,
            Colors.blue,
            isUnread: true,
          ),
          _buildNotifItem(
            'Penawaran Masuk!',
            'Sumur Bu Siti menawarkan harga Rp 48.000 untuk 1000L air Anda',
            '5 menit yang lalu',
            Icons.local_offer,
            Colors.blue,
            isUnread: true,
          ),
          _buildNotifItem(
            'Air Sedang Dikirim',
            'Sumur Pak Anto sedang dalam perjalanan menuju lokasi Anda',
            '1 jam yang lalu',
            Icons.local_shipping,
            Colors.orange,
          ),
          _buildNotifItem(
            'Pesanan Selesai',
            'Pesanan 800L air dari Sumur Bu Siti telah selesai. Beri rating yuk!',
            '5 Mei 2026',
            Icons.check_circle,
            Colors.green,
          ),
          _buildNotifItem(
            'Permintaan Kadaluarsa',
            'Permintaan 200L air Anda tidak mendapat penawaran. Coba ajukan lagi.',
            '3 Mei 2026',
            Icons.timer_off,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildNotifItem(
    String title,
    String body,
    String time,
    IconData icon,
    Color iconColor, {
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFE8F2F2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isUnread ? Border.all(color: const Color(0xFF2C6B6F).withOpacity(0.3)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFF2C6B6F), shape: BoxShape.circle),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
      ),
    );
  }
}