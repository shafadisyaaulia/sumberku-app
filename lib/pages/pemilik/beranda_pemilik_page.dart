import 'package:flutter/material.dart';
import 'tawar_harga_page.dart';
import 'detail_transaksi_pemilik_page.dart';
import '../landing_page.dart'; 
import 'profil_pemilik_page.dart'; 

class BerandaPemilikPage extends StatelessWidget {
  const BerandaPemilikPage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LandingPage()),
                (route) => false,
              );
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);

    // AVATAR SUDAH DIGANTI MENJADI MANUSIA
    final List<Map<String, dynamic>> permintaan = [
      {
        'nama': 'Budi Santoso',
        'rating': 4.8,
        'jumlahAir': 1000,
        'jarakKm': 0.8,
        'hargaMaks': 50000,
        'waktu': '5 menit lalu',
        'avatar': '👨🏽', // Emoji Pria
      },
      {
        'nama': 'Siti Nurhaliza',
        'rating': 5.0,
        'jumlahAir': 500,
        'jarakKm': 1.2,
        'hargaMaks': 40000,
        'waktu': '12 menit lalu',
        'avatar': '🧕🏼', // Emoji Wanita Berhijab
      },
      {
        'nama': 'Ahmad Rizki',
        'rating': 4.5,
        'jumlahAir': 500,
        'jarakKm': 1.5,
        'hargaMaks': 25000,
        'waktu': '18 menit lalu',
        'avatar': '👦🏻', // Emoji Pemuda
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: PopupMenuButton<String>(
          offset: const Offset(0, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'profil') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilPemilikPage()),
              );
            } else if (value == 'keluar') {
              _showLogoutDialog(context);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'profil',
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.black54),
                  SizedBox(width: 12),
                  Text('Profil Saya'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'keluar',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Keluar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selamat Datang,', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const Text('Pak Anto', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            ],
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: primaryTeal),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text('Online', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _buildStatCard('24', 'Pesanan', Icons.water_drop_outlined, primaryTeal),
                const SizedBox(width: 12),
                _buildStatCard('1.2M', 'Pendapatan', Icons.attach_money, const Color(0xFF27AE60)),
                const SizedBox(width: 12),
                _buildStatCard('4.8', 'Rating', Icons.trending_up, const Color(0xFFE67E22)),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Permintaan Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: primaryTeal, borderRadius: BorderRadius.circular(12)),
                  child: const Text('3 Baru', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...permintaan.map((item) => _buildPermintaanCard(context, item, primaryTeal)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildPermintaanCard(BuildContext context, Map<String, dynamic> item, Color primaryTeal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(item['avatar'], style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        Text(' ${item['rating']}', style: const TextStyle(fontSize: 11)),
                        Text('  •  ', style: TextStyle(color: Colors.grey[400])),
                        Icon(Icons.water_drop_outlined, size: 11, color: Colors.grey[400]),
                        Text(' ${item['jumlahAir']} L', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        Text('  •  ', style: TextStyle(color: Colors.grey[400])),
                        Icon(Icons.location_on, size: 11, color: Colors.grey[400]),
                        Text(' ${item['jarakKm']} km', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item['waktu'], style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('Maks. Harga', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  Text(
                    'Rp ${_formatRupiah(item['hargaMaks'])}',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryTeal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TawarHargaPage(pelanggan: item)));
                  },
                  child: Text('Tawar Harga', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailTransaksiPemilikPage()));
                  },
                  child: const Text('Terima', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRupiah(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}