import 'package:flutter/material.dart';
import 'beranda_pelanggan_page.dart';
import 'pesan_pelanggan_page.dart';
import 'riwayat_transaksi_pelanggan_page.dart';
import 'notifikasi_pelanggan_page.dart';
import 'profil_pelanggan_page.dart';

class MainNavigationPelanggan extends StatefulWidget {
  const MainNavigationPelanggan({super.key});

  @override
  State<MainNavigationPelanggan> createState() => _MainNavigationPelangganState();
}

class _MainNavigationPelangganState extends State<MainNavigationPelanggan> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BerandaPelangganPage(),
    const PesanPelangganPage(),
    const RiwayatTransaksiPelangganPage(),
    const NotifikasiPelangganPage(),
    // Placeholder untuk Halaman Profil agar tidak error saat di-run
    const ProfilPelangganPage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Beranda'), // Disesuaikan dengan gambar
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Pesan'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'), // Tambahan menu profil
        ],
      ),
    );
  }
}