import 'package:flutter/material.dart';
import 'permintaan_air_page.dart';
import 'penawaran_masuk_page.dart'; // PENTING: Mengatasi error 'PenawaranMasukPage isn't defined'

class BerandaPelangganPage extends StatelessWidget {
  const BerandaPelangganPage({super.key});

  @override
  Widget build(BuildContext context) {
    Color primaryTeal = const Color(0xFF2C6B6F);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat Datang,', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const Text('Budi Santoso', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: primaryTeal),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: primaryTeal, size: 16),
                const SizedBox(width: 4),
                Text('Jl. Merdeka No. 123, Jakarta', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryTeal, const Color(0xFF1E4648)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Butuh Air?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ajukan permintaan air dan dapatkan penawaran terbaik dari pemilik sumur terdekat.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PermintaanAirPage()),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajukan Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Permintaan Aktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: Text('Lihat Semua', style: TextStyle(color: primaryTeal))),
              ],
            ),
            const SizedBox(height: 8),

            _buildPermintaanCard(context, primaryTeal, '200 Liter Air Bersih', 'Menunggu Penawaran', '15 Menit', '2.3 km dari Anda'),
            _buildPermintaanCard(context, primaryTeal, '500 Liter Air Bersih', '3 Penawaran Masuk', 'Aktif', '1.8 km dari Anda', isGreenStatus: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPermintaanCard(BuildContext context, Color themeColor, String title, String status, String time, String distance, {bool isGreenStatus = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: themeColor.withOpacity(0.1),
                  child: Icon(Icons.opacity, color: themeColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isGreenStatus ? Colors.green[50] : Colors.orange[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(color: isGreenStatus ? Colors.green : Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(distance, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PenawaranMasukPage()),
                    );
                  },
                  child: Text(isGreenStatus ? 'Lihat Penawaran' : 'Lihat Detail', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}