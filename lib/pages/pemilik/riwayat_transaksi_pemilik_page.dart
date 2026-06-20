import 'package:flutter/material.dart';
import 'detail_transaksi_pemilik_page.dart';

class RiwayatTransaksiPemilikPage extends StatelessWidget {
  const RiwayatTransaksiPemilikPage({super.key});

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
          title: const Text('Transaksi Masuk', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
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
                _buildCardPemilik(
                  context,
                  namaPelanggan: 'Budi Santoso',
                  jumlahAir: '1000 Liter',
                  hargaDiterima: 'Rp 45.000',
                  waktu: '7 Mei 2026, 14:30',
                  status: 'Sedang Dikirim',
                  statusColor: Colors.orange,
                  avatar: '👨🏽',
                  primaryTeal: primaryTeal,
                ),
              ],
            ),

            // Tab Selesai
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCardPemilik(
                  context,
                  namaPelanggan: 'Siti Nurhaliza',
                  jumlahAir: '800 Liter',
                  hargaDiterima: 'Rp 38.000',
                  waktu: '5 Mei 2026, 10:00',
                  status: 'Selesai',
                  statusColor: Colors.green,
                  avatar: '🧕🏼',
                  primaryTeal: primaryTeal,
                ),
                _buildCardPemilik(
                  context,
                  namaPelanggan: 'Ahmad Rizki',
                  jumlahAir: '500 Liter',
                  hargaDiterima: 'Rp 22.000',
                  waktu: '3 Mei 2026, 09:15',
                  status: 'Selesai',
                  statusColor: Colors.green,
                  avatar: '👦🏻',
                  primaryTeal: primaryTeal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPemilik(
    BuildContext context, {
    required String namaPelanggan,
    required String jumlahAir,
    required String hargaDiterima,
    required String waktu,
    required String status,
    required Color statusColor,
    required String avatar,
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
              // Avatar emoji pelanggan
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(avatar, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(namaPelanggan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                  Text(hargaDiterima, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryTeal)),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Label pendapatan
              Row(
                children: [
                  Icon(Icons.attach_money, size: 14, color: Colors.grey[400]),
                  Text('Pendapatan kamu dari transaksi ini', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailTransaksiPemilikPage()));
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