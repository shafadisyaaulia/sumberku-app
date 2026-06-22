import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pelanggan/main_navigation_pelanggan.dart';
import 'pemilik/main_navigation_pemilik.dart';
import 'daftar_page.dart';

class LoginPage extends StatefulWidget {
  final String peran;

  const LoginPage({super.key, required this.peran});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;
  final Color primaryTeal = const Color(0xFF2C6B6F);

  void _login() async {
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan kata sandi wajib diisi!')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Login pakai Firebase Auth
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );

      // Ambil data user dari Firestore untuk cek perannya
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!mounted) return;

      if (!doc.exists) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data akun tidak ditemukan!')),
        );
        return;
      }

      final peranDiFirestore = doc.data()!['peran'];

      // Cek apakah peran yang dipilih sesuai dengan yang didaftarkan
      if (peranDiFirestore != widget.peran) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Akun ini terdaftar sebagai $peranDiFirestore, bukan ${widget.peran}!')),
        );
        return;
      }

      // Navigasi sesuai peran
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
      if (e.code == 'user-not-found') pesan = 'Email tidak terdaftar!';
      if (e.code == 'wrong-password') pesan = 'Kata sandi salah!';
      if (e.code == 'invalid-email') pesan = 'Format email tidak valid!';
      if (e.code == 'invalid-credential') pesan = 'Email atau kata sandi salah!';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
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
                          ? 'Masuk sebagai Pemilik Sumur'
                          : 'Masuk sebagai Pelanggan',
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
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selamat Datang!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Masuk untuk melanjutkan ke akun Anda',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    const SizedBox(height: 24),
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
                    const Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passCtrl,
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
                        onPressed: isLoading ? null : _login,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Masuk →',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Belum punya akun? ', style: TextStyle(color: Colors.grey[600])),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DaftarPage(peran: widget.peran)),
                          ),
                          child: Text('Daftar di sini',
                              style: TextStyle(
                                  color: primaryTeal, fontWeight: FontWeight.bold)),
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