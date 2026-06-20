import 'package:flutter/material.dart';
import 'pelanggan/main_navigation_pelanggan.dart';
import 'pemilik/main_navigation_pemilik.dart';

class LoginPage extends StatelessWidget {
  final String peran; // 'Pelanggan' atau 'Pemilik'

  const LoginPage({super.key, required this.peran});

  @override
  Widget build(BuildContext context) {
    final Color primaryTeal = const Color(0xFF2C6B6F);

    return Scaffold(
      backgroundColor: primaryTeal,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.water_drop, size: 50, color: Colors.white), // Telah diubah menjadi water_drop
                  const SizedBox(height: 10),
                  const Text('SumberKu', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      peran == 'Pemilik' ? 'Masuk sebagai Pemilik Sumur' : 'Masuk sebagai Pelanggan',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selamat Datang!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Masuk untuk melanjutkan ke akun Anda', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    const SizedBox(height: 24),
                    const Text('Nomor HP', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone, size: 18),
                        hintText: '08123456789',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, size: 18),
                        hintText: '••••••••',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => peran == 'Pemilik'
                                  ? const MainNavigationPemilik()
                                  : const MainNavigationPelanggan(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text('Masuk →', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}