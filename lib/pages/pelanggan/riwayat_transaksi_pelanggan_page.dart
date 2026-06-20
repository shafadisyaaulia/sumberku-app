import 'package:flutter/material.dart';
import 'detail_transaksi_pelanggan_page.dart';

class RiwayatTransaksiPelangganPage extends StatelessWidget {
  const RiwayatTransaksiPelangganPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text('Transaksi Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          bottom: const TabBar(
            labelColor: primaryTeal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryTeal,
            tabs: [
              Tab(text: 'Aktif'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Aktif
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCardPelanggan(
                  context,
                  nama: 'Sumur Pak Anto',
                  jumlahAir: '1000 Liter',
                  harga: 'Rp 45.000',
                  waktu: '7 Mei 2026, 14:30',
                  status: 'Sedang Dikirim',
                  statusColor: Colors.orange,
                  primaryTeal: primaryTeal,
                ),
              ],
            ),

            // Tab Selesai
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCardPelanggan(
                  context,
                  nama: 'Sumur Bu Siti',
                  jumlahAir: '800 Liter',
                  harga: 'Rp 38.000',
                  waktu: '5 Mei 2026, 10:00',
                  status: 'Selesai',
                  statusColor: Colors.green,
                  primaryTeal: primaryTeal,
                ),
                _buildCardPelanggan(
                  context,
                  nama: 'Sumur Pak Budi',
                  jumlahAir: '1200 Liter',
                  harga: 'Rp 50.000',
                  waktu: '3 Mei 2026, 09:15',
                  status: 'Selesai',
                  statusColor: Colors.green,
                  primaryTeal: primaryTeal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPelanggan(
    BuildContext context, {
    required String nama,
    required String jumlahAir,
    required String harga,
    required String waktu,
    required String status,
    required Color statusColor,
    required Color primaryTeal,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFE8F2F2),
                child: const Icon(Icons.water_drop, color: Color(0xFF2C6B6F)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.water_drop_outlined, size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(jumlahAir, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(waktu, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(harga, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2C6B6F))),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailTransaksiPelangganPage()));
                },
                child: Text('Lihat Detail', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}