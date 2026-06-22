import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pelanggan/main_navigation_pelanggan.dart';
import 'pemilik/main_navigation_pemilik.dart';

class DaftarPage extends StatefulWidget {
  final String peran;

  const DaftarPage({super.key, required this.peran});

  @override
  State<DaftarPage> createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  final namaCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();
  bool isLoading = false;
  String? kecamatanTerpilih;
  final Color primaryTeal = const Color(0xFF2C6B6F);

  // Daftar kecamatan di Banda Aceh
  final List<String> kecamatanBandaAceh = [
    'Baiturrahman',
    'Banda Raya',
    'Blang Cut',
    'Jaya Baru',
    'Kuta Alam',
    'Kuta Raja',
    'Lueng Bata',
    'Meuraxa',
    'Syiah Kuala',
    'Ulee Kareng',
  ];

  void _daftar() async {
    if (namaCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passCtrl.text.isEmpty ||
        kecamatanTerpilih == null ||
        alamatCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi!')),
      );
      return;
    }

    if (passCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi minimal 6 karakter!')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'uid': credential.user!.uid,
        'nama': namaCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'peran': widget.peran,
        'kecamatan': kecamatanTerpilih,
        'alamat': alamatCtrl.text.trim(),
        'kota': 'Banda Aceh',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => widget.peran == 'Pemilik'
              ? const MainNavigationPemilik()
              : const MainNavigationPelanggan(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      String pesan = 'Terjadi kesalahan, coba lagi.';
      if (e.code == 'email-already-in-use') pesan = 'Email sudah terdaftar!';
      if (e.code == 'invalid-email') pesan = 'Format email tidak valid!';
      if (e.code == 'weak-password') pesan = 'Kata sandi terlalu lemah!';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    namaCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    alamatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.water_drop, size: 50, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text('SumberKu',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.peran == 'Pemilik'
                          ? 'Daftar sebagai Pemilik Sumur'
                          : 'Daftar sebagai Pelanggan',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Buat Akun Baru',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Lengkapi data di bawah ini untuk mendaftar',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    const SizedBox(height: 16),

                    // Note layanan Banda Aceh
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.orange[700], size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Layanan SumberKu saat ini hanya tersedia di wilayah Banda Aceh',
                              style: TextStyle(color: Colors.orange[800], fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nama Lengkap
                    const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: namaCtrl,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person, size: 18),
                        hintText: 'Masukkan nama Anda',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email, size: 18),
                        hintText: 'contoh@email.com',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Kata Sandi
                    const Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, size: 18),
                        hintText: 'Minimal 6 karakter',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Kecamatan Dropdown
                    const Text('Kecamatan', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: kecamatanTerpilih,
                      hint: const Text('Pilih kecamatan'),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.map, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: kecamatanBandaAceh
                          .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                          .toList(),
                      onChanged: (val) => setState(() => kecamatanTerpilih = val),
                    ),
                    const SizedBox(height: 16),

                    // Alamat Detail
                    const Text('Alamat Detail', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: alamatCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.home, size: 18),
                        hintText: 'Contoh: Jl. Iskandar Muda No. 12',
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
                        onPressed: isLoading ? null : _daftar,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Daftar Sekarang →',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sudah punya akun? ', style: TextStyle(color: Colors.grey[600])),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text('Masuk',
                              style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
                        ),
                      ],
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