import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pesan_pelanggan_page.dart';

class DetailTransaksiPelangganPage extends StatefulWidget {
  final String transaksiId;

  const DetailTransaksiPelangganPage({super.key, required this.transaksiId});

  @override
  State<DetailTransaksiPelangganPage> createState() =>
      _DetailTransaksiPelangganPageState();
}

class _DetailTransaksiPelangganPageState
    extends State<DetailTransaksiPelangganPage> {
  bool _sudahMunculPopupUlasan = false;

  void _tampilkanPopupUlasan(BuildContext context, String pemilikUid) {
    if (_sudahMunculPopupUlasan) return;
    _sudahMunculPopupUlasan = true;

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _DialogUlasan(
          transaksiId: widget.transaksiId,
          pemilikUid: pemilikUid,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transaksi')
            .doc(widget.transaksiId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text('Data transaksi tidak ditemukan'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'aktif';
          final isDiJalan = status == 'di_jalan';
          final isSelesai = status == 'selesai';
          final isDibatalkan = status == 'dibatalkan';
          final namaPemilik = data['namaPemilik'] ?? 'Pemilik Sumur';
          final pemilikUid = data['pemilikUid'] ?? '';
          final sudahUlasan = data['sudahUlasan'] ?? false;

          if (isSelesai && !sudahUlasan) {
            _tampilkanPopupUlasan(context, pemilikUid);
          }

          String labelStatus = 'Sedang Diproses';
          Color warnaStatus = Colors.orange;
          if (isDiJalan) {
            labelStatus = 'Sedang Diantar';
            warnaStatus = Colors.orange;
          } else if (isSelesai) {
            labelStatus = 'Selesai';
            warnaStatus = Colors.green;
          } else if (isDibatalkan) {
            labelStatus = 'Dibatalkan';
            warnaStatus = Colors.red;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status tracker ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStep('Permintaan', true),
                      _buildDividerLine(true),
                      _buildStep('Diterima', true),
                      _buildDividerLine(isDiJalan || isSelesai),
                      _buildStep('Di Jalan', isDiJalan || isSelesai),
                      _buildDividerLine(isSelesai),
                      _buildStep('Selesai', isSelesai),
                    ],
                  ),
                ),

                if (isDiJalan) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.orange.withOpacity(0.4))),
                    child: const Row(
                      children: [
                        Icon(Icons.local_shipping,
                            color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Air sedang dalam perjalanan menuju lokasimu!',
                            style:
                                TextStyle(color: Colors.orange, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (isSelesai) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.green.withOpacity(0.4))),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Pesanan telah selesai. Terima kasih!',
                            style:
                                TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        ),
                        if (!sudahUlasan)
                          TextButton(
                            onPressed: () {
                              _sudahMunculPopupUlasan = false;
                              _tampilkanPopupUlasan(context, pemilikUid);
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap),
                            child: const Text(
                              'Beri Ulasan',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        if (sudahUlasan)
                          const Text(
                            '✓ Sudah diulas',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // ── Info pemilik sumur ──
                const Text(
                  'Informasi Pemilik Sumur',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFE8F2F2),
                            child: Icon(Icons.person, color: primaryTeal),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                namaPemilik,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                'Banda Aceh',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone, color: primaryTeal),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat, color: primaryTeal),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RuangChatPelangganPage(
                                    transaksiId: widget.transaksiId,
                                    namaLawan: namaPemilik,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Detail pesanan ──
                const Text(
                  'Detail Pesanan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      _buildRow(
                          'Jumlah Air', '${data['jumlahAir'] ?? '-'} Liter'),
                      const SizedBox(height: 10),
                      _buildRow(
                        'Harga',
                        data['harga']?.toString() ?? '-',
                        valueColor: primaryTeal,
                        valueBold: true,
                      ),
                      const SizedBox(height: 10),
                      _buildRow('Metode Pembayaran',
                          data['metodePembayaran'] ?? 'Tunai (COD)'),
                      const SizedBox(height: 10),
                      _buildRow('Status', labelStatus,
                          valueColor: warnaStatus, valueBold: true),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Alamat ──
                const Text(
                  'Alamat Pengiriman',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: primaryTeal, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          data['alamatPelanggan'] ?? 'Banda Aceh',
                          style: TextStyle(
                              color: Colors.grey[700], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                if (data['catatan'] != null &&
                    data['catatan'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Catatan',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      data['catatan'],
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                ],

                if (!isDiJalan && !isSelesai && !isDibatalkan) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _batalkanTransaksi(context),
                      child: const Text(
                        'Batalkan Pesanan',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _batalkanTransaksi(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content:
            const Text('Apakah kamu yakin ingin membatalkan pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('transaksi')
                  .doc(widget.transaksiId)
                  .update({'status': 'dibatalkan'});
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Ya, Batalkan',
                style: TextStyle(color: Colors.red)),
          ),
        ],
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
            fontWeight:
                isDone ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDividerLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? const Color(0xFF2C6B6F) : Colors.grey[300],
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {Color? valueColor, bool valueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: valueColor ?? Colors.black,
            fontWeight:
                valueBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ── Dialog Ulasan ──
class _DialogUlasan extends StatefulWidget {
  final String transaksiId;
  final String pemilikUid;

  const _DialogUlasan({
    required this.transaksiId,
    required this.pemilikUid,
  });

  @override
  State<_DialogUlasan> createState() => _DialogUlasanState();
}

class _DialogUlasanState extends State<_DialogUlasan> {
  int _bintang = 0;
  final TextEditingController _komentarCtrl = TextEditingController();
  bool _isLoading = false;

  static const Color primaryTeal = Color(0xFF2C6B6F);

  final List<String> _labelBintang = [
    '',
    'Sangat Buruk',
    'Buruk',
    'Cukup',
    'Bagus',
    'Sangat Bagus'
  ];

  @override
  void dispose() {
    _komentarCtrl.dispose();
    super.dispose();
  }

  Future<void> _kirimUlasan() async {
    if (_bintang == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bintang terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('ulasan').add({
        'transaksiId': widget.transaksiId,
        'pemilikUid': widget.pemilikUid,
        'bintang': _bintang,
        'komentar': _komentarCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('transaksi')
          .doc(widget.transaksiId)
          .update({'sudahUlasan': true});

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terima kasih atas ulasanmu!')),
      );
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim ulasan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      title: const Column(
        children: [
          Icon(Icons.water_drop, color: primaryTeal, size: 36),
          SizedBox(height: 8),
          Text(
            'Beri Ulasan',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            'Bagaimana pengalaman pengirimanmu?',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.normal),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final index = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _bintang = index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index <= _bintang ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            _bintang > 0
                ? _labelBintang[_bintang]
                : 'Ketuk bintang untuk menilai',
            style: TextStyle(
              fontSize: 12,
              color: _bintang > 0 ? Colors.amber[700] : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _komentarCtrl,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Tulis ulasan singkat (opsional)...',
              hintStyle:
                  const TextStyle(color: Colors.grey, fontSize: 12),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 4),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Lewati',
              style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _isLoading ? null : _kirimUlasan,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text(
                  'Kirim Ulasan',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}