import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../menu/drawer.widget.dart';
import 'chatbot-discussion.page.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final List<Map<String, dynamic>> _conversations = [];

  void _startNewConversation() async {
    final result = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatBotDiscussionPage(),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _conversations.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': 'Nouvelle conversation',
          'date': DateTime.now(),
          'messages': result,
        });
      });
    }
  }

  void _openConversation(int index) async {
    final conv = _conversations[index];
    final result = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder: (context) => ChatBotDiscussionPage(conversation: conv),
      ),
    );

    if (result != null) {
      setState(() {
        if (result.isEmpty) {
          _conversations.removeAt(index);
        } else {
          _conversations[index]['messages'] = result;
        }
      });
    }
  }

  void _deleteConversation(int index) {
    setState(() {
      _conversations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FD),
      drawer: const MyDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Chatbot',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, '/parametres');
            },
          ),
        ],
      ),
      body: _conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune conversation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Appuyez sur le bouton ci-dessous pour commencer',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conv = _conversations[index];
                DateTime date = conv['date'] as DateTime;
                String dateStr = DateFormat('dd/MM/yyyy HH:mm').format(date);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  color: const Color(0xFFF7F5FA),
                  elevation: 0,
                  child: ListTile(
                    onTap: () => _openConversation(index),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.chat_bubble, color: Colors.blue),
                    ),
                    title: Text(
                      conv['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      dateStr,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteConversation(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple.shade100,
        elevation: 1,
        onPressed: _startNewConversation,
        icon: const Icon(Icons.add, color: Colors.black87),
        label: const Text(
          'Nouvelle conversation',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
