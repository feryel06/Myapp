import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../menu/drawer.widget.dart';

class ParametresPage extends StatefulWidget {
  const ParametresPage({super.key});

  @override
  State<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends State<ParametresPage> {
  bool _darkMode = false;
  String _selectedLanguage = 'Français';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'Français';
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() {
      _darkMode = value;
    });
  }

  Future<void> _changeLanguage(String? newLang) async {
    if (newLang == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLang);
    setState(() {
      _selectedLanguage = newLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FD),
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode, color: Colors.blue),
              title: const Text('Mode Sombre / Night Mode'),
              subtitle: const Text('Activer ou désactiver le thème sombre'),
              value: _darkMode,
              onChanged: _toggleDarkMode,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.language, color: Colors.blue),
              title: const Text('Langue de l\'application'),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                items: const [
                  DropdownMenuItem(value: 'Français', child: Text('Français')),
                  DropdownMenuItem(value: 'Anglais', child: Text('English')),
                  DropdownMenuItem(value: 'Arabe', child: Text('العربية')),
                ],
                onChanged: _changeLanguage,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              title: Text('Version de l\'application'),
              subtitle: Text('v1.0.0 (Ateliers Completes)'),
            ),
          ),
        ],
      ),
    );
  }
}
