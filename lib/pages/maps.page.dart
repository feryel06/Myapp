import 'package:flutter/material.dart';
import '../menu/drawer.widget.dart';
import 'maps-details.page.dart';

class MapsPage extends StatelessWidget {
  final TextEditingController txt_ville = TextEditingController();

  MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text('Maps'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: txt_ville,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_city),
                hintText: "Ville",
                border: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                _onGetMapsDetails(context);
              },
              child: const Text(
                'Chercher',
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onGetMapsDetails(BuildContext context) {
    String ville = txt_ville.text.trim();
    if (ville.isEmpty) {
      ville = "Tunis";
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapsDetailsPage(ville),
      ),
    );
    txt_ville.text = "";
  }
}
