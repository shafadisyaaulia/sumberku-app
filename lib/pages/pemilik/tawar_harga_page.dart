import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'menunggu_page.dart';

class TawarHargaPage extends StatefulWidget {
  final Map<String, dynamic> pelanggan;

  const TawarHargaPage({super.key, required this.pelanggan});

  @override
  State<TawarHargaPage> createState() => _TawarHargaPageState();
}

class _TawarHargaPageState extends State<TawarHargaPage> {
  final TextEditingController _hargaController = TextEditingController();
  bool _isValid = false;

  static const Color primaryTeal = Color(0xFF2C6B6F);

  @override
  void initState() {
    super.initState();
    _hargaController.addListener(_validate);
  }

  void _validate() {
    final text = _hargaController.text.trim();
    final val = int.tryParse(text);
    setState(() {
      _isValid = val != null && val > 0 && val <= widget.pelanggan['hargaMaks'];
    });
  }

  @override
  void dispose() {
    _hargaController.dispose();
    super.dispose();
  }

  String _formatRupiah(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final pelanggan = widget.pelanggan;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tawar Harga', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info pelanggan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informasi Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[700])),
                  const SizedBox(height: 12),
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
                      Row(children: [
                        Icon(Icons.water_drop_outlined, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text('Jumlah Air', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ]),
                      Text('${pelanggan['jumlahAir']} Liter', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.attach_money, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text('Harga Maksimal', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ]),
                      Text(
                        'Rp ${_formatRupiah(pelanggan['hargaMaks'])}',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Input harga penawaran
            const Text('Harga Penawaran Anda (Rp)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Contoh: 45000',
                hintStyle: TextStyle(color: Colors.grey[400]),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryTeal)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Masukkan harga yang Anda tawarkan (maksimal Rp ${_formatRupiah(pelanggan['hargaMaks'])})',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
            const SizedBox(height: 16),

            // Tips
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡 ', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Tips: Berikan harga yang kompetitif untuk meningkatkan peluang penawaran Anda diterima',
                      style: TextStyle(color: Colors.orange[900], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Tombol kirim
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isValid ? primaryTeal : Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isValid
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MenungguPage(
                              pelanggan: pelanggan,
                              hargaPenawaran: int.parse(_hargaController.text.trim()),
                            ),
                          ),
                        );
                      }
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Kirim Penawaran',
                      style: TextStyle(
                        color: _isValid ? Colors.white : Colors.grey[500],
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward, color: _isValid ? Colors.white : Colors.grey[500], size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}