import 'package:flutter/material.dart';
import 'login_page.dart';

class PilihPeranPage extends StatefulWidget {
  const PilihPeranPage({super.key});

  @override
  State<PilihPeranPage> createState() => _PilihPeranPageState();
}

class _PilihPeranPageState extends State<PilihPeranPage> {
  String selectedRole = 'Pelanggan';
  final Color primaryTeal = const Color(0xFF2C6B6F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.water_drop, size: 60, color: primaryTeal),
              const SizedBox(height: 16),
              const Text(
                'Pilih Peran Anda',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                'Bagaimana Anda ingin menggunakan SumberKu?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Pilihan Pelanggan Air
              _buildRoleCard('Pelanggan', 'Pelanggan Air', 'Saya membutuhkan air bersih untuk kebutuhan sehari-hari.', Icons.people_outline),
              const SizedBox(height: 16),

              // Pilihan Pemilik Sumur
              _buildRoleCard('Pemilik', 'Pemilik Sumur', 'Saya memiliki sumur dan ingin menjual air.', Icons.opacity),
              const SizedBox(height: 40),

              // Tombol Lanjutkan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text('Lanjutkan →', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String role, String title, String subtitle, IconData icon) {
    bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F2F2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? primaryTeal : Colors.grey.shade300, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: isSelected ? primaryTeal : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            Radio<String>(
              value: role,
              groupValue: selectedRole,
              activeColor: primaryTeal,
              onChanged: (value) => setState(() => selectedRole = value!),
            ),
          ],
        ),
      ),
    );
  }
}