import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// =========================================================
// 1. HALAMAN DAFTAR CHAT PEMILIK
// =========================================================
class PesanPemilikPage extends StatelessWidget {
  const PesanPemilikPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text('Pesan Masuk',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.search, color: Colors.black54),
              onPressed: () {}),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('Silakan login terlebih dahulu'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transaksi')
                  .where('pemilikUid', isEqualTo: uid)
                  .where('status', whereIn: ['aktif', 'di_jalan'])
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada pesan.\nChat akan muncul setelah transaksi aktif.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Colors.black12),
                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;
                    final transaksiId = docs[index].id;
                    final namaPelanggan =
                        data['namaPelanggan'] ?? 'Pelanggan';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFE8F2F2),
                        child: Icon(Icons.person,
                            color: primaryTeal, size: 24),
                      ),
                      title: Text(namaPelanggan,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text(
                        'Transaksi aktif — ketuk untuk chat',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing:
                          const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RuangChatPemilikPage(
                              transaksiId: transaksiId,
                              namaLawan: namaPelanggan,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

// =========================================================
// 2. HALAMAN RUANG CHAT PEMILIK (Firebase Realtime)
// =========================================================
class RuangChatPemilikPage extends StatefulWidget {
  final String transaksiId;
  final String namaLawan;

  const RuangChatPemilikPage({
    super.key,
    required this.transaksiId,
    required this.namaLawan,
  });

  @override
  State<RuangChatPemilikPage> createState() => _RuangChatPemilikPageState();
}

class _RuangChatPemilikPageState extends State<RuangChatPemilikPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static const Color primaryTeal = Color(0xFF2C6B6F);

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _controller.clear();

    await FirebaseFirestore.instance
        .collection('transaksi')
        .doc(widget.transaksiId)
        .collection('chat')
        .add({
      'pengirimUid': uid,
      'pesan': text,
      'waktu': FieldValue.serverTimestamp(),
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE8F2F2),
              child: Icon(Icons.person, color: primaryTeal, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.namaLawan,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const Text('● Online',
                    style:
                        TextStyle(color: Colors.green, fontSize: 10)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.phone, color: primaryTeal),
              onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Banner info transaksi
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: primaryTeal.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.water_drop, color: primaryTeal, size: 16),
                SizedBox(width: 8),
                Text('Transaksi aktif',
                    style: TextStyle(
                        color: primaryTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // List pesan dari Firebase
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transaksi')
                  .doc(widget.transaksiId)
                  .collection('chat')
                  .orderBy('waktu', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                        'Belum ada pesan. Mulai chat sekarang!',
                        style: TextStyle(color: Colors.black54)),
                  );
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final data = messages[i].data()
                        as Map<String, dynamic>;
                    final isMe = data['pengirimUid'] == uid;
                    return _buildBubble(
                        data['pesan'] ?? '', isMe);
                  },
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan ke pelanggan...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const CircleAvatar(
                    backgroundColor: primaryTeal,
                    child: Icon(Icons.send,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isMe) {
    return Align(
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isMe ? primaryTeal : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 14),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Text(text,
            style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 13)),
      ),
    );
  }
}