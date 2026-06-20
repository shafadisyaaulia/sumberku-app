import 'package:flutter/material.dart';

// =========================================================
// 1. HALAMAN DAFTAR CHAT (Sperti WhatsApp)
// =========================================================
class PesanPemilikPage extends StatelessWidget {
  const PesanPemilikPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);

    // Data dummy untuk daftar chat pelanggan
    final List<Map<String, dynamic>> chatList = [
      {
        'nama': 'Budi Santoso',
        'pesanTerakhir': 'Sekitar 15-20 menit lagi',
        'waktu': '10:30',
        'unread': 1,
        'isOnline': true,
        'avatar': '👨🏽',
      },
      {
        'nama': 'Siti Nurhaliza',
        'pesanTerakhir': 'Airnya jernih banget pak, makasih ya.',
        'waktu': '09:15',
        'unread': 0,
        'isOnline': false,
        'avatar': '🧕🏼',
      },
      {
        'nama': 'Ahmad Rizki',
        'pesanTerakhir': 'Bisa kirim ke alamat yang di map kan?',
        'waktu': 'Kemarin',
        'unread': 0,
        'isOnline': true,
        'avatar': '👦🏻',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Pesan Masuk', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black54), onPressed: () {}),
        ],
      ),
      body: ListView.separated(
        itemCount: chatList.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
        itemBuilder: (context, index) {
          final chat = chatList[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE8F2F2),
                  child: Text(chat['avatar'], style: const TextStyle(fontSize: 24)),
                ),
                if (chat['isOnline'])
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(chat['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(
              chat['pesanTerakhir'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: chat['unread'] > 0 ? Colors.black87 : Colors.grey[600], fontWeight: chat['unread'] > 0 ? FontWeight.w600 : FontWeight.normal),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat['waktu'], style: TextStyle(color: chat['unread'] > 0 ? primaryTeal : Colors.grey, fontSize: 12, fontWeight: chat['unread'] > 0 ? FontWeight.bold : FontWeight.normal)),
                const SizedBox(height: 4),
                if (chat['unread'] > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: primaryTeal, shape: BoxShape.circle),
                    child: Text(chat['unread'].toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            onTap: () {
              // Menuju Ruang Chat
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RuangChatPemilikPage()));
            },
          );
        },
      ),
    );
  }
}

// =========================================================
// 2. HALAMAN RUANG CHAT (Kode Asli Milikmu)
// =========================================================
class RuangChatPemilikPage extends StatefulWidget {
  const RuangChatPemilikPage({super.key});

  @override
  State<RuangChatPemilikPage> createState() => _RuangChatPemilikPageState();
}

class _RuangChatPemilikPageState extends State<RuangChatPemilikPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Halo, apakah air sudah siap dikirim?', 'isMe': false},
    {'text': 'Siap Pak, sedang dalam perjalanan ke lokasi Anda', 'isMe': true},
    {'text': 'Kira-kira berapa lama sampainya?', 'isMe': false},
    {'text': 'Sekitar 15-20 menit lagi', 'isMe': true},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'text': text, 'isMe': true});
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF2C6B6F);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE8F2F2),
              child: Text('🐱', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Budi Santoso', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                Text('● Online', style: TextStyle(color: Colors.green, fontSize: 10)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.phone, color: primaryTeal), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryTeal.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.water_drop, color: primaryTeal, size: 16),
                SizedBox(width: 8),
                Text('Transaksi aktif: 1000L • Pendapatan Rp 45.000', style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _buildBubble(_messages[i]['text'], _messages[i]['isMe']),
            ),
          ),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const CircleAvatar(
                    backgroundColor: primaryTeal,
                    child: Icon(Icons.send, color: Colors.white, size: 18),
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
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2C6B6F) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 14),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 13)),
      ),
    );
  }
}