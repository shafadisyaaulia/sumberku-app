import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../landing_page.dart';

class ProfilPemilikPage extends StatelessWidget {
  const ProfilPemilikPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
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
        title: const Text('Profil Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          uid == null
              ? const SizedBox()
              : FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox();
                    final userData = snapshot.data!.data() as Map<String, dynamic>;
                    
                    return IconButton(
                      icon: const Icon(Icons.edit, color: primaryTeal),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilPemilikPage(userData: userData, uid: uid),
                          ),
                        );
                      },
                    );
                  },
                ),
          const SizedBox(width: 8),
        ],
      ),
      body: uid == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Gagal memuat profil.'));
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final fotoUrl = userData['fotoUrl'] as String?;
                
                // Ambil data status aktif sumur (default: true jika belum ada di firebase)
                final bool isAktif = userData['isAktif'] ?? true;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // --- FOTO PROFIL ---
                      Center(
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: const Color(0xFFE8F2F2),
                          backgroundImage: fotoUrl != null && fotoUrl.isNotEmpty ? NetworkImage(fotoUrl) : null,
                          child: fotoUrl == null || fotoUrl.isEmpty
                              ? const Text('👨🏽', style: TextStyle(fontSize: 40))
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // --- NAMA & PERAN ---
                      Text(userData['nama'] ?? '-', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(userData['peran'] ?? 'Pemilik Sumur', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      const SizedBox(height: 6),

                      // --- FITUR BARU: RATING BINTANG ALA GRAB ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            // Mengambil data rating dari firebase, kalau kosong diset otomatis ke default 4.8
                            '${userData['rating'] ?? 4.8} (${userData['totalUlasan'] ?? 0} Ulasan)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- FITUR BARU: SAKLAR ON/OFF STATUS SUMUR (REALTIME) ---
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAktif ? primaryTeal.withOpacity(0.3) : Colors.red.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: SwitchListTile(
                          activeColor: primaryTeal,
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey[300],
                          title: Text(
                            isAktif ? 'Status: Siap Menerima Air' : 'Status: Tutup / Air Kurang',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isAktif ? primaryTeal : Colors.red[700],
                            ),
                          ),
                          subtitle: Text(
                            isAktif 
                                ? 'Sumur normal. Anda akan mendapatkan notifikasi orderan masuk.' 
                                : 'Aplikasi dimatikan sementara. Notifikasi orderan tidak akan masuk.',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                          value: isAktif,
                          onChanged: (bool value) async {
                            // LANGSUNG UPDATE STATUS KE FIREBASE SAAT SAKLAR DIKLIK
                            await FirebaseFirestore.instance.collection('users').doc(uid).update({
                              'isAktif': value,
                            });
                          },
                        ),
                      ),

                      // --- INFO DATA DIRI ---
                      _buildInfoTile(Icons.email_outlined, 'Email (Tidak dapat diubah)', userData['email'] ?? '-'),
                      _buildInfoTile(Icons.phone_android, 'No. WhatsApp', userData['noHp'] ?? '-'),
                      _buildInfoTile(Icons.location_city, 'Kecamatan Tugas', userData['kecamatan'] ?? '-'),
                      
                      const SizedBox(height: 40),
                      
                      // --- TOMBOL KELUAR ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            elevation: 0,
                            side: BorderSide(color: Colors.red[100]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (!context.mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LandingPage()),
                              (route) => false,
                            );
                          },
                          child: const Text('Keluar Akun', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2C6B6F), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// HALAMAN FORM EDIT PROFIL (KAPASITAS SUMUR SUDAH DIHAPUS)
// =========================================================
class EditProfilPemilikPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String uid;

  const EditProfilPemilikPage({super.key, required this.userData, required this.uid});

  @override
  State<EditProfilPemilikPage> createState() => _EditProfilPemilikPageState();
}

class _EditProfilPemilikPageState extends State<EditProfilPemilikPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaCtrl;
  late TextEditingController _noHpCtrl;
  late TextEditingController _kecamatanCtrl;
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.userData['nama']);
    _noHpCtrl = TextEditingController(text: widget.userData['noHp']);
    _kecamatanCtrl = TextEditingController(text: widget.userData['kecamatan']);
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _noHpCtrl.dispose();
    _kecamatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihGambar() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    String? fotoUrlBaru = widget.userData['fotoUrl'];

    try {
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance.ref().child('foto_profil').child('${widget.uid}.jpg');
        await ref.putFile(_imageFile!);
        fotoUrlBaru = await ref.getDownloadURL();
      }

      // UPDATE DATA (SUDAH TIDAK ADA KAPASITAS SUMUR)
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
        'nama': _namaCtrl.text.trim(),
        'noHp': _noHpCtrl.text.trim(),
        'kecamatan': _kecamatanCtrl.text.trim(),
        'fotoUrl': fotoUrlBaru,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);
    final fotoLama = widget.userData['fotoUrl'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ubah Profil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: _isSaving 
      ? const Center(child: CircularProgressIndicator(color: primaryTeal))
      : Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _pilihGambar,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (fotoLama != null && fotoLama.isNotEmpty ? NetworkImage(fotoLama) : null) as ImageProvider?,
                        child: _imageFile == null && (fotoLama == null || fotoLama.isEmpty)
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pilihGambar,
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: primaryTeal,
                          child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('Ketuk foto untuk mengubah', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 30),

              _buildTextField(label: 'Nama Lengkap', controller: _namaCtrl, icon: Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(label: 'No. WhatsApp', controller: _noHpCtrl, icon: Icons.phone_android, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(label: 'Kecamatan Tugas', controller: _kecamatanCtrl, icon: Icons.location_city),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _simpanPerubahan,
                  child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) => value == null || value.trim().isEmpty ? '$label tidak boleh kosong' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF2C6B6F), size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2C6B6F), width: 1)),
      ),
    );
  }
}