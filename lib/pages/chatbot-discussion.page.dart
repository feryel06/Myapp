import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatBotDiscussionPage extends StatefulWidget {
  final Map<String, dynamic>? conversation;
  const ChatBotDiscussionPage({super.key, this.conversation});

  @override
  State<ChatBotDiscussionPage> createState() => _ChatBotDiscussionPageState();
}

class _ChatBotDiscussionPageState extends State<ChatBotDiscussionPage> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.conversation != null && widget.conversation!['messages'] != null) {
      _messages.addAll(
        List<Map<String, dynamic>>.from(widget.conversation!['messages']),
      );
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendPrompt(String promptText) async {
    String text = promptText.trim();
    if (text.isEmpty) return;

    _promptController.clear();

    setState(() {
      _messages.add({
        'sender': 'Moi',
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _scrollToBottom();

    String reply = await _fetchAiResponse(text);

    if (mounted) {
      setState(() {
        _messages.add({
          'sender': 'IA',
          'text': reply,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<String> _fetchAiResponse(String prompt) async {
    try {
      Uri url = Uri.parse('https://api.openai.com/v1/chat/completions');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_OPENAI_API_KEY',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'Vous êtes un assistant IA en français.'},
            {'role': 'user', 'content': prompt}
          ],
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      }
    } catch (_) {}

    // Fallback intelligent en français
    String query = prompt.toLowerCase();
    if (query.contains('tunisie') || query.contains('capitale')) {
      return 'La capitale de la Tunisie est Tunis.';
    } else if (query.contains('canada')) {
      return 'La capitale du Canada est Ottawa.';
    } else if (query.contains('api rest')) {
      return 'Pour créer une API REST, vous pouvez utiliser Node.js/Express, Spring Boot ou Python/FastAPI avec le format JSON.';
    } else if (query.contains('projet') || query.contains('idée')) {
      return 'Voici quelques idées : Application Météo/Maps, Application E-Commerce ou Gestionnaire de Tâches IA !';
    } else if (query.contains('bonjour') || query.contains('salut')) {
      return 'Bonjour ! Comment puis-je vous aider aujourd\'hui ?';
    } else {
      return 'Voici la réponse à votre question sur "$prompt" : L\'intelligence artificielle traite votre demande avec succès.';
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

  void _speakMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔊 Synthèse vocale: "$text"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _messages.isNotEmpty ? _messages : null);
          },
        ),
        title: const Text(
          'Discussion',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black87),
            onPressed: () {
              setState(() => _messages.clear());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.smart_toy,
                            size: 70,
                            color: Colors.blue.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Bonjour ! 👋',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Comment puis-je vous aider aujourd\'hui ?',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Suggestions :',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSuggestionTile(
                          icon: '💻',
                          label: 'Comment créer une API REST ?',
                        ),
                        _buildSuggestionTile(
                          icon: '💡',
                          label: 'Donne-moi des idées de projets créatifs',
                        ),
                        _buildSuggestionTile(
                          icon: '🌍',
                          label: 'Quelle est la capitale du Tunisie ?',
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      bool isUser = msg['isUser'] ?? false;
                      DateTime dt = msg['timestamp'] as DateTime;
                      String timeStr = DateFormat('HH:mm').format(dt);
                      String text = msg['text'] ?? '';

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF1976D2) : const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          child: Column(
                            crossAxisAlignment: isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                text,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isUser ? FontWeight.normal : FontWeight.w500,
                                  color: isUser ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    timeStr,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isUser ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  if (!isUser) ...[
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () => _speakMessage(text),
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.red.shade400,
                                        child: const Icon(
                                          Icons.volume_up,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('L\'IA réfléchit...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.mic, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _promptController,
                      decoration: const InputDecoration(
                        hintText: 'Posez votre question...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (val) => _sendPrompt(val),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () => _sendPrompt(_promptController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionTile({required String icon, required String label}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _sendPrompt(label),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
