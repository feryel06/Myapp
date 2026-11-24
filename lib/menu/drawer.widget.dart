import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/global.params.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue],
              ),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.blue),
              ),
            ),
          ),
          ...GlobalParams.menus.map((item) {
            return Column(
              children: [
                ListTile(
                  leading: item['icon'],
                  title: Text(
                    item['title'],
                    style: const TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                  onTap: () async {
                    if (item['title'] == 'Déconnexion') {
                      try {
                        await FirebaseAuth.instance.signOut();
                      } catch (_) {}

                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool("connecte", false);

                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/authentification',
                          (route) => false,
                        );
                      }
                    } else {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, item['route']);
                    }
                  },
                ),
                const Divider(color: Colors.blue, height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}
