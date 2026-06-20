import 'package:flutter/material.dart';
import 'pesan_pelanggan_page.dart'; // nanti ganti ke ../pesan_page.dart setelah shared dihapus

class DetailTransaksiPelangganPage extends StatelessWidget {
  const DetailTransaksiPelangganPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status tracker
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStep('Permintaan', true),
                  _buildDividerLine(true),
                  _buildStep('Diterima', true),
                  _buildDividerLine(false),
                  _buildStep('Di Jalan', false),
                  _buildDividerLine(false),
                  _buildStep('Selesai', false),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info pemilik sumur
            const Text('Informasi Pemilik Sumur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(backgroundColor: Color(0xFFE8F2F2), child: Icon(Icons.person, color: primaryTeal)),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sumur Pak Anto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('★ 4.8  •  0.5 km', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildIconBtn(Icons.phone, primaryTeal, () {}),
                      _buildIconBtn(Icons.chat, primaryTeal, () {}),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Detail pesanan
            const Text('Detail Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildRow('Jumlah Air', '1000 Liter'),
                  const SizedBox(height: 10),
                  _buildRow('Harga Penawaran', 'Rp 45.000', valueColor: primaryTeal, valueBold: true),
                  const SizedBox(height: 10),
                  _buildRow('Metode Pembayaran', 'Tunai'),
                  const SizedBox(height: 10),
                  _buildRow('Waktu Pesanan', '7 Mei 2026, 14:30', valueColor: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Alamat pengiriman
            const Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: primaryTeal, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Jl. Merdeka No. 123, Jakarta', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Catatan
            const Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Text('Mohon kirim sebelum jam 5 sore', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ),
            const SizedBox(height: 24),

            // Tombol batalkan (hanya saat status belum di jalan)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Batalkan Pesanan?'),
                      content: const Text('Apakah kamu yakin ingin membatalkan pesanan ini?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tidak')),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Batalkan Pesanan', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String label, bool isDone) {
    return Column(
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_off,
          color: isDone ? const Color(0xFF2C6B6F) : Colors.grey,
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDone ? Colors.black : Colors.grey,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDividerLine(bool isDone) {
    return Expanded(
      child: Container(height: 2, color: isDone ? const Color(0xFF2C6B6F) : Colors.grey[300]),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor, bool valueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: valueColor ?? Colors.black,
            fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  static Widget _buildIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(icon: Icon(icon, color: color), onPressed: onTap);
  }
}