import 'package:flutter/material.dart';
import 'detail_transaksi_pemilik_page.dart';
import 'main_navigation_pemilik.dart';

class PenawaranDiterimaPage extends StatelessWidget {
  final Map<String, dynamic> pelanggan;
  final int hargaPenawaran;

  const PenawaranDiterimaPage({super.key, required this.pelanggan, required this.hargaPenawaran});

  String _formatRupiah(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Icon sukses
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
              ),
              const SizedBox(height: 20),
              const Text('Penawaran Diterima!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Pelanggan telah menerima penawaran Anda',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Detail card
              Container(
                width: double.infinity,
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
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(pelanggan['avatar'], style: const TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pelanggan['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('${pelanggan['jarakKm']} km dari lokasi Anda', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Jumlah Air', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        Text('${pelanggan['jumlahAir']} Liter', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Harga', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        Text(
                          'Rp ${_formatRupiah(hargaPenawaran)}',
                          style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Tombol aksi
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailTransaksiPemilikPage()));
                  },
                  child: const Text('Lihat Detail Transaksi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavigationPemilik()),
                      (route) => false,
                    );
                  },
                  child: Text('Kembali ke Beranda', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}