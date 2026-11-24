import 'package:flutter/material.dart';

class GlobalParams {
  static List menu = [
    {
      'title': 'Accueil',
      'icon': const Icon(Icons.home, color: Colors.blue),
      'route': '/home'
    },
    {
      'title': 'Météo',
      'icon': const Icon(Icons.sunny_snowing, color: Colors.blue),
      'route': '/meteo'
    },
    {
      'title': 'Maps',
      'icon': const Icon(Icons.location_on, color: Colors.blue),
      'route': '/maps'
    },
    {
      'title': 'Contacts',
      'icon': const Icon(Icons.phone, color: Colors.blue),
      'route': '/contacts'
    },
    {
      'title': 'Messenger',
      'icon': const Icon(Icons.messenger_outline, color: Colors.blue),
      'route': '/messenger'
    },
    {
      'title': 'ChatBot',
      'icon': const Icon(Icons.android, color: Colors.blue),
      'route': '/chatbot'
    },
    {
      'title': 'Paramètres',
      'icon': const Icon(Icons.settings, color: Colors.blue),
      'route': '/parametres'
    },
    {
      'title': 'Déconnexion',
      'icon': const Icon(Icons.logout, color: Colors.blue),
      'route': '/authentification'
    },
  ];

  static List accueil = [
    {
      'title': 'Météo',
      'image': 'images/meteo.png',
      'icon': Icons.wb_sunny,
      'route': '/meteo'
    },
    {
      'title': 'Maps',
      'image': 'images/maps.png',
      'icon': Icons.map,
      'route': '/maps'
    },
    {
      'title': 'Contacts',
      'image': 'images/contacts.png',
      'icon': Icons.contacts,
      'route': '/contacts'
    },
    {
      'title': 'Messenger',
      'image': 'images/messenger.png',
      'icon': Icons.chat_bubble,
      'route': '/messenger'
    },
    {
      'title': 'ChatBot',
      'image': 'images/chatbot.png',
      'icon': Icons.smart_toy,
      'route': '/chatbot'
    },
    {
      'title': 'Paramètres',
      'image': 'images/settings.png',
      'icon': Icons.settings,
      'route': '/parametres'
    },
  ];

  static List menus = menu;
}
