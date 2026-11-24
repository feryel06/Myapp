import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../menu/drawer.widget.dart';

class MeteoDetailsPage extends StatefulWidget {
  final String ville;
  const MeteoDetailsPage(this.ville, {super.key});

  @override
  State<MeteoDetailsPage> createState() => _MeteoDetailsPageState();
}

class _MeteoDetailsPageState extends State<MeteoDetailsPage> {
  var meteoData;

  @override
  void initState() {
    super.initState();
    getMeteoData(widget.ville);
  }

  void getMeteoData(String ville) {
    print("Meteo data de $ville");
    String url =
        "https://api.openweathermap.org/data/2.5/forecast?q=$ville&appid=c109c07bc4df77a88c923e6407aef864";

    http.get(Uri.parse(url)).then((res) {
      setState(() {
        meteoData = json.decode(res.body);
        print(meteoData);
      });
    }).catchError((err) {
      print(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Météo Details ${widget.ville}'),
        backgroundColor: Colors.blue,
      ),
      drawer: const MyDrawer(),
      body: meteoData == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : (meteoData['cod'] != "200" && meteoData['cod'] != 200)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Erreur: ${meteoData['message'] ?? 'Ville introuvable'}",
                      style: const TextStyle(fontSize: 20, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: (meteoData['list'] == null)
                      ? 0
                      : meteoData['list'].length,
                  itemBuilder: (context, index) {
                    var item = meteoData['list'][index];
                    var date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
                    var mainWeather = item['weather'][0]['main'];
                    var tempCelsius = (item['main']['temp'] - 273.15).round();

                    return Card(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.transparent],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage(
                                    "images/${mainWeather.toString().toLowerCase()}.png",
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('E - dd/MM/yyyy').format(date),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "${DateFormat('HH:mm').format(date)} | $mainWeather",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "$tempCelsius °C",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}