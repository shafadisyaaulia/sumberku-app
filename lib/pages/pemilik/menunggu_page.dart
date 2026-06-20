import 'package:flutter/material.dart';
import 'penawaran_diterima_page.dart';

class MenungguPage extends StatefulWidget {
  final Map<String, dynamic> pelanggan;
  final int hargaPenawaran;

  const MenungguPage({super.key, required this.pelanggan, required this.hargaPenawaran});

  @override
  State<MenungguPage> createState() => _MenungguPageState();
}

class _MenungguPageState extends State<MenungguPage> with SingleTickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

    // Simulasi: setelah 3 detik, pelanggan menerima penawaran
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PenawaranDiterimaPage(
              pelanggan: widget.pelanggan,
              hargaPenawaran: widget.hargaPenawaran,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikon jam
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.access_time, size: 50, color: Colors.grey),
              ),
              const SizedBox(height: 28),
              const Text(
                'Menunggu Pelanggan...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Menunggu pelanggan menerima penawaran\nAnda',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 28),
              _buildAnimatedDots(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final opacity = (((_dotController.value - delay) % 1.0 + 1.0) % 1.0 > 0.5) ? 1.0 : 0.3;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF2C6B6F).withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}