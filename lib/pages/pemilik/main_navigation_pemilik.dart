import 'package:flutter/material.dart';
import 'beranda_pemilik_page.dart';
import 'pesan_pemilik_page.dart';
import 'riwayat_transaksi_pemilik_page.dart';
import 'notifikasi_pemilik_page.dart';
import 'profil_pemilik_page.dart'; // Ini akan memanggil file profil yang sudah kita buat

class MainNavigationPemilik extends StatefulWidget {
  const MainNavigationPemilik({super.key});

  @override
  State<MainNavigationPemilik> createState() => _MainNavigationPemilikState();
}

class _MainNavigationPemilikState extends State<MainNavigationPemilik> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BerandaPemilikPage(),
    const PesanPemilikPage(),
    const RiwayatPemilikPage(),
    const NotifikasiPemilikPage(),
    const ProfilPemilikPage(), // Sekarang ini murni mengambil dari profil_pemilik_page.dart
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Pesan'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}