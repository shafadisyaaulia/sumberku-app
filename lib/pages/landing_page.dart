import 'package:flutter/material.dart';
import 'pilih_peran_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryTeal = const Color(0xFF2C6B6F);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Gradasi warna sebagai pengganti background image agar enteng di SSD & RAM
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryTeal, const Color(0xFF133032)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),
                
                // Konten Utama Tengah
                Column(
                  children: [
                    // Ikon Sumur / Pompa di atas logo SumberKu
                    Icon(Icons.waves, size: 70, color: Colors.white.withOpacity(0.9)),
                    const SizedBox(height: 16),
                    // Nama Aplikasi
                    const Text(
                      'SumberKu',
                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    // Kapsul Teks "Air Bersih untuk Semua"
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: const Text(
                        'Air Bersih untuk Semua',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Slogan
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Temukan sumber air terpercaya langsung dari pemilik sumur terdekat',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Tiga Kotak Fitur / Keunggulan (Ikon Transparan)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFeatureIcon(Icons.people_outline, '1000+ Pengguna'),
                        _buildFeatureIcon(Icons.opacity, 'Terpercaya'),
                        _buildFeatureIcon(Icons.speed, 'Cepat & Mudah'),
                      ],
                    ),
                  ],
                ),

                // Bagian Bawah: Tombol & Copyright
                Column(
                  children: [
                    // Tombol Mulai Sekarang
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PilihPeranPage()),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Mulai Sekarang ',
                              style: TextStyle(color: primaryTeal, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.arrow_forward, color: primaryTeal, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Copyright
                    Text(
                      'Hak Cipta © 2024 SumberKu',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk membuat kotak fitur transparan
  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}