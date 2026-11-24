import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class MessengerChatPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const MessengerChatPage({super.key, required this.user});

  @override
  State<MessengerChatPage> createState() => _MessengerChatPageState();
}

class _MessengerChatPageState extends State<MessengerChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  late CollectionReference _chatRef;

  late List<Map<String, dynamic>> _demoMessages;

  @override
  void initState() {
    super.initState();
    String userName = widget.user['name'] ?? 'Utilisateur';
    String chatId = 'chat_${userName.toLowerCase().replaceAll(' ', '_')}';
    _chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages');

    _demoMessages = [
      {
        'id': '1',
        'sender': userName,
        'text': 'Bonjour',
        'imageBase64': null,
        'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
        'isMe': false,
      },
      {
        'id': '2',
        'sender': 'Moi',
        'text': 'Bonjour ! Comment vas-tu ?',
        'imageBase64': null,
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'isMe': true,
      },
    ];
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({String? imageBase64}) async {
    String text = _msgController.text.trim();
    if (text.isEmpty && imageBase64 == null) return;

    _msgController.clear();
    User? currentUser = FirebaseAuth.instance.currentUser;
    String sender = currentUser?.email ?? 'Moi';

    try {
      await _chatRef.add({
        'sender': sender,
        'text': text,
        'imageBase64': imageBase64,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      setState(() {
        _demoMessages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'sender': sender,
          'text': text,
          'imageBase64': imageBase64,
          'timestamp': DateTime.now(),
          'isMe': true,
        });
      });
    }

    _scrollToBottom();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        Uint8List imageBytes = await pickedFile.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        await _sendMessage(imageBase64: base64Image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur image: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String userName = widget.user['name'] ?? 'Utilisateur';
    String initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    User? currentUser = FirebaseAuth.instance.currentUser;
    String myEmail = currentUser?.email ?? 'Moi';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatRef.orderBy('timestamp', descending: false).snapshots(),
              builder: (context, snapshot) {
                List<Map<String, dynamic>> messagesList = [];

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  messagesList = snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    Timestamp? ts = data['timestamp'] as Timestamp?;
                    DateTime dt = ts != null ? ts.toDate() : DateTime.now();
                    String sender = data['sender'] ?? 'Anonyme';
                    bool isMe = (sender == myEmail || sender == 'Moi');

                    return {
                      'id': doc.id,
                      'sender': sender,
                      'text': data['text'] ?? '',
                      'imageBase64': data['imageBase64'],
                      'timestamp': dt,
                      'isMe': isMe,
                    };
                  }).toList();
                } else {
                  messagesList = _demoMessages;
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  itemCount: messagesList.length,
                  itemBuilder: (context, index) {
                    final msg = messagesList[index];
                    bool isMe = msg['isMe'] ?? false;
                    DateTime dt = msg['timestamp'] as DateTime;
                    String timeStr = DateFormat('HH:mm').format(dt);
                    String? imgBase64 = msg['imageBase64'];

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF1E88E5) : const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.72,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (imgBase64 != null && imgBase64.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    base64Decode(imgBase64),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image, size: 50),
                                  ),
                                ),
                              ),
                            if (msg['text'].isNotEmpty)
                              Text(
                                msg['text'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 11,
                                color: isMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.blue, size: 28),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: TextField(
                      controller: _msgController,
                      decoration: const InputDecoration(
                        hintText: 'Envoyer un message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
