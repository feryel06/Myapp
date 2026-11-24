import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/home.page.dart';
import 'pages/meteo.page.dart';
import 'pages/maps.page.dart';
import 'pages/contacts.page.dart';
import 'pages/messenger.page.dart';
import 'pages/chatbot.page.dart';
import 'pages/parametres.page.dart';
import 'pages/authentification.page.dart';
import 'pages/inscription.page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init: $e');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isConnected = prefs.getBool("connecte") ?? false;

  runApp(MyApp(isConnected: isConnected));
}

class MyApp extends StatelessWidget {
  final bool isConnected;
  const MyApp({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mon Application',
      routes: {
        '/home': (context) => const HomePage(),
        '/meteo': (context) => Meteo(),
        '/maps': (context) => MapsPage(),
        '/contacts': (context) => const ContactsPage(),
        '/messenger': (context) => const MessengerPage(),
        '/chatbot': (context) => const ChatBotPage(),
        '/parametres': (context) => const ParametresPage(),
        '/authentification': (context) => const AuthentificationPage(),
        '/inscription': (context) => const InscriptionPage(),
      },
      initialRoute: isConnected ? '/home' : '/authentification',
    );
  }
}
