import 'package:flutter/material.dart';
import '../landing_page.dart'; // Sesuaikan path jika berbeda

class ProfilPelangganPage extends StatelessWidget {
  const ProfilPelangganPage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LandingPage()),
                (route) => false,
              );
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profil', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 30, bottom: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryTeal, Color(0xFF1E4648)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    alignment: Alignment.center,
                    child: const Text('👦', style: TextStyle(fontSize: 45)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Budi Santoso',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pelanggan Air',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            // Content Body
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Card 1: Contact Info
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.phone_outlined, 'Nomor HP', '+62 812-3456-7890'),
                        Divider(height: 1, color: Colors.grey.shade200, indent: 50),
                        _buildInfoRow(Icons.location_on_outlined, 'Alamat', 'Jl. Merdeka No. 123, Jakarta'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card 2: Menus
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildMenuRow(Icons.person_outline, 'Edit Profil', onTap: () {}),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _buildMenuRow(Icons.settings_outlined, 'Pengaturan', onTap: () {}),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _buildMenuRow(Icons.help_outline, 'Bantuan', onTap: () {}),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _buildMenuRow(Icons.logout, 'Keluar', isLogout: true, onTap: () => _showLogoutDialog(context)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  // Footer
                  Text('Versi 1.0.0', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('© 2024 SumberKu', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow(IconData icon, String title, {bool isLogout = false, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.grey[700], size: 22),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: isLogout ? Colors.red : Colors.grey[400], size: 20),
      onTap: onTap,
    );
  }
}