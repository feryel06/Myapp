import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../menu/drawer.widget.dart';

class MapsDetailsPage extends StatefulWidget {
  final String ville;
  const MapsDetailsPage(this.ville, {super.key});

  @override
  State<MapsDetailsPage> createState() => _MapsDetailsPageState();
}

class _MapsDetailsPageState extends State<MapsDetailsPage> {
  final Completer<GoogleMapController> _controller = Completer();
  MapType _currentMapType = MapType.normal;
  bool _hasError = false;

  static const Map<String, LatLng> _villesCoords = {
    'tunis': LatLng(36.8065, 10.1815),
    'sfax': LatLng(34.7406, 10.7603),
    'sousse': LatLng(35.8256, 10.6084),
    'tataouine': LatLng(32.9297, 10.4518),
    'bizerte': LatLng(37.2744, 9.8739),
    'nabeul': LatLng(36.4561, 10.7376),
    'monastir': LatLng(35.7833, 10.8333),
    'kairouan': LatLng(35.6781, 10.0963),
    'gabes': LatLng(33.8815, 10.0982),
    'djerba': LatLng(33.8076, 10.8804),
    'paris': LatLng(48.8566, 2.3522),
  };

  LatLng _getCoordinates(String ville) {
    String key = ville.trim().toLowerCase();
    return _villesCoords[key] ?? const LatLng(36.8065, 10.1815);
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      if (_currentMapType == MapType.normal) {
        _currentMapType = MapType.satellite;
      } else if (_currentMapType == MapType.satellite) {
        _currentMapType = MapType.hybrid;
      } else {
        _currentMapType = MapType.normal;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    LatLng targetPos = _getCoordinates(widget.ville);

    return Scaffold(
      appBar: AppBar(
        title: Text('Page Maps Details ${widget.ville}'),
        backgroundColor: Colors.blue,
      ),
      drawer: const MyDrawer(),
      body: _hasError
          ? Center(
              child: Card(
                margin: const EdgeInsets.all(20),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 60, color: Colors.blue),
                      const SizedBox(height: 10),
                      Text(
                        'Carte de ${widget.ville}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Latitude: ${targetPos.latitude}\nLongitude: ${targetPos.longitude}',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: targetPos,
                    zoom: 12.0,
                  ),
                  mapType: _currentMapType,
                  onMapCreated: (GoogleMapController controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('cityMarker'),
                      position: targetPos,
                      infoWindow: InfoWindow(
                        title: widget.ville,
                        snippet: 'Position de ${widget.ville}',
                      ),
                    ),
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FloatingActionButton(
                      onPressed: _onMapTypeButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.map, size: 30.0, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
